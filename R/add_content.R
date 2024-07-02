#' Add Content from PDF Documents
#'
#' @description Incorporate the text or cover image from a PDF document into the \pkg{inlpubs} package.
#'
#' @param pub_id 'character' vector.
#'   Unique identifier for the publication.
#'   May also be specified using the `year` of publication.
#' @param year 'integer' vector.
#'   Year of publication.
#' @param type 'character' string.
#'   Type of content to extract from the PDF file.
#'   Specify as either "text" (the default) or "image".
#' @param ...
#'   Arguments to be passed to the extraction function,
#'   [`extract_pdf_text`] for "text" and [`extract_pdf_image`] for "image".
#' @param srcdir 'character' string.
#'   The PDF document is located in a subdirectory of the source directory,
#'   and this subdirectory is named after the publication year.
#'   It is set to default to the 'archive' directory, which is found in the working directory.
#' @param destdir 'character' string.
#'   Target folder for the cover image that is saved in JPEG format.
#'   Defaults to the temporary directory.
#' @param ignore 'character' vector.
#'   Publication identifier(s) to ignore.
#' @param pubs 'pub' table.
#'   Publications of the INLPO, see [`pubs`] dataset for data format.
#' @param overwrite 'logical' flag.
#'   Whether to overwrite an existing text or image file.
#'
#' @return Returns the path to the saved text or image file, invisibly.
#'
#' @author J.C. Fisher, U.S. Geological Survey, Idaho Water Science Center
#'
#' @export
#'
#' @keywords internal

add_content <- function(pub_id,
                        year,
                        type = c("text", "image"),
                        ...,
                        srcdir = "archive",
                        destdir = tempdir(),
                        ignore = NULL,
                        pubs = inlpubs::pubs,
                        overwrite = FALSE) {

  # check arguments
  if (missing(pub_id)) {
    pub_id <- NULL
  }
  if (!missing(year)) {
    checkmate::assert_integerish(year,
      lower = min(pubs$year),
      upper = max(pubs$year),
      any.missing = FALSE
    )
    ids <- pubs$pub_id[pubs$year %in% unique(year)]
    pub_id <- c(pub_id, ids) |> unique()
  }
  checkmate::assert_subset(pub_id, choices = pubs$pub_id, empty.ok = TRUE)
  type <- match.arg(type)
  checkmate::assert_directory_exists(srcdir)
  checkmate::assert_string(destdir, min.chars = 1)
  checkmate::assert_subset(ignore, choices = pubs$pub_id, empty.ok = TRUE)
  checkmate::assert_class(pubs, classes = c("pub", "data.frame"), null.ok = TRUE)
  checkmate::assert_flag(overwrite)

  # set extraction method
  extract <- switch(type,
    "text" = extract_pdf_text,
    "image" = extract_pdf_image
  )

  # ignore publication identifiers
  is <- pub_id %in% ignore
  pub_id <- pub_id[!is]

  # account for no publications
  if (length(pub_id) == 0) {
    return(NULL)
  }

  # get publication indexes
  idxs <- match(pub_id, pubs$pub_id)

  # set input paths
  years <- pubs$year[idxs]
  files <- vapply(pubs$files[idxs],
    FUN = function(x) {
      if (is.null(x)) NA_character_ else x[1]
    },
    FUN.VALUE = character(1)
  )
  inputs <- file.path(srcdir, years, pub_id, files)

  # remove inputs with missing document
  if (any(is <- is.na(files))) {
    message("Missing document(s) for publication: ",
      paste(sQuote(pub_id[is]), collapse = ", ")
    )
    pub_id <- pub_id[!is]
    inputs <- inputs[!is]
  }

  # create destination directory
  dir.create(destdir, showWarnings = FALSE, recursive = TRUE)

  # set output paths
  files <- sprintf("pub-%s", pub_id)
  outputs <- file.path(destdir, files)

  # extract content
  paths <- vapply(seq_along(inputs),
    FUN = function(i) {
      id <- pub_id[i] |> sQuote()
      message("Extract publication ", id)
      is <- outputs[i] |> checkmate::test_file_exists(access = "rw")
      if (is && !overwrite) {
        message("Skipping publication ", id)
        return(outputs[i])
      }
      extract(input = inputs[i], output = outputs[i], ...)
    },
    FUN.VALUE = character(1)
  )

  invisible(paths)
}
