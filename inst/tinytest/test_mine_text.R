# setup tinytest for checkmate functionality
library("tinytest")
library("checkmate")
using("checkmate")

# test that all publications are accounted for
m <- mine_text(pubs, c("title", "abstract", "annotation", "citation"))
is <- rownames(pubs) %in% colnames(m)
all(is) |> expect_true()

# test that when all the text components are NA an empty table is returned
d <- pubs[is.na(pubs$annotation), ]
m <- mine_text(d, "annotation")
is <- nrow(m) == 0L
expect_true(is)
