#' Bibliographic information of the INLPO
#'
#' Bibliographic information for reports, articles, maps, and theses related
#' to scientific monitoring and research conducted by the U.S. Geological Survey (USGS),
#' Idaho Water Science Center, Idaho National Laboratory Project Office
#' ([INLPO](https://www.usgs.gov/centers/idaho-water-science-center/science/idaho-national-laboratory-project-office)).
#'
#' @format An object of class 'pubs_data' that inherits behavior from the data frame class.
#'   Each record corresponds to a bibliographical item and contains the following variables:
#'   \describe{
#'     \item{`key`}{[BibTeX](https://en.wikipedia.org/wiki/BibTeX) key for the citation entry;}
#'     \item{`year`}{year of publication;}
#'     \item{`citation`}{bibliographic entry of class [`bibentry`][utils::bibentry];}
#'     \item{`abstract`}{abstract text string;}
#'     \item{`annotation`}{annotation text string (Knobel and others, 2005; Bartholomay, 2022).}
#'   }
#'   Row names are the BibTeX key for the citation entry.
#'
#' @source Many of these publications are available through the
#'   [USGS Publications Warehouse](https://pubs.er.usgs.gov/).
#'
#' @references
#'    Bartholomay, R.C., 2022, Historical development of the U.S. Geological Survey hydrological monitoring
#'    and investigative programs at the Idaho National Laboratory, Idaho, 2002–2020: U.S. Geological Survey
#'    Open-File Report 2022–1027 (DOE/ID-22256), 54 p., \doi{10.3133/ofr20221027}.
#' @references
#'    Knobel, L.L., Bartholomay, R.C., and Rousseau, J.P., 2005,
#'    Historical development of the U.S. Geological Survey hydrologic monitoring and investigative programs
#'    at the Idaho National Engineering and Environmental Laboratory, Idaho, 1949 to 2001:
#'    U.S. Geological Survey Open-File Report 2005--1223 (DOE/ID--22195), 93 p.,
#'    \doi{10.3133/ofr20051223}.
#'
#' @keywords datasets
#'
#' @examples
#' ## Display table structure
#' str(pubs, max.level = 1, nchar.max = 50)
#'
#' ## Print the citation key for each entry in the bibliography:
#' rownames(pubs[1:10, ])
#'
#' ## Print citation, authors, and abstract for Fisher and others (2012):
#' key <- "FisherOthers2012"
#' ref <- pubs[key, "citation"]
#' print(ref, style = "citation", bibtex = TRUE)
#' format(ref$author, c("given", "family"))
#' pubs[key, "abstract"] |> strwrap() |> cat(sep = "\n")
#'
#' ## Print list of authors:
#' authors <- do.call("c", pubs$citation$author)
#' authors <- authors[!duplicated(authors)]
#' authors[1:10] |> format() |> cat(sep = "\n")
#'
#' ## Export suggested citations from the bibliography:
#' txt <- vapply(pubs$citation, function(x) {
#'   attr(unclass(x)[[1]], which = "textVersion")
#' }, character(1))
#' txt <- sort(txt) |>
#'   rbind(character(nrow(pubs))) |>
#'   c() |>
#'   head(n = -1L) |>
#'   strwrap(width = 80, exdent = 2)
#' file <- tempfile(fileext = ".txt")
#' writeLines(txt, file)
#' if (interactive()) {
#'   file.show(file,
#'     title = "Suggested citations",
#'     encoding = "UTF-8"
#'   )
#' }
#'
#' unlink(file)

"pubs"
