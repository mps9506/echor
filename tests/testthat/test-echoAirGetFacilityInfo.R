context("test-echoAirGetFacilityInfo")

library(httptest)
library(here)

.mockPaths(here("tests/testthat/"))


# test_that("Record requests if online", {
#   capture_requests({
#   echoAirGetFacilityInfo(p_pid = "NC0000003706500036", output = "df")
#   })
#
# })

with_mock_api({
  test_that("echoAirGetFacilityInfo works", {
    x <- echoAirGetFacilityInfo(p_pid = "NC0000003706500036", output = "df")
    expect_equal(is.data.frame(x), TRUE)

    expect_error(echoAirGetFacilityInfo(), "No valid arguments supplied")

    expect_message(echoAirGetFacilityInfo(p_pid = "NC0000003706500036", output = "df", verbose = TRUE))

    expect_error(echoAirGetFacilityInfo(p_pid = "NC0000003706500036", output = "JSON", verbose = TRUE))
  })
})



# capture_requests({
#   echoAirGetFacilityInfo(p_pid = "NC0000003706500036", output = "sf")
#   })

with_mock_api({
  test_that("echoWaterGetFacilityInfo sf works", {
    x <- echoAirGetFacilityInfo(p_pid = "NC0000003706500036", output = "sf")

    expect_equal(is(x, "sf"), TRUE)

    expect_message(echoAirGetFacilityInfo(p_pid = "NC0000003706500036", output = "sf", verbose = TRUE))
  })
})
