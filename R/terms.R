#' Term Frequency from INLPO Publications
#'
#' @description Term frequency from publications by the U.S. Geological Survey (USGS),
#'   Idaho Water Science Center, Idaho National Laboratory Project Office (INLPO).
#'
#' @format An object of class 'term' that inherits behavior from the 'data.frame' class
#'   and includes the following columns:
#'   \describe{
#'     \item{`term`}{Term, a word or group of words,
#'       represented by an ASCII character string in lowercase.}
#'     \item{`pub_id`}{Identifier for a publication,
#'       referes to the primry key of the [`pubs`] data table.}
#'     \item{`freq`}{Frequency count from text analysis.}
#'   }
#'
#' @source The publication text was sourced from the original PDF documents using the [`extract_pdf_text`] function,
#'   and term frequencies were extracted from the text using the [`mine_text`] function.
#'
#' @keywords datasets
#'
#' @examples
#' str(terms, max.level = 3, width = 75, strict.width = "cut")

"terms"
