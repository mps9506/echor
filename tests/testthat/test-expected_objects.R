context("core functions return expected objects")

test_that("core functions return tbl_df", {

  skip_on_cran()

  x <- echoAirGetFacilityInfo(p_pid = "NC0000003706500036", output = "df",
                              qcolumns = "3,4,5")
  expect_s3_class(x, "tbl_df")

  x <- echoSDWGetMeta(verbose = FALSE)
  expect_s3_class(x, "tbl_df")

  x <- echoGetCAAPR(p_id = '110000350174')
  expect_s3_class(x, "tbl_df")

  x <- echoGetEffluent(p_id = "tx0119407", parameter_code = "50050")
  expect_s3_class(x, "tbl_df")

  x <- echoGetReports(program = "caa",
                      p_id = '110000350174',
                      verbose = FALSE)
  expect_s3_class(x, "tbl_df")

  x <- echoGetReports(program = "cwa",
                      p_id = "tx0119407",
                      parameter_code = "50050",
                      verbose = FALSE)
  expect_s3_class(x, "tbl_df")

  x <- echoSDWGetSystems(p_co = "Brazos", p_st = "tx", verbose = FALSE)
  expect_s3_class(x, "tbl_df")

  x <- echoWaterGetFacilityInfo(p_pid = "ALR040033", output = "df",
                                qcolumns = "3,4,5")
  expect_s3_class(x, "tbl_df")

  x <- echoWaterGetParams(term = "Oxygen, dissolved")
  expect_s3_class(x, "tbl_df")

  x <- echoWaterGetParams(code = "00300")
  expect_s3_class(x, "tbl_df")

  x <- echoGetFacilities(program = "cwa", p_pid = "ALR040033", output = "df",
                         qcolumns = "1,2,3")
  expect_s3_class(x, "tbl_df")

})

test_that("core functions return sf", {

  skip_on_cran()

  x <- echoAirGetFacilityInfo(p_pid = "NC0000003706500036", output = "sf", verbose = FALSE)
  expect_s3_class(x, "sf")

  x <- echoWaterGetFacilityInfo(p_pid = "ALR040033", output = "sf")
  expect_s3_class(x, "sf")

})
