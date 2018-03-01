context("test-echoAirGetFacilityInfo")

library(httptest)
library(here)

.mockPaths(here("tests/testthat/"))


# test_that("Record requests if online", {
#   capture_requests({
#   echoAirGetFacilityInfo(p_pid = "NC0000003706500036", output = "JSON")
#   })
#
# })

with_mock_api({
  test_that("echoAirGetFacilityInfo works", {
    x <- echoAirGetFacilityInfo(p_pid = "NC0000003706500036", output = "df")
    expect_equal(is.data.frame(x), TRUE)
  })
})
