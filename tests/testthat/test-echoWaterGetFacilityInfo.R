context("test-echoWatergetfacilityInfo")

test_that("echoWaterGetFacilityInfo returns df", {
  skip_on_cran()
  x <- echoWaterGetFacilityInfo(p_pid = "ALR040033", output = "df")
  expect_equal(is.data.frame(x), TRUE)
  })

test_that("echoWaterGetFacilityInfo returns errors",{
  expect_error(echoWaterGetFacilityInfo(), "No valid arguments supplied")
  expect_error(echoWaterGetFacilityInfo(p_pid = "ALR040033", output = "JSON"))
})

test_that("echoWaterGetFacilityInfo returns messages", {
  skip_on_cran()
  expect_message(echoWaterGetFacilityInfo(p_pid = "ALR040033", output = "df", verbose = TRUE))
  expect_message(echoWaterGetFacilityInfo(p_pid = "ALR040033", output = "sf", verbose = TRUE))
})

test_that("echoWaterGetFacilityInfo returns sf", {
  skip_on_cran()
  x <- echoWaterGetFacilityInfo(p_pid = "ALR040033", output = "sf")
  expect_equal(is(x, "sf"), TRUE)
})
