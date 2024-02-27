# Function that takes author identifiers and returns author entries

get_person <- function(x, persons) {

  # check arguments
  checkmate::assert_character(x, any.missing = FALSE, unique = TRUE, .var.name = "get_person")
  checkmate::assert_class(persons, classes = "person")

  is <- !(x %in% names(persons))
  if (any(is)) {
    txt <- x[is] |> sQuote(q = FALSE) |> paste(collapse = ",")
    stop("Missing entry for author identifier(s): ", txt, call. = FALSE)
  }

  persons[x]
}
