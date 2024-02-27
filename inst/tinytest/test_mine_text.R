# setup tinytest for checkmate functionality
library("tinytest")
library("checkmate")
using("checkmate")

# test that all publications are accounted for
m <- mine_text(pubs, components = c("title", "abstract", "annotation", "citation"))
is <- rownames(pubs) %in% colnames(m)
all(is) |> expect_true()

# test that when all the text components are NA an empty table is returned
is <- is.na(pubs$annotation)
m <- mine_text(pubs[is, ], components = "annotation")
expect_true(nrow(m) == 0L)

# test that 3-grams result in 3 word tokens, requires JAVA system dependency
is <- Sys.getenv("JAVA_HOME") |> test_directory_exists(access = "r")
if (is) {
  m <- mine_text(pubs, components = "title", ngmin = 3L)
  nwords <- rownames(m) |>
    strsplit(" ") |>
    vapply(FUN = length, FUN.VALUE = integer(1))
  all(nwords == 3L) |>
    expect_true()
}
