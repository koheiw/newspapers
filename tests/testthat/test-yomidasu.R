context("test import_yomidasu")

test_that("test that import_yomidasu works with HTML downloaded by a scraper", {


    dat1 <- import_yomidasu("../data/yomidasu/yomidasu_1987-01-01_001.html")
    expect_identical(nrow(dat1), 78L)
    expect_true(!any(is.na(dat1$date)))
    expect_true(sum(dat1$body != "") == 70L)
    expect_true(sum(dat1$title != "") == 0L)

    dat2 <- import_yomidasu("../data/yomidasu/yomidasu_2018-01-01_001.html")
    expect_identical(nrow(dat2), 27L)
    expect_true(!any(is.na(dat2$date)))
    expect_true(all(dat2$body != ""))
    expect_true(all(dat2$title != ""))

})

