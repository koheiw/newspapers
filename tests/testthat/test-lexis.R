context("test import_lexis")

test_that("test that import_lexis works with lexis Advance", {

    dat1 <- import_lexis('../data/lexis/nyt1.docx', variant = "advance")
    expect_identical(nrow(dat1), 50L)
    expect_true(all(dat1$body != ""))
    expect_true(all(dat1$head != ""))

    dat2 <- import_lexis('../data/lexis/washington-post.docx', variant = "advance")
    expect_identical(nrow(dat2), 50L)
    expect_true(all(dat2$body != ""))
    expect_true(all(dat2$head != ""))

    dat3 <- import_lexis('../data/lexis/usa-today.docx', variant = "advance")
    expect_identical(nrow(dat3), 7L)
    expect_true(all(dat3$body != ""))
    expect_true(all(dat3$head != ""))

    dat4 <- import_lexis('../data/lexis/misc.docx', variant = "advance")
    expect_identical(nrow(dat4), 100L)
    expect_true(all(dat4$body != ""))
    expect_true(all(dat4$head != ""))

    dat5 <- import_lexis('../data/lexis/nyt2.docx', variant = "advance")
    expect_identical(nrow(dat5), 100L)
    expect_true(all(dat5$body != ""))
    expect_true(all(dat5$head != ""))

    dat6 <- import_lexis('../data/lexis/guardian1.docx', variant = "advance")
    expect_identical(nrow(dat6), 2L)
    expect_true(all(dat6$body != ""))
    expect_true(all(dat6$head != ""))
    expect_false(any(stri_detect_fixed(dat6$dat6, "guardian")))

    dat7 <- import_lexis('../data/lexis/guardian2.docx', variant = "advance")
    expect_identical(nrow(dat7), 1L)
    expect_true(all(dat7$body != ""))
    expect_true(all(dat7$head != ""))
    expect_false(any(stri_detect_fixed(dat7$date, "guardian")))

    dat8 <- import_lexis('../data/lexis/guardian3.docx', variant = "advance")
    expect_identical(nrow(dat8), 62L)
    expect_true(all(dat8$body != ""))
    expect_true(all(dat8$head != ""))
    expect_false(any(stri_detect_fixed(dat8$date, "guardian")))

    dat_all <- import_lexis('../data/lexis', variant = "advance")
    expect_identical(nrow(dat_all), 50L + 50L + 7L + 100L + 100L + 2L + 1L + 62L)
    expect_true(all(dat_all$body != ""))
    expect_true(all(dat_all$head != ""))

})
