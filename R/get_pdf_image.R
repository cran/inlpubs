#' Obtain Image from a PDF Document
#'
#' @description Obtain an image from any PDF document.
#'   Requires that the \pkg{pdftools} and \pkg{magick} packages are available.
#'
#' @param input 'character' string.
#'   File path to PDF document.
#' @param output 'character' string.
#'   Location to write the JPEG image file.
#' @param page 'integer' number.
#'   Page number in the document.
#'   Defaults to page 1.
#' @param width 'integer' number.
#'   Image width in pixels.
#' @param depth 'integer' number.
#'   Image color depth (either 8 or 16).
#'   Defaults to 8.
#' @param quality 'integer' number.
#'   JPEG quality, a number between 0 and 100.
#'   Defaults to 70.
#'
#' @return Returns the path to the image file.
#'
#' @author J.C. Fisher, U.S. Geological Survey, Idaho Water Science Center
#'
#' @export
#'
#' @seealso [`add_content`] function to add cover images to the \pkg{inlpubs} package.
#'
#' @examples
#' input <- system.file("extdata", "test.pdf", package = "inlpubs")
#' path <- get_pdf_image(input)
#'
#' unlink(path)

get_pdf_image <- function(input,
                          output = tempfile(fileext = ".jpg"),
                          page = 1,
                          width = 300,
                          depth = 8,
                          quality = 70) {

  # check system dependencies
  if (!requireNamespace("pdftools", quietly = TRUE)) {
    stop("Reading a PDF requires the 'pdftools' package", call. = FALSE)
  }
  if (!requireNamespace("magick", quietly = TRUE)) {
    stop("Image processing requires the 'magick' package", call. = FALSE)
  }

  # check arguments
  input <- path.expand(input) |> normalizePath(winslash = "/", mustWork = FALSE)
  checkmate::assert_file_exists(input, access = "r", extension = "pdf")
  output <- path.expand(output) |> normalizePath(winslash = "/", mustWork = FALSE)
  checkmate::assert_path_for_output(output, overwrite = TRUE)
  checkmate::assert_int(page, lower = 1)
  checkmate::assert_int(width, lower = 1)
  checkmate::assert_subset(depth, choices = c(8, 16))
  checkmate::assert_int(quality, lower = 0, upper = 100)

  # set output's file extension
  if (!grepl("\\.(jpg|jpeg)$", tolower(output))) {
    output <- paste0(output, ".jpg")
  }

  # read and process image
  image <- magick::image_read_pdf(path = input, pages = page) |>
    magick::image_scale(
      geometry = magick::geometry_size_pixels(width = width)
    ) |>
    magick::image_convert(
      format = "jpeg",
      colorspace = "rgb",
      depth = depth,
      interlace = "Plane"
    ) |>
    magick::image_blur(radius = 0, sigma = 0.05) |>
    magick::image_strip()

  # write image
  magick::image_write(image, path = output, quality = quality)

  # check file exists
  checkmate::assert_file_exists(output, access = "r")

  output
}
