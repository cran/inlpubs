## ----"setup", include=FALSE---------------------------------------------------
library(inlpubs)
cit <- inlpubs::pubs$citation
dt_opt <- list(
  "dom" = "Blfrtip",
  "pagingType" = "full",
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
      "filename" = "inlpubs-text-mining"
    )
  )
)

## ----"bib_stats", echo=FALSE, results="asis"----------------------------------
institutions <- vapply(cit, function(x) {
  desc <- attr(unclass(x)[[1]], "bibtype")
  if (is.null(x$institution)) character(1) else x$institution
}, character(1))
is <- institutions %in% "U.S. Geological Survey"
percent_usgs <- (sum(is) / length(is) * 100) |> round(digits = 1) |> format(nsmall = 1)
years <- table(pubs$year)
mean_years <- mean(years) |> round(digits = 1) |> format(nsmall = 1)
sd_years <- sd(years) |> round(digits = 1) |> format(nsmall = 1)

## ----"ref_typ_tbl", echo=FALSE, results="asis"--------------------------------
m <- do.call("rbind", lapply(cit, function(x) {
  desc <- attr(unclass(x)[[1]], "bibtype")
  type <- if (is.null(x$type)) character(1) else x$type
  institution <- if (is.null(x$institution)) "" else x$institution
  if (desc == "TechReport") desc <- institution
  c(desc, type)
}))
d <- data.frame(m[!duplicated(m), , drop = FALSE], stringsAsFactors = FALSE)
d <- d[order(d[, 1], d[, 2]), ]
is <- d[, 2] == ""
d[is, 2] <- d[is, 1]
d[is, 1] <- NA
d[, 3] <- as.integer(table(m)[d[, 2]])
d <- d[order(d[, 1], d[, 3], decreasing = TRUE, na.last = FALSE), ]
ran <- vapply(seq_len(nrow(d)), function(i) {
  d[i, is.na(d[i, 1]) + 1L]
  is <- m[, 1] == d[i, 2] | m[, 2] == d[i, 2]
  ran <- range(pubs$year[is])
  if (identical(ran[1], ran[2])) format(ran[1]) else paste(ran, collapse = "--")
}, character(1))
d[d[, 2] == "Article", 2] <- "Article from a journal"
d[d[, 2] == "InProceedings", 2] <- "Article in a conference proceedings"
d[d[, 2] == "Proceedings", 2] <- "Proceedings of a conference"
d[d[, 2] == "MastersThesis", 2] <- "Master's thesis"
d[, 2] <- sprintf(
  "%s <span style='color:#808080;font-size:small;'>(%s)</span>",
  d[, 2], ran
)
d[, 4] <- d[, 3] / sum(d[, 3]) * 100
d[, 4] <- formatC(round(d[, 4], digits = 1), format = "f", digits = 1)
nm <- as.character(na.omit(unique(d[, 1])))
grp <- lapply(nm, function(x) range(which(d[, 1] %in% x)))
names(grp) <- nm
d <- rbind(d, c("", "Total", sum(d[, 3]), ""))
rownames(d) <- NULL
d[, 1] <- NULL
x <- knitr::kable(d,
  format = "html",
  col.names = c("Type of publication", "Count", "Percent"),
  align = c("l", "r", "r"), escape = FALSE
)
x <- kableExtra::kable_styling(x, c("row-border", "condensed"),
  full_width = FALSE, position = "left"
)
for (i in seq_along(grp)) {
  x <- kableExtra::pack_rows(x, names(grp)[i], grp[[i]][1], grp[[i]][2])
}
kableExtra::row_spec(x, row = nrow(d), italic = TRUE)

## ----"graph_prod", echo=FALSE, results="asis", fig.height=4, fig.cap=sprintf("<b>Figure 1.</b> &nbsp; Distribution of INL Project Office publications (%s--%s). USGS and non-USGS publication types are distinguished by color.", min(pubs$year), max(pubs$year))----

tbl <- table(pubs$year)
d1 <- data.frame(
  x = as.Date(sprintf("%s-01-01", names(tbl))), y1 = as.integer(tbl),
  y2 = NA_integer_, stringsAsFactors = FALSE
)
is <- vapply(pubs$citation, function(x) {
  !is.null(x$institution) && x$institution %in% "U.S. Geological Survey"
}, logical(1))
tbl <- table(pubs$year[is])
d2 <- data.frame(
  x = as.Date(sprintf("%s-01-01", names(tbl))), y2 = as.integer(tbl),
  stringsAsFactors = FALSE
)
d1$y2[match(d2$x, d1$x)] <- d2$y2
ylab <- "Total number of publications per year"
cols <- c("Non-USGS" = "#B47846", "USGS" = "#4682B4")

npubs <- apply(d1[, -1], 1, sum, na.rm = TRUE)
ylim <- range(pretty(0:max(npubs)))

dates <- d1[, 1]
pretty_dates <- pretty(dates)
is <- dates %in% pretty_dates
dates[!is] <- NA
pretty_dates <- dates[is]
at <- which(is)

graphics::par(mar = c(2.1, 3.1, 1.1, 0.1))

graphics::barplot(
  height = t(as.matrix(d1[, -1])),
  names.arg = dates,
  ylab = ylab,
  col = cols,
  space = 0,
  border = NA,
  ylim = ylim,
  yaxt = "n",
  xaxt = "n",
  cex.axis = 0.7,
  cex.lab = 0.7,
  mgp = c(2, 0.5, 0)
)

graphics::axis(
  side = 1,
  at = at,
  labels = format(pretty_dates),
  tck = 0.02,
  lwd = 0,
  lwd.ticks = 0.5,
  cex.axis = 0.7,
  mgp = c(2, 0.5, 0)
)

graphics::axis(
  side = 2,
  ylab = ylab,
  las = 2,
  tck = 0.02,
  lwd = 0,
  lwd.ticks = 0.5,
  cex.axis = 0.7,
  mgp = c(2, 0.5, 0)
)

graphics::axis(
  side = 3,
  at = at,
  labels = NA,
  tck = 0.02,
  lwd = 0,
  lwd.ticks = 0.5,
  mgp = c(2, 0.5, 0)
)

graphics::axis(
  side = 4,
  labels = NA,
  las = 2,
  tck = 0.02,
  lwd = 0,
  lwd.ticks = 0.5,
  mgp = c(2, 0.5, 0)
)

graphics::legend(
  x = "topright",
  legend = rev(names(cols)),
  fill = rev(cols),
  border = NA,
  inset = c(0.02, 0.05),
  cex = 0.7,
  box.lty = 1,
  box.lwd = 0.5,
  xpd = NA,
  bg = "#FFFFFFE7"
)

graphics:: box(lwd = 0.5)

## ----"tm_data", echo=FALSE, results="asis"------------------------------------
m <- mine_text(pubs, lowfreq = 3L)
tm_dat <- data.frame("term" = rownames(m), "count" = rowSums(m), "support" = rowSums(m > 0))
top_word <- stringi::stri_trans_totitle(tm_dat[1, "term"])
top_count <- format(tm_dat[1, "count"], big.mark = ",")

## ----"tm_tbl", echo=FALSE, results="asis"-------------------------------------
tbl <- DT::datatable(tm_dat,
  options = dt_opt,
  extensions = "Buttons",
  class = "hover row-border compact",
  colnames = c("Word", "Frequency count", "No. of publications"),
  rownames = FALSE,
  escape = FALSE,
  width = 600,
  elementId = "htmlwidget-tm-tbl"
)
tbl <- DT::formatCurrency(tbl, "count", currency = "", digits = 0)
tbl <- DT::formatCurrency(tbl, "support", currency = "", digits = 0)
tbl

