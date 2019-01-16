context("core functions return expected objects")

test_that("core functions return tbl_df", {

  skip_on_cran()

  expect_is(echoAirGetFacilityInfo(p_pid = "NC0000003706500036", output = "df",
                                         qcolumns = "3,4,5"), "tbl_df")

  expect_is(echoSDWGetMeta(verbose = FALSE), "tbl_df")

  expect_is(echoGetCAAPR(p_id = '110000350174'), "tbl_df")

  expect_is(echoGetEffluent(p_id = "tx0119407", parameter_code = "50050"),
                  "tbl_df")

  expect_is(echoGetEffluentSummary(p_id = "tx0119407", parameter_code = "50050"),
            "tbl_df")

  expect_is(echoGetReports(program = "caa",
                                 p_id = '110000350174',
                                 verbose = FALSE),
                  "tbl_df")

  expect_is(echoGetReports(program = "cwa",
                                 p_id = "tx0119407",
                                 parameter_code = "50050",
                                 verbose = FALSE),
                  "tbl_df")

  expect_is(echoSDWGetSystems(p_co = "Brazos", p_st = "tx", verbose = FALSE),
                  "tbl_df")

  expect_is(echoWaterGetFacilityInfo(p_pid = "ALR040033", output = "df",
                                           qcolumns = "3,4,5"),
                  "tbl_df")

  expect_is(echoWaterGetParams(term = "Oxygen, dissolved"),
                  "tbl_df")

  expect_is(echoWaterGetParams(code = "00300"), "tbl_df")

  expect_is(echoGetFacilities(program = "cwa", p_pid = "ALR040033", output = "df",
                                    qcolumns = "1,2,3"), "tbl_df")

})

test_that("core functions return sf", {

  skip_on_cran()

  expect_is(echoAirGetFacilityInfo(p_pid = "NC0000003706500036", output = "sf", verbose = FALSE),
                  "sf")

  expect_is(echoWaterGetFacilityInfo(p_pid = "ALR040033", output = "sf"),
                  "sf")

})
