context("test-echoGetCAAPR")

library(httptest)
library(here)

.mockPaths(here("tests/testthat/"))

## Not sure if I need to include this in test_that(). Causes test to skip in the specified context.

# capture_requests({
#     echoGetCAAPR(p_id = '110000350174')
#   })


with_mock_api({
  test_that("echoGetCAAPR works", {
    x <- echoGetCAAPR(p_id = '110000350174')
    expect_equal(is.data.frame(x), TRUE)
  })
})
