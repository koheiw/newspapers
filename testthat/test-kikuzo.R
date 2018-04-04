test_that("test that import_kikuzo works with HTML downloaded by a scraper", {


    data1 <- import_kikuzo('data/kikuzo_1985-01-01_001.html')
    expect_identical(nrow(data1), 95L)
    expect_true(all(data1$body != ''))
    expect_true(all(data1$title != ''))

    data2 <- import_kikuzo('data/kikuzo_1985-01-01_002.html')
    expect_identical(nrow(data2), 96L)
    expect_true(all(data2$body != ''))
    expect_true(all(data2$title != ''))

})


test_that("test that import_kikuzo works with HTML downloaded manually", {

    data <- import_kikuzo('data/kikuzo_raw.html')
    expect_identical(nrow(data), 100L)
    expect_true(all(data$body != ''))
    expect_true(all(data$title != ''))

})
