#' Mine Text
#'
#' @description Performs a term frequency text analysis.
#'   A term is defined as a word or group of words.
#'
#' @param docs 'list' or 'character' vector.
#'   Document text to analyze.
#'   Each list item contains the extracted text from a single document.
#' @param ngmin,ngmax integer number.
#'   Splits strings into *n-grams* with given minimal and maximal numbers of grams.
#'   An n-gram is an ordered sequence of n words taken from the body of a text.
#'   Requires the \pkg{RWeka} package is available and that the
#'   environment variable JAVA_HOME points to where the Java software is located.
#'   Recommended for single text compoents only.
#' @param sparse 'numeric' number that is greater than 0 and less than 1.
#'   A threshold of relative document frequency for a term.
#'   It specifies the proportion of documents in which a term must appear to be retained.
#'   For example if you specify `sparse` equal to 0.99,
#'   it removes terms that are more sparse than 0.99.
#'   Conversely, at 0.01, only terms appearing in nearly every document will be retained.
#'
#' @details HTML entities are decoded when the \pkg{textutils} package is available.
#'
#' @return A term-frequency data table giving the number of times each word occurs in the text.
#'   A column in the table represents a single component in the `docs` argument,
#'   and each row provides frequency counts for a particular word (also known as a 'term').
#'
#' @author J.C. Fisher, U.S. Geological Survey, Idaho Water Science Center
#'
#' @seealso [`search_terms`] function to search for terms within the resulting term-frequency data table.
#' @seealso [`make_wordcloud`] function to create a word cloud.
#'
#' @export
#'
#' @examples
#' d <- c(
#'   "The quick brown fox jumps over the lazy lazy dog.",
#'   "Pack my brown box.",
#'   "Jazz fly brown dog."
#' ) |>
#'   mine_text()
#'
#' d <- list(
#'   "A" = "The quick brown fox jumps over the lazy lazy dog.",
#'   "B" = c("Pack my brown box.", NA, "Jazz fly brown dog."),
#'   "C" = NA_character_
#' ) |>
#'   mine_text()

mine_text <- function(docs,
                      ngmin = 1,
                      ngmax = ngmin,
                      sparse = NULL) {

  # check arguments
  checkmate::assert_count(ngmin, positive = TRUE)
  checkmate::assert_int(ngmax, lower = ngmin)
  checkmate::assert_number(sparse, lower = 0.001, upper = 0.999, null.ok = TRUE)

  # assign names
  if (is.null(names(docs))) {
    names(docs) <- seq_along(docs) |> as.character()
  }

  # concatenate strings
  docs <- vapply(docs,
    FUN <- function(x) {
      stats::na.omit(x) |>
        as.character() |>
        paste(collapse = " ")
    },
    FUN.VALUE = character(1)
  )

  # decode HTML entities
  if (requireNamespace("textutils", quietly = TRUE)) {
    docs <- textutils::HTMLdecode(docs)
  }

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

  # create volatile corpus
  corpus <- tm::VectorSource(docs) |>
    tm::VCorpus() |>
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
  for (i in seq_along(corpus)) {
    corpus[[i]]$meta$id <- names(docs)[i]
  }

  # initialize control options
  control <- list()

  # define n-gram tokenizer
  if (ngmax > 1L) {
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
  }

  # coerce corpus to term-document matrix
  tdm <- tm::TermDocumentMatrix(corpus, control = control)

  # remove sparse terms
  if (!is.null(sparse)) {
    tdm <- tm::removeSparseTerms(tdm, sparse = sparse)
  }

  # convert to frequency table
  d <- as.table(tdm) |>
    as.data.frame(stringsAsFactors = TRUE)

  # set column names
  colnames(d) <- c("term", "pub_id", "freq")

  # set frequency to integer class
  d$freq <- as.integer(d$freq)

  # remove rows with zero frequency
  d <- d[d$freq > 0, ]

  # remove rows with duplicate words in term
  if (ngmax > 1) {
    is <- as.character(d$term) |>
      strsplit(split = " ") |>
      vapply(FUN = anyDuplicated, FUN.VALUE = integer(1)) |>
      as.logical()
    d <- d[!is, ]
  }

  # sort rows
  idxs <- order(d$term, d$freq, decreasing = c(FALSE, TRUE), method = "radix")
  d <- d[idxs, ]

  # clear row names
  rownames(d) <- NULL

  droplevels(d)
}
