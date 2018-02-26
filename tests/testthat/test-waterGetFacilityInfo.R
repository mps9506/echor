context("test-watergetfacilityInfo")

library(httptest)
library(here)

.mockPaths(here("tests/testthat/"))


#capture_requests({
#   echoWaterGetFacilityInfo(p_pid = "ALR040033", output = "df")
#   })


with_mock_api({
  test_that("waterGetFacilityInfo works", {
    x <- echoWaterGetFacilityInfo(p_pid = "ALR040033", output = "df")
    expect_equal(is.data.frame(x), TRUE)
    })
})
