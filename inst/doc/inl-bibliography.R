## ----"setup", include=FALSE---------------------------------------------------
library(inlpubs)
cit <- inlpubs::pubs$citation

## ----"bib_dat", include=FALSE-------------------------------------------------
key <- rownames(pubs)

cite <- apply(pubs, 1, function(x) {
  cit <- format(x$citation$author, "family")
  if (length(cit) > 2) {
    cit <- sprintf("%s and others", cit[1])
  } else if (length(cit) == 2) {
    cit <- paste(cit, collapse = " and ")
  }
  cit
})

badge <- unlist(apply(pubs, 1, function(x) {
  doi <- x$citation$doi
  fmt <- "<a class='pubs-tag %s' href='%s' target='_blank'>DOI&nbsp;%s</a>"
  if (is.null(doi)) {
    sprintf(fmt, "other", "https://www.doi.org/", "not available")
  } else {
    sprintf(fmt, "doi", sprintf("https://doi.org/%s", doi), doi)
  }
}))

title <- apply(pubs, 1, function(x) x$citation$title)

author <- apply(pubs, 1, function(x) {
  aut <- format(x$citation$author, c("given", "family"))
  for (i in seq_along(aut)) {
    orcid <- x$citation$author[i]$comment["ORCID"]
    if (!is.null(orcid)) {
      href <- sprintf("https://orcid.org/%s", orcid)
      icon <- sprintf("<a href='%s' target='_blank'>%s</a>", href, inlpubs:::orcid_icon)
      aut[i] <- paste0(aut[i], icon)
    }
    email <- x$citation$author[i]$email
    if (!is.null(email)) {
      href <- sprintf("mailto: %s", email)
      icon <- sprintf("<a href='%s'>%s</a>", href, inlpubs:::email_icon)
      aut[i] <- paste0(aut[i], icon)
    }
  }
  n <- length(aut)
  if (n > 2) aut[-n] <- paste0(aut[-n], ",")
  if (n > 1) aut[n] <- paste("and", aut[n])
  paste(aut, collapse = " ")
})

reference <- vapply(cit, function(x) attr(unclass(x)[[1]], "textVersion"), character(1))

bib <- lapply(cit, function(x) {
  b <- utils::toBibtex(x)
  idx <- c(1, length(b))
  out <- stringi::stri_wrap(b[-idx], width = 60, simplify = FALSE, indent = 2, exdent = 4)
  b[-idx] <- vapply(out, function(y) {
    stringi::stri_c(y, collapse = "\n", ignore_null = TRUE)
  }, character(1))
  b
})

## ----"bib_lst", echo=FALSE, results="asis"------------------------------------
for (yr in seq(max(pubs$year), min(pubs$year))) {
  cat(sprintf("## %s", yr), "\n\n")
  idx <- which(pubs$year %in% yr)
  if (length(idx) == 0) cat("<p>None</p>", "\n\n")
  for (i in idx) {
    cat(sprintf("### %s {#%s}", cite[i], key[i]), "\n\n")
    if (!is.null(badge[i])) {
      cat("<div style='paddding:10px 0'>", "\n")
      cat(badge[i], "\n")
      cat("</div>", "\n\n")
    }
    cat("#### Title", "\n\n")
    cat(title[i], "\n\n")
    cat("#### Authors", "\n\n")
    cat(author[i], "\n\n")
    cat("#### Suggested citation", "\n\n")
    cat(reference[i], "\n\n")

    cat("<details>", "\n")
    cat("<summary>BibTeX citation</summary>", "\n")
    cat("```", "\n")
    cat(bib[[i]], sep = "\n")
    cat("```", "\n")
    cat("</details>", "\n")
    x <- pubs[i, "abstract"]
    if (!is.na(x) && nzchar(x)) {
      cat("<details>", "\n\n")
      cat("<summary>Abstract</summary>", "\n")
      cat("\n")
      cat(stringi::stri_unescape_unicode(x), sep = "\n")
      cat("\n")
      cat("</details>", "\n\n")
    }
    x <- pubs[i, "annotation"]
    if (!is.na(x) && nzchar(x)) {
      cat("<details>", "\n")
      cat("<summary>Annotation</summary>", "\n")
      cat("\n")
      cat(stringi::stri_unescape_unicode(x), sep = "\n")
      cat("\n")
      cat("</details>", "\n\n")
    }
  }
}

