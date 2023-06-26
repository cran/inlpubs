# Function that takes author keys and returns author entries ----

get_person <- function(x, authors) {

  # check arguments
  checkmate::assert_character(x, any.missing = FALSE, unique = TRUE, .var.name = "get_person")
  checkmate::assert_class(authors, classes = "person")

  is <- !(x %in% names(authors))
  if (any(is)) {
    bad <- x[is] |> sQuote() |> paste(collapse = ",")
    txt <- sprintf("Missing entry for the following author key(s): {%s}.", bad)
    stop(txt, call. = FALSE)
  }
  authors[x]
}


# Function to read and parse markdown text ----

parse_markdown <- function(filename, citation_keys = NULL) {

  # check arguments
  checkmate::assert_file_exists(filename, access = "r")
  checkmate::assert_character(citation_keys, any.missing = FALSE, unique = TRUE, null.ok = TRUE)

  label <- basename(filename) |> sQuote()

  md <- readLines(filename, encoding = "UTF-8")
  idxs <- grep("^ *(#{1,6}) *([^\n]+?) *#* *(?:\n+|$)", md)

  keys <- gsub("#", "", md[idxs]) |> trimws()
  is <- duplicated(keys)
  if (any(is)) {
    bad <- keys[is] |> sQuote() |> paste(collapse = ",")
    txt <- sprintf("In %s file: duplicated key(s): {%s}.", label, bad)
    stop(txt, call. = FALSE)
  }

  md[idxs] <- "<<citation-key>>"

  entries <- paste(md, collapse = "\n") |>
    strsplit("<<citation-key>>") |>
    unlist()
  entries <- strsplit(entries[-1], split = "\n\n")
  names(entries) <- keys

  entries <- vapply(entries, function(x) {
    entry <- x[nchar(x) > 0L] |>
      trimws() |>
      paste(collapse = "\n\n") |>
      stringi::stri_escape_unicode()
    tools::showNonASCII(entry)
    entry
  }, character(1))

  if (is.null(citation_keys)) return(entries)

  out <- rep(NA_character_, times = length(citation_keys))
  names(out) <- citation_keys

  idxs <- match(names(entries), names(out))
  if (anyNA(idxs)) {
    bad <- names(entries)[is.na(idxs)] |> sQuote() |> paste(collapse = ",")
    txt <- sprintf("In %s file: citation entry not found for key(s): {%s}.", label, bad)
    stop(txt, call. = FALSE)
  }

  out[idxs] <- entries

  out
}
