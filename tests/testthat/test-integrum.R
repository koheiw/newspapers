context("test import_integrum")

test_that("test that import_integrum works with XLSX", {

    dat1 <- import_integrum("../data/integrum/channel1_20050201-20050228_0001-0059_0059.xlsx")
    expect_identical(nrow(dat1), 59L)
    expect_true(all(dat1$body != ""))
    expect_true(all(dat1$head != ""))

    dat2 <- import_integrum("../data/integrum/ntv_20121201-20121231_0001-0100_0190.xlsx")
    expect_identical(nrow(dat2), 100L)
    expect_true(all(dat2$body != ""))
    expect_true(all(dat2$head != ""))

})

test_that("test that import_integrum works with HTML", {

    dat1 <- import_integrum("../data/integrum/moscow_1993-06-06_1994-09-02.html")
    expect_identical(nrow(dat1), 27L)
    expect_true(all(dat1$body != ""))
    expect_true(all(dat1$head != ""))

    # dat2 <- import_integrum("../data/integrum/ntv_20121201-20121231_0001-0100_0190.xlsx")
    # expect_identical(nrow(dat2), 100L)
    # expect_true(all(dat2$body != ""))
    # expect_true(all(dat2$head != ""))

})
