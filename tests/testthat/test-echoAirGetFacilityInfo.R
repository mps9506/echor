context("test-echoAirGetFacilityInfo")


test_that("echoAirGetFacilityInfo returns a df", {
  skip_on_cran()
  x <- echoAirGetFacilityInfo(p_pid = "NC0000003706500036", output = "df")
  expect_equal(is.data.frame(x), TRUE)

  x <- echoAirGetFacilityInfo(p_pid = "NC0000003706500036", output = "sf")
  expect_equal(is(x, "sf"), TRUE)
  })

test_that("echoAirGetFacilityInfo returns errors", {
  expect_error(echoAirGetFacilityInfo(), "No valid arguments supplied")
  expect_error(echoAirGetFacilityInfo(p_pid = "NC0000003706500036", output = "JSON", verbose = TRUE))
  })

test_that("echoAirGetFacilityInfo produces messages", {
  skip_on_cran()
  expect_message(echoAirGetFacilityInfo(p_pid = "NC0000003706500036", output = "df", verbose = TRUE))
  expect_message(echoAirGetFacilityInfo(p_pid = "NC0000003706500036", output = "sf", verbose = TRUE))
  })
