context("test import_nexis")

test_that("test that import_nexis works with Nexis UK", {

    data1 <- import_nexis('../data/nexis/irish-times_1995-06-12_0001.html')
    expect_identical(nrow(data1), 166L)
    expect_true(all(data1$body != ""))
    expect_true(all(data1$title != ""))

    data2 <- import_nexis('../data/nexis/guardian_1986-01-01_0001.html')
    expect_identical(nrow(data2), 262L)
    expect_true(all(data2$body != ""))
    expect_true(all(data2$title != ""))

    data3 <- import_nexis('../data/nexis/spiegel_2012-02-01_0001.html', language_date = 'german')
    expect_identical(nrow(data3), 49L)
    expect_true(all(data3$body != ""))
    expect_true(all(data3$title != ""))

    data4 <- import_nexis('../data/nexis/afp_2013-03-12_0501.html')
    expect_identical(nrow(data4), 74L)
    expect_true(all(data4$body != ""))
    expect_true(all(data4$title != ""))

    data5 <- import_nexis('../data/nexis', raw_date = TRUE)
    expect_identical(nrow(data5), 166L + 262L + 49L + 74L)
    expect_true(all(data5$body != ""))
    expect_true(all(data5$title != ""))

})


test_that("test that import_nexis works with Nexis Advance", {

    data1 <- import_nexis('../data/nexis/nyt.docx', variant = "advance")
    expect_identical(nrow(data1), 50L)
    expect_true(all(data1$body != ""))
    expect_true(all(data1$title != ""))

    data2 <- import_nexis('../data/nexis/washington-post.docx', variant = "advance")
    expect_identical(nrow(data2), 50L)
    expect_true(all(data2$body != ""))
    expect_true(all(data2$title != ""))

    data3 <- import_nexis('../data/nexis/usa-today.docx', variant = "advance")
    expect_identical(nrow(data3), 7L)
    expect_true(all(data3$body != ""))
    expect_true(all(data3$title != ""))

    data4 <- import_nexis('../data/nexis/', variant = "advance")
    expect_identical(nrow(data4), 50L + 50L + 7L)
    expect_true(all(data4$body != ""))
    expect_true(all(data4$title != ""))

})
