context("test-echoWaterGetParams")

library(httptest)
library(here)

.mockPaths(here("tests/testthat/"))

# capture_requests({
#   echoWaterGetParams(term = "Oxygen, dissolved")
#   echoWaterGetParams(code = "00300")
#   })


with_mock_api({
  test_that("echoWaterGetParams works", {
    x <- echoWaterGetParams(term = "Oxygen, dissolved")
    expect_equal(is.data.frame(x), TRUE)

    x <- echoWaterGetParams(code = "00300")
    expect_equal(is.data.frame(x), TRUE)

    expect_error(echoWaterGetParams(term = "Oxygen, dissolved", code = "00300"))

    expect_error(echoWaterGetParams())
  })
})
