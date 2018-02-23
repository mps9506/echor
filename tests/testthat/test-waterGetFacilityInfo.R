context("test-watergetfacilityInfo")

library(httptest)
library(here)

.mockPaths(here("tests/testthat/"))


test_that("Record requests if online", {
  skip_on_cran()
  skip_if_disconnected()

  capture_requests({
  echoWaterGetFacilityInfo(p_pid = "ALR040033", output = "JSON")
  })

})

with_mock_api({
  test_that("waterGetFacilityInfo works", {
    x <- echoWaterGetFacilityInfo(p_pid = "ALR040033", output = "JSON")
    expect_equal(is.data.frame(x), TRUE)
    })
})
