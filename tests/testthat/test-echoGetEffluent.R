context("test-getEffluent")


test_that("echoGetEffluent works", {
  skip_on_cran()
  x <- echoGetEffluent(p_id = "tx0119407", parameter_code = "50050")
  expect_equal(is.data.frame(x), TRUE)
  })
