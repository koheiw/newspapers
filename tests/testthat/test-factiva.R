context("test import_factiva")

test_that("test that import_factiva works", {

    dat1 <- import_factiva("../data/factiva/irish-independence_1_2017-11-14.html")
    expect_identical(nrow(dat1), 44L)
    expect_true(all(dat1$body != ""))
    expect_true(all(dat1$head != ""))
    expect_true(all(!is.na(dat1$date)))

    dat2 <- import_factiva("../data/factiva/suddeutsche_1_2017-11-19.html")
    expect_identical(nrow(dat2), 51L)
    expect_true(all(dat2$body != ""))
    expect_true(all(dat2$head != ""))
    expect_true(all(!is.na(dat2$date)))

    dat3 <- import_factiva("../data/factiva/chosun_ilbo_1_2018-05-28.html")
    expect_identical(nrow(dat3), 59L)
    expect_true(all(dat2$body != ""))
    expect_true(all(dat2$head != ""))
    expect_true(all(!is.na(dat3$date)))

    dat4 <- import_factiva("../data/factiva/nyt_1_1993-01-03.html")
    expect_identical(nrow(dat4), 27L)
    expect_true(all(dat4$body != ""))
    expect_true(all(dat4$head != ""))
    expect_true(all(!is.na(dat4$date)))

})

test_that("test that import_factiva works with different language editions", {

    dat1 <- import_factiva("../data/factiva/german-ui.html")
    expect_identical(nrow(dat1), 100L)
    expect_true(all(dat1$body != ""))
    expect_true(all(dat1$head != ""))
    expect_true(all(!is.na(dat1$date)))

    dat2 <- import_factiva("../data/factiva/chinese-ui.html")
    expect_identical(nrow(dat2), 97L)
    expect_true(all(dat2$body != ""))
    expect_true(all(dat2$head != ""))
    expect_true(all(!is.na(dat2$date)))

})

test_that("test that highlighted words are preserved", {
    dat_all <- import_factiva("../data/factiva/irish-independence_1_2017-11-14.html")
    expect_true(all(stringi::stri_detect_regex(dat_all$body, "Dáil|speech|parliament|debate")))
})
