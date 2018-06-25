context("test-echoGetCAAPR")


test_that("echoGetCAAPR returns dataframe", {
  skip_on_cran()
  x <- echoGetCAAPR(p_id = '110000350174')
  expect_equal(is.data.frame(x), TRUE)
  })

