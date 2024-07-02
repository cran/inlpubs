#' Search Terms
#'
#' @description Pattern matches a search term within the term-frequency data table.
#'
#' @param x 'character' string.
#'   Term searched for in the term-frequency data table.
#' @param data 'term' and 'data.frame' class.
#'   Term-frequency data table.
#'   Defaults to using the term frequencies from the INLPO publications,
#'   see [`terms`] dataset for details.
#' @param ignore.case 'logical' flag.
#'   Whether to ignore character case during pattern matching.
#' @param ...
#'   Additional arguments passed to the [`grep`] function.
#' @param low_freq 'numeric' number.
#'   Lower frequency bound.
#' @param high_freq 'numeric' number.
#'   Upper frequency bound.
#' @param simplify 'logical' flag.
#'   Whether to return only the unique publication identifiers.
#'
#' @return A subset of the data table sorted by decreasing frequency.
#'
#' @author J.C. Fisher, U.S. Geological Survey, Idaho Water Science Center
#'
#' @export
#'
#' @seealso [`mine_text`] function to perform a term frequency text analysis.
#'
#' @examples
#' search_terms("mlms")
#'
#' out <- search_terms("mlms", simplify = FALSE)
#' head(out)

search_terms <- function(x,
                         data = inlpubs::terms,
                         ignore.case = TRUE,
                         ...,
                         low_freq = 1,
                         high_freq = Inf,
                         simplify = TRUE) {

  # check arguments
  checkmate::assert_string(x, na.ok = FALSE)
  checkmate::assert_class(data, classes = c("term", "data.frame"))
  checkmate::assert_flag(ignore.case)
  checkmate::assert_number(low_freq, lower = 1)
  checkmate::assert_number(high_freq, lower = low_freq)
  checkmate::assert_flag(simplify)

  # extract matching data and drop factor levels
  is <- grepl(pattern = x, data$term, ignore.case = ignore.case, ...)
  out <- data[is, ]

  # extract data within frequency bounds
  is <- out$freq >= low_freq & out$freq <= high_freq
  out <- out[is, ]

  # sort by decreasing frequency
  idxs <- order(out$freq, out$pub_id, decreasing = c(TRUE, FALSE), method = "radix")
  out <- out[idxs, ]

  # drop factor levels
  out <- droplevels(out)

  # simplify results
  if (simplify) {
    out <- out$pub_id |>
      as.character() |>
      unique()
  }

  out
}
