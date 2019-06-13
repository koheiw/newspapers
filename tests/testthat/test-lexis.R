context("test import_lexis")

test_that("test that import_lexis works with lexis Advance", {

    dat1 <- import_lexis('../data/lexis/nyt.docx', variant = "advance")
    expect_identical(nrow(dat1), 50L)
    expect_true(all(dat1$body != ""))
    expect_true(all(dat1$title != ""))

    dat2 <- import_lexis('../data/lexis/washington-post.docx', variant = "advance")
    expect_identical(nrow(dat2), 50L)
    expect_true(all(dat2$body != ""))
    expect_true(all(dat2$title != ""))

    dat3 <- import_lexis('../data/lexis/usa-today.docx', variant = "advance")
    expect_identical(nrow(dat3), 7L)
    expect_true(all(dat3$body != ""))
    expect_true(all(dat3$title != ""))

    dat4 <- import_lexis('../data/lexis/misc.docx', variant = "advance")
    expect_identical(nrow(dat4), 100L)
    expect_true(all(dat4$body != ""))
    expect_true(all(dat4$title != ""))

    dat5 <- import_lexis('../data/lexis/nyt2.docx', variant = "advance")
    expect_identical(nrow(dat5), 100L)
    expect_true(all(dat5$body != ""))
    expect_true(all(dat5$title != ""))

    dat_all <- import_lexis('../data/lexis', variant = "advance")
    expect_identical(nrow(dat_all), 50L + 50L + 7L + 100L + 100L)
    expect_true(all(dat_all$body != ""))
    expect_true(all(dat_all$title != ""))

})
