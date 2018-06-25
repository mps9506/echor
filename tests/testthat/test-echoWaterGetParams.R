context("test-echoWaterGetParams")

test_that("echoWaterGetParams returns dataframe", {
  skip_on_cran()
  x <- echoWaterGetParams(term = "Oxygen, dissolved")
  expect_equal(is.data.frame(x), TRUE)

  x <- echoWaterGetParams(code = "00300")
  expect_equal(is.data.frame(x), TRUE)

  })

test_that("echoWaterGetParams returns errors", {
  skip_on_cran()
  expect_error(echoWaterGetParams(term = "Oxygen, dissolved", code = "00300"))
  expect_error(echoWaterGetParams())
  })

test_that("echoWaterGetParams returns messages", {
  expect_message(echoWaterGetParams(code = "00300", verbose = TRUE))
  })
