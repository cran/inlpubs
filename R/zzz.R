.onAttach <- function(lib, pkg) {
  if (interactive()) {
    ver <- file.path(lib, pkg, "DESCRIPTION", fsep = "/") |>
      read.dcf(fields = "Version")
    "USGS Research Package: https://owi.usgs.gov/R/packages.html#research" |>
      strwrap() |>
      paste(collapse = "\n") |>
      packageStartupMessage()
  }
  invisible()
}
