#' Obtain Text from a PDF Document
#'
#' @description Obtain text from any PDF document.
#'   Requires that the \pkg{pdftools} and \pkg{tesseract} packages are available.
#'
#' @param input 'character' string.
#'   File path to PDF document.
#' @param output 'character' string.
#'   Location to write the text file.
#' @param dpi 'integer' number between 100 and 1200.
#'   Dots per inch (DPI).
#'   The resolution of an image, specifically the number of pixels per inch.
#'   For optimal optical character recognition (OCR) accuracy, 600 DPI (the default) is recommended.
#' @param psm `integer` number between 0 and 13.
#'   Page Segmentation Mode (PSM).
#'   Describes the layout of the text you are trying to extract.
#'   For processing two columns of text you should use the page segmentation mode 1 (default).
#'   PSM 1 (default) is used to automatically segment the page into different text areas
#'   and also detect the orientation and script of the text.
#'
#' @return Returns the path to the text file.
#'   Each page from the PDF is transcribed as a separate line in the file.
#'
#' @author J.C. Fisher, U.S. Geological Survey, Idaho Water Science Center
#'
#' @export
#'
#' @seealso [`add_content`] function to add texts to the \pkg{inlpubs}-package corpus.
#'
#' @examples
#' \dontrun{
#'   input <- system.file("extdata", "test.pdf", package = "inlpubs")
#'   path <- get_pdf_text(input)
#'
#'   unlink(path)
#' }

get_pdf_text <- function(input,
                         output = tempfile(fileext = ".txt"),
                         dpi = 600,
                         psm = 1) {

  # check arguments
  input <- path.expand(input) |> normalizePath(winslash = "/", mustWork = FALSE)
  checkmate::assert_file_exists(input, access = "r", extension = "pdf")
  output <- path.expand(output) |> normalizePath(winslash = "/", mustWork = FALSE)
  checkmate::assert_path_for_output(output, overwrite = TRUE)
  checkmate::assert_int(dpi, lower = 100, upper = 1200)
  checkmate::assert_int(psm)

  # check system dependencies
  if (!requireNamespace("pdftools", quietly = TRUE)) {
    stop("Reading a PDF requires the 'pdftools' package", call. = FALSE)
  }
  if (!requireNamespace("tesseract", quietly = TRUE)) {
    stop("OCR requires the 'tesseract' package", call. = FALSE)
  }

  # set output's file extension
  if (!grepl("\\.(txt|text)$", tolower(output))) {
    output <- paste0(output, ".txt")
  }

  # use optical character recognition
  wd <- setwd(dir = tempdir())
  on.exit(setwd(wd))
  text <- pdftools::pdf_ocr_text(
    pdf = input,
    dpi = dpi,
    options = list(
      "tessedit_pageseg_mode" = psm
    )
  ) |>
    suppressWarnings()
  setwd(wd)

  # remove non-ASCII characters
  enc <- stringi::stri_enc_detect(text)[[1]]$Encoding[1]
  text <- iconv(text, from = enc, to = "ASCII", sub = " ")

  # remove non-printable characters
  text <- gsub(pattern = "[[:cntrl:]]", replacement = " ", x = text)

  # account for word hyphenation
  text <- gsub(pattern = "- ",  replacement = "-", x = text)

  # replace repeated periods with a single period
  text <- gsub(pattern = "\\.{2,}", replacement = ".", x = text)

  # replace repeated white space with a single space
  text <- gsub(pattern = "\\s+", replacement = " ", x = text)

  # remove leading/trailing white space
  text <- trimws(text)

  # write text
  writeLines(text, con = output)

  # check file exists
  checkmate::assert_file_exists(output, access = "r")

  output
}
