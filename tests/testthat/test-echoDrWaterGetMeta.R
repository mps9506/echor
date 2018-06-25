context("test-echoSDWGetMeta")

test_that("echoSDWGetMeta returns dataframe", {
  skip_on_cran()

  x <- echoSDWGetMeta(verbose = FALSE)
  expect_equal(is.data.frame(x), TRUE)


  expect_message(echoSDWGetMeta(verbose = TRUE))
})
