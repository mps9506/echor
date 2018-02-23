context("test-getEffluent")

library(httptest)
library(here)

.mockPaths(here("tests/testthat/"))


test_that("Record requests if online", {
  skip_on_cran()
  skip_if_disconnected()

  capture_requests({
    echoGetEffluent(p_id = "tx0119407", parameter_code = "50050")
  })

})

with_mock_api({
  test_that("echoGetEffluent works", {
    x <- echoGetEffluent(p_id = "tx0119407", parameter_code = "50050")
    expect_equal(is.tibble(x), TRUE)
  })
})
