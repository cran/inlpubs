#' Create Author and Publication Webpages
#'
#' @description Creates a webpage for each author, listing their publications.
#'   Each webpage is saved as an [R Markdown](https://rmarkdown.rstudio.com/) file.
#'
#' @param authors 'author' data frame.
#'   Contributing authors to the INLPO publications, see [`authors`] dataset for data format.
#' @param pubs 'pub' data frame.
#'   Publications of the INLPO, see [`pubs`] dataset for data format.
#' @param destdir 'character' string.
#'   Destination directory to write files, with tilde-expansion performed.
#'   Defaults to a temporary directory.
#' @param quiet 'logical' flag.
#'   Whether to suppress printing of debugging information.
#'
#' @return `NULL` invisibly.
#'
#' @author J.C. Fisher, U.S. Geological Survey, Idaho Water Science Center
#'
#' @export
#'
#' @keywords internal
#'
#' @examples
#' destdir <- tempfile("")
#' make_webpages(
#'   authors = inlpubs::authors,
#'   pubs = inlpubs::pubs,
#'   destdir = destdir,
#'   quiet = TRUE
#' )
#'
#' unlink(destdir, recursive = TRUE)

make_webpages <- function(authors = NULL,
                          pubs = NULL,
                          destdir = tempdir(),
                          quiet = FALSE) {

  # check arguments
  checkmate::assert_class(authors, classes = c("author", "data.frame"), null.ok = TRUE)
  checkmate::assert_class(pubs, classes = c("pub", "data.frame"), null.ok = TRUE)
  checkmate::assert_string(destdir)
  destdir <- path.expand(destdir) |> normalizePath(winslash = "/", mustWork = FALSE)
  dir.create(destdir, recursive = TRUE, showWarnings = FALSE)
  checkmate::assert_path_for_output(destdir, overwrite = TRUE)
  checkmate::assert_flag(quiet)

  # write author webpages
  if (!is.null(authors)) {
    make_author_webpages(authors, pubs, destdir, quiet)
  }

  # write publication webpages
  if (!is.null(pubs)) {
    make_pub_webpages(pubs, destdir, quiet)
  }

  invisible()
}


# Function to write author webpages ----

make_author_webpages <- function(authors, pubs, destdir, quiet) {

  # check arguments
  checkmate::assert_class(authors, classes = c("author", "data.frame"))
  checkmate::assert_path_for_output(destdir, overwrite = TRUE)
  checkmate::assert_flag(quiet)

  # make yaml headers
  headers <- vapply(authors$person,
    FUN = function(x) {
      title <- sprintf("title: \"%s\"",
        format(x, include = c("given", "family"))
      )
      paste("---", title, "---", sep = "\n")
    },
    FUN.VALUE = character(1)
  )

  # get icons
  icons <- vapply(authors$person,
    FUN = function(x) {
      orcid <- x$comment["ORCID"]
      if (!is.null(orcid)) {
        href <- paste0("https://orcid.org/", orcid)
        title <- "Open the author&#8217;s ORCID record in a new browser tab."
        img <- "<img alt='ORCID logo' src='orcid.svg' width='16' height='16' />"
        orcid <- sprintf("<a href='%s' title='%s' target='_blank'>%s&nbsp;%s</a>",
          href, title, img, orcid
        )
      }
      email <- x$email
      if (!is.null(email)) {
        href <- paste("mailto:", email)
        title <- "Contact the author"
        img <- "<img alt='Email logo' src='email.svg' width='16' height='16' />"
        email <- sprintf("<a href='%s' title='%s'>%s&nbsp;%s</a>",
          href, title, img, email
        )
      }
      sprintf("<span>%s</span>",
        paste(c(orcid, email), collapse = "&nbsp;&nbsp;&nbsp;&nbsp;")
      )
    },
    FUN.VALUE = character(1)
  )

  # make counts table
  row_names <- c(
    "total_pub" = "Total publications",
    "single_authored" = "Single authored",
    "multi_authored" = "Multi authored",
    "first_authored" = "First authored"
  )
  counts <- apply(authors,
    MARGIN = 1,
    FUN = function(x) {
      x$person <- NULL
      x$pub_id <- NULL
      d <- data.frame(x)[, names(row_names)] |> t()
      rownames(d) <- row_names
      knitr::kable(d, format = "html", align = "r") |>
        kableExtra::kable_styling(
          bootstrap_options = c("row-border", "condensed"),
          full_width = FALSE,
          position = "left"
        )
    }
  )

  # get citations
  refs <- sprintf("%s (%s)", pubs$text_ref, pubs$year)
  names(refs) <- pubs$pub_id
  citations <- vapply(authors$pub_id,
    FUN = function(ids) {
      vapply(ids,
        FUN = function(id) {
          href <- sprintf("pub-%s.html", id)
          ref <- sprintf("<h4><a href='%s'>%s</a></h4>", href, refs[id])
          bib <- attr(unclass(pubs[id, "bibentry"])[[1]], which = "textVersion")
          paste(ref, bib, sep = "\n\n")
        },
        FUN.VALUE = character(1)
      ) |>
        paste(collapse = "\n\n")
    },
    FUN.VALUE = character(1)
  )

  # set paths to temporary location for Rmd files
  tempdir <- tempfile(pattern = "")
  dir.create(tempdir, showWarnings = FALSE)
  files <- file.path(tempdir, sprintf("author-%s.Rmd", authors$author_id))

  # loop through files
  for (i in seq_along(files)) {
    if (!quiet) {
      message("Writing ", sQuote(basename(files[i]), q = FALSE))
    }

    # send output to file
    sink(file = files[i])

    # write file content
    cat(headers[i], "", sep = "\n")
    cat(icons[i], "", sep = "\n")
    cat("## Counts", "", counts[i], "", sep = "\n")
    cat("## Citations", "", citations[i], "", sep = "\n")

    # end output to file
    sink()
  }

  # copy temporary files to destination directory
  list.files(path = destdir, pattern = "^author-", full.names = TRUE) |> unlink()
  file.copy(from = files, to = destdir) |> invisible()

  # delete temporary files
  unlink(tempdir, recursive = TRUE)

  invisible()
}


# Function to write publication webpages ----

make_pub_webpages <- function(pubs, destdir, quiet) {

  # check arguments
  checkmate::assert_class(pubs, classes = c("pub", "data.frame"))
  checkmate::assert_path_for_output(destdir, overwrite = TRUE)

  # get text references
  refs <- sprintf("%s (%s)", pubs$text_ref, pubs$year)
  names(refs) <- pubs$pub_id

  # make yaml headers
  headers <- vapply(seq_along(refs),
    FUN = function(i) {
      href <- paste0("https://doi.org/", pubs$bibentry[i]$doi)
      title <- "Launch the external DOI link, which leads to the publication content, in a separate browser tab."
      img <- "<img alt='DOI link' align='right' src='doi.svg' width='20' height='20' />"
      doi <- sprintf("<a href='%s' title='%s' target='_blank'>%s</a>", href, title, img)
      title <- sprintf("title: \"%s%s\"", refs[i], doi)
      paste("---", title, "---", sep = "\n")
    },
    FUN.VALUE = character(1)
  )

  # make covers
  covers <- vapply(pubs$pub_id,
    FUN = function(x) {
      file <- sprintf("vignettes/pub-%s.jpg", x)
      if (checkmate::test_file_exists(file, access = "r")) {
        sprintf(
          "<img class='cover-image' src='%s' alt='Cover image' align='right' width='300px' />",
          basename(file)
        )
      } else {
        character(1)
      }
    },
    FUN.VALUE = character(1)
  )

  # get publication titles
  titles <- pubs$title

  # get author names
  authors <- vapply(pubs$bibentry,
    FUN = function(x) {
      author <- format(x$author, include = c("given", "family"))
      author <- gsub(" ", "&nbsp;", author)
      ids <- names(x$author)
      for (i in seq_along(ids)) {
        href <- sprintf("author-%s.html", ids[i])
        author[i] <- sprintf("<a href='%s'>%s</a>", href, author[i])
      }
      n <- length(author)
      if (n > 2) {
        author[-n] <- paste0(author[-n], ",")
      }
      if (n > 1) {
        author[n] <- paste("and", author[n])
      }
      paste(author, collapse = " ")
    },
    FUN.VALUE = character(1)
  )

  # get citations
  citations <- vapply(pubs$bibentry,
    FUN = function(x) {
      attr(unclass(x)[[1]], which = "textVersion")
    },
    FUN.VALUE = character(1)
  )

  # get BibTex entries
  bibtexs <- vapply(pubs$bibentry,
    FUN = function(bib) {
      bibtex <- utils::toBibtex(bib) |> paste(collapse = "\n")
      paste(
        "<a href='#bibtex' class='btn btn-default btn-xs' data-toggle='collapse' title='%s'>BibTeX</a>",
        "<div id='bibtex' class='collapse'><pre><code>%s</pre></code></div>",
        sep = "\n"
      ) |>
        sprintf("Switch between displaying and hiding the BibTeX citation.", bibtex)
    },
    FUN.VALUE = character(1)
  )

  # get abstracts
  abstracts <- pubs$abstract |> stringi::stri_unescape_unicode()

  # get annotations
  annotations <- pubs$annotation |> stringi::stri_unescape_unicode()

  # get annotation sources
  txt <- refs[pubs$annotation_src]
  hrefs <- sprintf("pub-%s.html", names(txt))
  annotation_srcs <- sprintf("<a href='%s'>%s</a>", hrefs, txt)
  annotation_srcs[is.na(txt)] <- NA_character_

  # set paths to temporary location for Rmd files
  tempdir <- tempfile(pattern = "")
  dir.create(tempdir, showWarnings = FALSE)
  files <- file.path(tempdir, sprintf("pub-%s.Rmd", pubs$pub_id))

  # loop through files
  for (i in seq_along(files)) {
    if (!quiet) {
      message("Writing ", sQuote(basename(files[i]), q = FALSE))
    }

    # send output to file
    sink(file = files[i])

    # write file content
    cat(headers[i], "", sep = "\n")
    cat(paste("## Title", covers[i]), "", titles[i], "", sep = "\n")
    cat("## Authors", "", authors[i], "", sep = "\n")
    cat("## Citation", "", citations[i], "", sep = "\n")
    cat(bibtexs[i], "", sep = "\n")
    if (!is.na(abstracts[i])) {
      cat("## Abstract", "", abstracts[i], "", sep = "\n")
    }
    if (!is.na(annotations[i])) {
      cat("## Annotation", "", annotations[i], "", paste("--- From", annotation_srcs[i]), "", sep = "\n")
    }

    # end output to file
    sink()
  }

  # copy temporary files to destination directory
  list.files(path = destdir, pattern = "^pub-*(.+).Rmd$", full.names = TRUE) |> unlink()
  file.copy(from = files, to = destdir) |> invisible()

  # delete temporary files
  unlink(tempdir, recursive = TRUE)

  invisible()
}
