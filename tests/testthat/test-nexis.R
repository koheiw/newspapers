    context("test import_nexis")

test_that("test that import_nexis works with Nexis UK", {

    dat1 <- import_nexis('../data/nexis/irish-times_1995-06-12_0001.html')
    expect_identical(nrow(dat1), 166L)
    expect_true(all(dat1$body != ""))
    expect_true(all(dat1$head != ""))

    dat2 <- import_nexis('../data/nexis/guardian_1986-01-01_0001.html')
    expect_identical(nrow(dat2), 262L)
    expect_true(all(dat2$body != ""))
    expect_true(all(dat2$head != ""))

    dat3 <- import_nexis('../data/nexis/spiegel_2012-02-01_0001.html')
    expect_identical(nrow(dat3), 49L)
    expect_true(all(dat3$body != ""))
    expect_true(all(dat3$head != ""))

    dat4 <- import_nexis('../data/nexis/afp_2013-03-12_0501.html')
    expect_identical(nrow(dat4), 74L)
    expect_true(all(dat4$body != ""))
    expect_true(all(dat4$head != ""))

    dat_all <- import_nexis('../data/nexis')
    expect_identical(nrow(dat_all), 166L + 262L + 49L + 74L)
    expect_true(all(dat_all$body != ""))
    expect_true(all(dat_all$head != ""))

})

