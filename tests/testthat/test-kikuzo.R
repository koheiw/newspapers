context("test import_kikuzo")

test_that("test that import_kikuzo works with HTML downloaded by a scraper", {


    data1 <- import_kikuzo("../data/kikuzo/asahi_1985-01-01_001.html")
    expect_identical(nrow(data1), 95L)
    expect_true(!any(is.na(data1$date)))
    expect_true(all(data1$body != ""))
    expect_true(all(data1$title != ""))

    data2 <- import_kikuzo("../data/kikuzo/asahi_1985-01-01_002.html")
    expect_identical(nrow(data2), 96L)
    expect_true(!any(is.na(data2$date)))
    expect_true(all(data2$body != ""))
    expect_true(all(data2$title != ""))

})


test_that("test that import_kikuzo works with HTML downloaded manually", {

    data <- import_kikuzo("../data/kikuzo/asahi_raw.html")
    expect_identical(nrow(data), 100L)
    expect_true(all(data$body != ""))
    expect_true(all(data$title != ""))
    expect_true(all(stringi::stri_detect_fixed(data$body, "一帯一路")))
})

test_that("test that highlighted words are preserved", {
    data <- import_kikuzo("../data/kikuzo/asahi_raw.html")
    expect_true(all(stringi::stri_detect_fixed(data$body, "一帯一路")))
})
