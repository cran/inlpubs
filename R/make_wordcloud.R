#' Create Word Cloud from Frequency Table of Words
#'
#' @description Create a word cloud from a frequency table of words, and save to a PNG file.
#'   Requires R-packages \pkg{htmltools}, \pkg{htmlwidgets}, \pkg{magick}, \pkg{webshot2},
#'   and \pkg{wordcloud2} are available.
#'   System dependencies include the the following:
#'   [ImageMagick](https://imagemagick.org/) for displaying the PNG image,
#'   [OptiPNG](https://optipng.sourceforge.net/) for PNG file compression, and
#'   [Chrome](https://www.google.com/chrome/)- or a Chromium-based browser
#'   with support for the Chrome DevTools protocol.
#'   Use [`find_chromate`][chromote::find_chrome] function to find the path to the Chrome browser.
#'
#' @param x 'data.frame'.
#'   A frequency table of words that includes "word" and "freq" in each column.
#' @param max_words 'integer' number.
#'   Maximum number of words to include in the word cloud.
#' @param size 'numeric' number.
#'   Font size, where the larger size indicates a bigger word.
#' @param shape 'character' string.
#'   Shape of the \dQuote{cloud} to draw.
#'   Possible shapes include a "circle", "cardioid", "diamond",
#'   "triangle-forward", "triangle", "pentagon", and "star".
#' @param ellipticity 'numeric' number.
#'   Degree of \dQuote{flatness} of the shape to draw, a value between 0 and 1.
#' @param ...
#'   Additional arguments to be passed to the [`wordcloud2`][wordcloud2::wordcloud2] function.
#' @param width 'integer' number.
#'   Desired image width in pixels.
#' @param output 'character' string.
#'   Path to the output file, by default the word cloud is copied to a temporary file.
#' @param display 'logical' flag.
#'   Whether to display the saved PNG file in a graphics window.
#'   Requires access to the \pkg{magick} package.
#'
#' @return File path to the word cloud plot in PNG format.
#'
#' @author J.C. Fisher, U.S. Geological Survey, Idaho Water Science Center
#'
#' @export
#'
#' @examples
#' \dontrun{
#'   file <- wordcloud2::demoFreq |>
#'     make_wordcloud(size = 1.5, display = interactive())
#'
#'   unlink(file)
#' }

make_wordcloud <- function(x,
                           max_words = 200L,
                           size = 1,
                           shape = "circle",
                           ellipticity = 0.65,
                           ...,
                           width = 910L,
                           output = NULL,
                           display = FALSE) {

  # check packages
  pkgs <- c(
    "htmltools",
    "htmlwidgets",
    "magick",
    "utils",
    "webshot2",
    "wordcloud2"
  )
  is <- vapply(pkgs, FUN = requireNamespace, FUN.VALUE = logical(1), quietly = TRUE)
  if (any(!is)) {
    txt <- pkgs[!is] |> sQuote(q = FALSE) |> paste(collapse = ", ")
    stop("Word cloud requires missing package(s): ", txt, call. = FALSE)
  }

  # check arguments
  checkmate::assert_data_frame(x,
    types = c("factor", "character", "integerish"),
    any.missing = FALSE,
    min.rows = 3,
    min.cols = 2
  )
  checkmate::assert_names(colnames(x), must.include = c("word", "freq"))
  checkmate::assert_count(max_words, positive = TRUE)
  checkmate::assert_number(size, lower = 0, finite = TRUE)
  shape <- match.arg(shape,
    choices = c(
      "circle",
      "cardioid",
      "diamond",
      "triangle-forward",
      "triangle",
      "pentagon",
      "star"
    )
  )
  checkmate::assert_number(ellipticity, lower = 0, upper = 1, finite = TRUE)
  checkmate::assert_count(width, positive = TRUE)
  checkmate::assert_flag(display)
  if (is.null(output)) {
    output <- tempfile(fileext = ".png")
  }
  output <- normalizePath(output, winslash = "/", mustWork = FALSE)
  checkmate::assert_path_for_output(output, overwrite = TRUE, extension = "png")

  # sort data in decreasing frequency
  d <- x[order(x$freq, decreasing = TRUE), ]

  # exclude words that are infrequently used
  d <- utils::head(x, max_words)

  # create word cloud html widget
  wc <- wordcloud2::wordcloud2(d,
    size = size,
    shape = shape,
    ellipticity = ellipticity,
    ...
  )

  # configure to not display hover labels
  sty <- htmltools::HTML(".wcLabel {display: none;}")
  tag <- htmltools::tags$style(sty) |> htmltools::tags$head()
  wc <- htmlwidgets::prependContent(wc, tag)

  # save word-cloud widget to a temporary HTML file
  html <- tempfile(fileext = ".html")
  htmlwidgets::saveWidget(wc, html, selfcontained = FALSE)

  # take screenshot of html file and save to a PNG file
  webshot2::webshot(
    url = html,
    file = output,
    vwidth = width,
    vheight = as.integer(width * ellipticity),
    cliprect = "viewport",
    delay = 10
  )

  # delete html files
  unlink(
    list.files(
      path = dirname(html),
      pattern = sub(".html", "", basename(html)),
      full.names = TRUE
    ),
    recursive = TRUE
  )

  # recompress png file
  suppressWarnings(
    system2(
      command = "optipng",
      args = c("-quiet", "-strip all", "-o7", shQuote(output))
    )
  )

  # display saved PNG in a graphics window
  if (display) {
    magick::image_read(output) |> plot()
  }

  invisible(output)
}
