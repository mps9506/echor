context("test-echoGetFacilities")

test_that("echoGetFacilities returns a dataframe", {
  skip_on_cran()
  Sys.sleep(5)
  x <- echoGetFacilities(program = "cwa", p_pid = "ALR040033", output = "df", verbose = TRUE, qcolumns = "1,2,3")
  expect_equal(is.data.frame(x), TRUE)

  #x <- echoGetFacilities(program = "caa", p_pid = "NC0000003706500036", output = "df", verbose = FALSE, qcolumns = "1,2,3")
  #expect_equal(is.data.frame(x), TRUE)

  #x <- echoGetFacilities(program = "sdw", p_co = "Brazos", p_st = "tx", verbose = FALSE, qcolumns = "1,2,3")
  #expect_equal(is.data.frame(x), TRUE)
})

test_that("echoGetFacilities returns error when specifying sf for sdw program", {
  expect_error(echoGetFacilities(program = "sdw", p_co = "Brazos", p_st = "tx", verbose = FALSE, output = "sf"))
})

test_that("echoGetFacilities returns error if wrong program is entered", {
  expect_error(echoGetFacilities(program = "abc"))
})
