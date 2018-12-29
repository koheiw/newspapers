context("test import_factiva")

test_that("test that import_factiva works", {

    data1 <- import_factiva("../data/factiva/irish-independence_1_2017-11-14.html")
    expect_identical(nrow(data1), 44L)
    expect_true(all(data1$body != ""))
    expect_true(all(data1$title != ""))

    data2 <- import_factiva("../data/factiva/suddeutsche_1_2017-11-19.html")
    expect_identical(nrow(data2), 51L)
    expect_true(all(data2$body != ""))
    expect_true(all(data2$title != ""))

    data3 <- import_factiva("../data/factiva/chosun_ilbo_1_2018-05-28.html")
    expect_identical(nrow(data3), 59L)
    expect_true(all(data2$body != ""))
    expect_true(all(data2$title != ""))

})

test_that("test that import_factiva works with different language editions", {

    data1 <- import_factiva("../data/factiva/german-ui.html")
    expect_identical(nrow(data1), 100L)
    expect_true(all(data1$body != ""))
    expect_true(all(data1$title != ""))

    data2 <- import_factiva("../data/factiva/chinese-ui.html")
    expect_identical(nrow(data2), 97L)
    expect_true(all(data2$body != ""))
    expect_true(all(data2$title != ""))

})

test_that("test that highlighted words are preserved", {
    data <- import_factiva("../data/factiva/irish-independence_1_2017-11-14.html")
    expect_true(all(stringi::stri_detect_regex(data$body, "Dáil|speech|parliament|debate")))
})
