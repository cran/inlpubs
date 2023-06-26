## ----"setup", include=FALSE---------------------------------------------------
library(inlpubs)
cit <- inlpubs::pubs$citation
dt_opt <- list(
  "dom" = "Blfrtip",
  "lengthMenu" = list(
    c(10L, 25L, 50L, -1L),
    c("10", "25", "50", "all")
  ),
  "buttons" = list(
    list(
      "extend" = "copyHtml5",
      "titleAttr" = "Copy visible data (tab deliminated) to clipboard",
      "title" = NULL,
      "exportOptions" = list(
        "columns" =  ":visible",
        "rows" = ":visible"
      )
    ),
    list(
      "extend" = "csvHtml5",
      "titleAttr" = "Save all rows in a CSV (comma deliminated) file format",
      "filename" = "inlpubs-authors"
    )
  )
)

## ----"aut_dat", include=FALSE-------------------------------------------------
all_aut <- lapply(cit, function(x) names(x$author))
aut <- do.call("c", cit$author)
aut <- aut[!duplicated(aut)]
nm <- vapply(aut, function(x) format(x, c("family", "given")), character(1))
aut <- aut[order(nm)]
names(aut) <- NULL

key <- paste0(substr(format(aut, "given"), 1, 1), format(aut, "family"))
key <- vapply(key, function(x) strsplit(x, " ")[[1]][1], character(1))
key <- tolower(gsub("-", "", key))
key <- tolower(gsub("'", "", key))

author <- vapply(aut, function(x) {
  a <- format(x, c("family", "given"), braces = list(family = c("", ",")))
  orcid <- x$comment["ORCID"]
  if (!is.null(x$comment["ORCID"])) {
    href <- sprintf("https://orcid.org/%s", x$comment["ORCID"])
    icon <- sprintf("<a href='%s' target='_blank'>%s</a>", href, inlpubs:::orcid_icon)
    a <- paste0(a, icon)
  }
  if (!is.null(x$email)) {
    href <- sprintf("mailto: %s", x$email)
    icon <- sprintf("<a href='%s'>%s</a>", href, inlpubs:::email_icon)
    a <- paste0(a, icon)
  }
  a
}, character(1))

d <- data.frame(
  "author" = author,
  "total_pub" = NA_integer_,
  "single_aut" = NA_integer_,
  "multi_aut" = NA_integer_,
  "first_aut" = NA_integer_,
  "syear" = NA_integer_,
  "eyear" = NA_integer_,
  row.names = key, stringsAsFactors = FALSE
)
for (i in seq_along(key)) {
  d$total_pub[i] <- sum(vapply(all_aut, function(x) {
    key[i] %in% x
  }, logical(1)))
  d$single_aut[i] <- sum(vapply(all_aut, function(x) {
    length(x) == 1 & key[i] %in% x
  }, logical(1)))
  d$multi_aut[i] <- sum(vapply(all_aut, function(x) {
    length(x) > 1 & key[i] %in% x
  }, logical(1)))
  d$first_aut[i] <- sum(vapply(all_aut, function(x) {
    length(x) > 1 & key[i] == x[1]
  }, logical(1)))
  bib <- cit[vapply(all_aut, function(x) key[i] %in% x, logical(1))]
  yrs <- range(as.integer(vapply(bib, function(x) x$year, character(1))))
  d$syear[i] <- yrs[1]
  d$eyear[i] <- yrs[2]
}

d <- d[order(d$total_pub, decreasing = TRUE), ]

aut_dat <- d

## ----"aut_tbl", echo=FALSE, results="asis"------------------------------------
cols <- c(
  "Author name",
  "Total<br/>publications",
  "Single-<br/>authored",
  "Multi-<br/>authored",
  "First-<br/>authored",
  "First<br/>year",
  "Last<br/>year"
)
DT::datatable(aut_dat,
  options = dt_opt,
  extensions = "Buttons",
  class = "hover row-border compact",
  colnames = cols,
  rownames = FALSE,
  escape = FALSE,
  elementId = "htmlwidget-aut-tbl"
)

