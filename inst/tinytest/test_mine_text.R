# setup tinytest for checkmate functionality
library("tinytest")
library("checkmate")
using("checkmate")

# test that 3-grams result in 3 word tokens, requires JAVA system dependency
if (test_directory_exists(Sys.getenv("JAVA_HOME"), access = "r")) {
  d <- mine_text(docs = pubs$title, ngmin = 3L)
  nwords <- as.character(d$term) |>
    strsplit(" ") |>
    vapply(FUN = length, FUN.VALUE = integer(1))
  all(nwords == 3L) |> expect_true()
}
