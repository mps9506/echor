library(httptest)
context("test-watergetfacilityInfo")



test_that("Record requests if online", {
  skip_if_disconnected()

  capture_requests(verbose = TRUE, {
  echoWaterGetFacilityInfo(p_pid = "ALR040033", output = "JSON")
  })

})

with_mock_api({
  test_that("waterGetFacilityInfo works", {
    x <- echoWaterGetFacilityInfo(p_pid = "ALR040033", output = "JSON")
    #print(x)
    })
})
