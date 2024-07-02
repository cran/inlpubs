# setup tinytest for checkmate functionality
library("tinytest")
library("checkmate")
using("checkmate")

# test for missing annotation sources
is <- pubs$annotation_src[!is.na(pubs$annotation)] |> anyNA()
expect_false(is)
