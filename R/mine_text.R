#' Mine Text Components in the INLPO Publications
#'
#' Performs a word frequency text analysis of Idaho National Laboratory Project Office
#' ([INLPO](https://www.usgs.gov/centers/idaho-water-science-center/science/idaho-national-laboratory-project-office))
#' publications.
#'
#' @param pubs 'pub' class.
#'   Bibliographic information, see [`pubs`] dataset for details.
#' @param components character vector.
#'   One or more text components to analyze.
#'   Choices include the "title", "abstract", "annotation", and "bibentry" of the document.
#' @param ngmin,ngmax integer number.
#'   Splits strings into *n-grams* with given minimal and maximal numbers of grams.
#'   An n-gram is an ordered sequence of n words taken from the body of a text.
#'   Requires the \pkg{RWeka} package is available and that the
#'   environment variable JAVA_HOME points to where the Java software is located.
#'   Recommended for single text compoents only.
#' @param lowfreq integer number.
#'   Lower frequency bound.
#'   Words that occur less than this bound are excluded from the returned frequency table.
#'
#' @details HTML entities are decoded when the \pkg{textutils} package is available.
#'
#' @return A word frequency table giving the number of times each word occurs in a publication's text component(s).
#'   A table column represents a single publication that is identified using its bibentry-key.
#'   And each row provides frequency counts for a particular word (also known as a 'term').
#'
#' @author J.C. Fisher, U.S. Geological Survey, Idaho Water Science Center
#'
#' @seealso
#'   [`make_wordcloud`] function to create a word cloud.
#'
#' @export
#'
#' @examples
#' m <- head(pubs, 3) |> mine_text()
#' head(m)
#'
#' \dontrun{
#'   d <- data.frame(word = rownames(m), freq = rowSums(m))
#'   file <- make_wordcloud(d, display = interactive())
#'   unlink(file)
#' }

mine_text <- function(pubs,
                      components = c("title", "abstract"),
                      ngmin = 1L,
                      ngmax = ngmin,
                      lowfreq = 1L) {

  # check arguments
  checkmate::assert_class(pubs, classes = c("pub", "data.frame"))
  choices <- c("title", "abstract", "annotation", "bibentry")
  components <- match.arg(components, choices, several.ok = TRUE)
  checkmate::assert_count(ngmin, positive = TRUE)
  checkmate::assert_int(ngmax, lower = ngmin)
  checkmate::assert_count(lowfreq, positive = TRUE)

  # extract text component(s)
  texts <- apply(pubs,
    MARGIN = 1,
    FUN = function(x) {
      txt <- character(0)
      if ("title" %in% components) {
        txt <- c(txt, x$bibentry$title)
      }
      if ("abstract" %in% components) {
        txt <- c(txt, x$abstract)
      }
      if ("annotation" %in% components) {
        txt <- c(txt, x$annotation)
      }
      if ("bibentry" %in% components) {
        txt <- attr(unclass(x$bibentry)[[1]], which = "textVersion")
      }
      txt <- stats::na.omit(txt)
      if (length(txt) == 0) {
        return(NA_character_)
      }
      txt <- paste(txt, collapse = " ")
      if (requireNamespace("textutils", quietly = TRUE)) {
        txt <- textutils::HTMLdecode(txt)
      }
      txt
    }
  )

  # define transformation functions
  remove_url <- tm::content_transformer(
    FUN = function(x) {
      gsub("(f|ht)tp(s?)://\\S+", "", x, perl = TRUE)
    }
  )
  remove_pat <- tm::content_transformer(
    FUN = function(x, pattern) {
      gsub(pattern, " ", x)
    }
  )

  # create volatile corpora
  corpora <- tm::VCorpus(tm::VectorSource(texts)) |>
    tm::tm_map(remove_url) |>
    tm::tm_map(remove_pat, "\\\\u[0-9A-Fa-f]{4}") |>
    tm::tm_map(remove_pat, "\\\\n") |>
    tm::tm_map(remove_pat, "<.*?>") |>
    tm::tm_map(remove_pat, "/") |>
    tm::tm_map(remove_pat, "@") |>
    tm::tm_map(remove_pat, "\\|") |>
    tm::tm_map(tm::content_transformer(tolower)) |>
    tm::tm_map(tm::removeNumbers) |>
    tm::tm_map(tm::removeWords, tm::stopwords("english")) |>
    tm::tm_map(tm::removeWords, tm::stopwords("SMART")) |>
    tm::tm_map(tm::removePunctuation, preserve_intra_word_dashes = TRUE) |>
    tm::tm_map(tm::stripWhitespace)

  # identify with publication identifier
  for (i in seq_along(corpora)) {
    corpora[[i]]$meta$id <- pubs$pub_id[i]
  }

  # define n-gram tokenizer
  if (ngmin > 1L || ngmax > 1L) {
    is <- Sys.getenv("JAVA_HOME") |> checkmate::test_directory_exists(access = "r")
    if (!is) {
      stop("JAVA_HOME cannot be determined from the Registry", call. = FALSE)
    }
    if (!requireNamespace("RWeka", quietly = TRUE)) {
      stop("word n-grams require the 'RWeka' package", call. = FALSE)
    }
    control <- list(
      "tokenize" = function(x) {
        RWeka::NGramTokenizer(x,
          control = RWeka::Weka_control(min = ngmin, max = ngmax)
        )
      }
    )
  } else {
    control <- list()
  }

  # coerce corpora to a document-term matrix
  dtm <- tm::TermDocumentMatrix(corpora, control = control)

  # find frequently occurring words
  words <- tm::findFreqTerms(dtm, lowfreq = lowfreq)
  if (!is.null(words)) {
    dtm <- dtm[words, ]
  }

  # coerce document-term matrix to a frequency table
  tbl <- as.matrix(dtm)

  # sort table in decreasing frequency
  idxs <- rowSums(tbl) |> order(decreasing = TRUE)
  tbl <- tbl[idxs, ]

  tbl
}
