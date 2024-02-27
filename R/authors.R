#' Contributing Authors to INLPO Publications
#'
#' @description Authors who have contributed to the publications by the U.S. Geological Survey (USGS),
#'   Idaho Water Science Center, Idaho National Laboratory Project Office (INLPO).
#'
#' @format An object of class 'author' that inherits behavior from the 'data.frame' class
#'   and includes the following columns:
#'   \describe{
#'     \item{`author_id`}{Unique identifier for the author.}
#'     \item{`name`}{Name of author, surname first and initials or given name.}
#'     \item{`person`}{Information about the [person][utils::person]
#'       like email address and [ORCiD](https://orcid.org/) identifier.}
#'     \item{`pub_id`}{Identifier(s) of the publication(s) the author has contributed to,
#'       referes to the primry key of the [`pubs`] data table.}
#'     \item{`total_pub`}{Total number of publications.}
#'     \item{`single_authored`}{Number of single-authored publications.}
#'     \item{`multi_authored`}{Number of multi-authored publications.}
#'     \item{`first_authored`}{Number of multi-authored publications where the researcher appears as first author.}
#'     \item{`first_year`}{First year author published.}
#'     \item{`last_year`}{Last year author published.}
#'   }
#'
#' @source Curated by INLPO staff.
#'
#' @keywords datasets
#'
#' @examples
#' # Subset Jason Fisher's information and display structure:
#' author <- authors["jfisher", ]
#' str(author, max.level = 3, width = 75, strict.width = "cut")
#'
#' # Print author's given name:
#' author$person |> format(include = "given")

"authors"
