context("test utils")

test_that("test that check_gaps works", {

    d <- seq(as.Date("2019-01-31"), as.Date("2019-12-31"), by = "1 day")
    dat <- data.frame(date = sample(d, 10000, replace = TRUE))

    dat_gap7 <- subset(dat, date < as.Date("2019-04-01") | as.Date("2019-04-07") < date)
    expect_warning(check_gaps(dat_gap7, size = 3), "3-day gaps after 2019-03-31")
    expect_warning(check_gaps(dat_gap7, size = 7), "7-day gaps after 2019-03-31")
    expect_silent(check_gaps(dat_gap7, size = 14))

    dat_gap14 <- subset(dat, date < as.Date("2019-09-01") | as.Date("2019-09-14") < date)
    expect_warning(check_gaps(dat_gap14, size = 14), "14-day gaps after 2019-08-31")
})
