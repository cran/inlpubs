
#' Get Person(s)
#'
#' @description Filter a list of individuals based on their distinct identifiers.
#'
#' @param x 'character' vector.
#'   Identifier for one or more persons.
#' @param persons 'person' named list.
#'   Information about an arbitrary number of persons.
#'   Each element in the list is assigned a name, which uniquely identifies a person.
#'
#' @return A subset of `persons`.
#'
#' @author J.C. Fisher, U.S. Geological Survey, Idaho Water Science Center
#'
#' @export
#'
#' @keywords internal
#'
#' @examples
#' get_person("jfisher", persons = inlpubs::authors$person)

get_person <- function(x, persons) {
  checkmate::assert_character(x, any.missing = FALSE, unique = TRUE, .var.name = "get_person")
  checkmate::assert_class(persons, classes = "person")
  is <- !(x %in% names(persons))
  if (any(is)) {
    txt <- x[is] |> sQuote(q = FALSE) |> paste(collapse = ",")
    stop("Missing entry for author identifier(s): ", txt, call. = FALSE)
  }
  persons[x]
}
