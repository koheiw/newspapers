context("test import_factiva")

test_that("test that import_factiva works", {

    dat1 <- import_factiva("../data/factiva/irish-independence_1_2017-11-14.html")
    expect_identical(nrow(dat1), 44L)
    expect_true(all(dat1$body != ""))
    expect_true(all(dat1$head != ""))
    expect_true(all(!is.na(as.Date(stri_datetime_parse(dat1$date, 'd MMMM y', locale = 'en_EN')))))

    dat2 <- import_factiva("../data/factiva/suddeutsche_1_2017-11-19.html")
    expect_identical(nrow(dat2), 51L)
    expect_true(all(dat2$body != ""))
    expect_true(all(dat2$head != ""))
    expect_true(all(!is.na(as.Date(stri_datetime_parse(dat2$date, 'd MMMM y', locale = 'en_EN')))))

    dat3 <- import_factiva("../data/factiva/chosun_ilbo_1_2018-05-28.html")
    expect_identical(nrow(dat3), 59L)
    expect_true(all(dat3$body != ""))
    expect_true(all(dat3$head != ""))
    expect_true(all(!is.na(as.Date(stri_datetime_parse(dat3$date, 'd MMMM y', locale = 'en_EN')))))

    dat4 <- import_factiva("../data/factiva/nyt_1_1993-01-03.html")
    expect_identical(nrow(dat4), 27L)
    expect_true(all(dat4$body != ""))
    expect_true(all(dat4$head != ""))
    expect_true(all(!is.na(as.Date(stri_datetime_parse(dat4$date, 'd MMMM y', locale = 'de_DE')))))

})

test_that("test that import_factiva works with different language editions", {

    dat1 <- import_factiva("../data/factiva/german-ui.html")
    expect_identical(nrow(dat1), 100L)
    expect_true(all(dat1$body != ""))
    expect_true(all(dat1$head != ""))
    expect_true(all(!is.na(as.Date(stri_datetime_parse(dat1$date, 'd MMMM y', locale = 'de_DE')))))

    dat2 <- import_factiva("../data/factiva/chinese-ui.html")
    expect_identical(nrow(dat2), 97L)
    expect_true(all(dat2$body != ""))
    expect_true(all(dat2$head != ""))
    expect_true(all(!is.na(dat2$date)))
    expect_true(all(!is.na(as.Date(stri_datetime_parse(dat2$date, 'y 年 M 月 d 日')))))

})

test_that("test that highlighted words are preserved", {
    dat_all <- import_factiva("../data/factiva/irish-independence_1_2017-11-14.html")
    expect_true(all(stringi::stri_detect_regex(dat_all$body, "Dáil|speech|parliament|debate")))
})
