context("test-getEffluent")

library(httptest)
library(here)

.mockPaths(here("tests/testthat/"))

## Not sure if I need to include this in test_that(). Causes test to skip in the specified context.
# test_that("Record requests if online", {
#   capture_requests({
#     echoGetEffluent(p_id = "tx0119407", parameter_code = "50050")
#   })
#
# })

with_mock_api({
  test_that("echoGetEffluent works", {
    x <- echoGetEffluent(p_id = "tx0119407", parameter_code = "50050")
    expect_equal(is.data.frame(x), TRUE)
  })
})
