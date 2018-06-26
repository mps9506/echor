context("test-echoGetReports")

test_that("echoGetReports returns a dataframe", {
  skip_on_cran()

  x <- echoGetReports(program = "caa",
                      p_id = '110000350174',
                      verbose = FALSE)
  expect_equal(is.data.frame(x), TRUE)

  x <- echoGetReports(program = "cwa",
                      p_id = "tx0119407",
                      parameter_code = "50050",
                      verbose = FALSE)
  expect_equal(is.data.frame(x), TRUE)

})

test_that("echoGetReports returns errors",{
  expect_error(echoGetReports(program = "sdw"))
})
