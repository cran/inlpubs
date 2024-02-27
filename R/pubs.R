#' Publications of the INLPO
#'
#' @description Bibliographic information for reports, articles, maps, and theses related
#'   to scientific monitoring and research conducted by the U.S. Geological Survey (USGS),
#'   Idaho Water Science Center, Idaho National Laboratory Project Office (INLPO).
#'
#' @format An object of class 'pub' that inherits behavior from the 'data.frame' class
#'   and includes the following columns:
#'   \describe{
#'     \item{`pub_id`}{Unique identifier for the publication.}
#'     \item{`institution`}{Name of the institution that published and/or sponsored the report.}
#'     \item{`type`}{Type of publication.}
#'     \item{`text_ref`}{Text reference (also known as the in-text citation) that excludes the year of publication.}
#'     \item{`year`}{Year of publication.}
#'     \item{`author_id`}{Identifier(s) of the author(s),
#'       referes to the primry key of the [`authors`] data table.}
#'     \item{`title`}{Title of publication.}
#'     \item{`bibentry`}{Bibliographic entry of class [`bibentry`][utils::bibentry].}
#'     \item{`abstract`}{Abstract of publication.}
#'     \item{`annotation`}{Annotation of publication.}
#'     \item{`annotation_src`}{Identifier for the annotation source publication
#'       (Knobel and others, 2005; Bartholomay, 2022).}
#'   }
#'
#' @source Many of these publications are available through the
#'   [USGS Publications Warehouse](https://pubs.usgs.gov/).
#'
#' @references Bartholomay, R.C., 2022, Historical development of the U.S. Geological Survey
#'   hydrological monitoring and investigative programs at the Idaho National Laboratory, Idaho, 2002-2020:
#'   U.S. Geological Survey Open-File Report 2022-1027 (DOE/ID-22256), 54 p., \doi{10.3133/ofr20221027}.
#' @references Knobel, L.L., Bartholomay, R.C., and Rousseau, J.P., 2005,
#'   Historical development of the U.S. Geological Survey hydrologic monitoring and investigative programs
#'   at the Idaho National Engineering and Environmental Laboratory, Idaho, 1949 to 2001:
#'   U.S. Geological Survey Open-File Report 2005--1223 (DOE/ID--22195), 93 p.,
#'   \doi{10.3133/ofr20051223}.
#'
#' @keywords datasets
#'
#' @examples
#' # Subset Fisher and others (2012) and display structure:
#' id <- "FisherOthers2012"
#' pub <- pubs[id, ]
#' str(pub, max.level = 3, width = 75, strict.width = "cut")
#'
#' # Print suggested citation:
#' attr(unclass(pub$bibentry[[1]])[[1]], which = "textVersion")
#'
#' # Print authors full name:
#' format(pub$bibentry[[1]]$author, include = c("given", "family"))
#'
#' # Print abstract:
#' pub$abstract

"pubs"
