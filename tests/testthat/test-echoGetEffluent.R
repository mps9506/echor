context("test-getEffluent")

library(httptest)
library(here)

.mockPaths(here("tests/testthat/"))

# capture_requests({
#    echoGetEffluent(p_id = "tx0119407", parameter_code = "50050")
#  })


with_mock_api({
  test_that("echoGetEffluent works", {
    x <- echoGetEffluent(p_id = "tx0119407", parameter_code = "50050")
    expect_equal(is.data.frame(x), TRUE)
  })
})
