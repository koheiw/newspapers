context("test import_kikuzo")

test_that("test that import_kikuzo works with HTML downloaded by a scraper", {


    dat1 <- import_kikuzo("../data/kikuzo/kikuzo_1985-01-01_001.html")
    expect_identical(nrow(dat1), 95L)
    expect_true(!any(is.na(dat1$date)))
    expect_true(all(dat1$body != ""))
    expect_true(all(dat1$head != ""))

    dat2 <- import_kikuzo("../data/kikuzo/kikuzo_1985-01-01_002.html")
    expect_identical(nrow(dat2), 96L)
    expect_true(!any(is.na(dat2$date)))
    expect_true(all(dat2$body != ""))
    expect_true(all(dat2$head != ""))

})


test_that("test that import_kikuzo works with HTML downloaded manually", {

    dat <- import_kikuzo("../data/kikuzo/kikuzo_raw.html")
    expect_identical(nrow(dat), 100L)
    expect_true(all(dat$body != ""))
    expect_true(all(dat$head != ""))
    expect_true(all(stringi::stri_detect_fixed(dat$body, "一帯一路")))
})

test_that("test that highlighted words are preserved", {
    dat <- import_kikuzo("../data/kikuzo/kikuzo_raw.html")
    expect_true(all(stringi::stri_detect_fixed(dat$body, "一帯一路")))
})
