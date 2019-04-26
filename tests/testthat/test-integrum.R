context("test import_integrum")

test_that("test that import_integrum works", {

    dat1 <- import_integrum("../data/integrum/channel1_20050201-20050228_0001-0059_0059.xlsx")
    expect_identical(nrow(dat1), 59L)
    expect_true(all(dat1$body != ""))
    expect_true(all(dat1$title != ""))

    dat2 <- import_integrum("../data/integrum/ntv_20121201-20121231_0001-0100_0190.xlsx")
    expect_identical(nrow(dat2), 100L)
    expect_true(all(dat2$body != ""))
    expect_true(all(dat2$title != ""))

})
