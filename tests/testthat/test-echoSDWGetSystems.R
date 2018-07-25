context("test-echoSDWGetSystems")

test_that("echoSDWGetSystems returns dataframe", {
  skip_on_cran()

  x <- echoSDWGetSystems(p_co = "Brazos", p_st = "tx", verbose = FALSE)
  expect_s3_class(x, "tbl_df")
  })

test_that("echoSDWGetSystems returns errors", {
  expect_error(echoSDWGetSystems())
  })


test_that("echoSDWGetSystems returns messages", {
  skip_on_cran()
  expect_message(echoSDWGetSystems(p_co = "Brazos", p_st = "tx", verbose = TRUE))
  })
