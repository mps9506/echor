context("test-echoWatergetfacilityInfo")

library(httptest)
library(here)

.mockPaths(here("tests/testthat/"))


# capture_requests({
#   echoWaterGetFacilityInfo(p_pid = "ALR040033", output = "df")
#   })


with_mock_api({
  test_that("echoWaterGetFacilityInfo df works", {
    x <- echoWaterGetFacilityInfo(p_pid = "ALR040033", output = "df")
    expect_equal(is.data.frame(x), TRUE)

    expect_error(echoWaterGetFacilityInfo(), "No valid arguments supplied")

    expect_message(echoWaterGetFacilityInfo(p_pid = "ALR040033", output = "df", verbose = TRUE))

    expect_error(echoWaterGetFacilityInfo(p_pid = "ALR040033", output = "JSON"))
    })
})


# capture_requests({
#   echoWaterGetFacilityInfo(p_pid = "ALR040033", output = "sf")
#   })

with_mock_api({
  test_that("echoWaterGetFacilityInfo sf works", {
    x <- echoWaterGetFacilityInfo(p_pid = "ALR040033", output = "sf")

    expect_equal(is(x, "sf"), TRUE)

    expect_message(echoWaterGetFacilityInfo(p_pid = "ALR040033", output = "sf", verbose = TRUE))
  })
})
