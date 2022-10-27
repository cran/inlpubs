# test that all publications are accounted for
m <- mine_text(pubs, c("title", "abstract", "annotation", "citation"))
expect_true(all(rownames(pubs) %in% colnames(m)))


# test that when all the text components are NA an empty table is returned", {
d <- pubs[is.na(pubs$annotation), ]
m <- mine_text(d, "annotation")
expect_true(nrow(m) == 0L)
