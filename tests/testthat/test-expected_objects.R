context("core functions return expected objects")


api_root <- "https://echodata.epa.gov/echo/"
set_redactor(function (response) {
  response %>%
    gsub_response(api_root, "api/", fixed = TRUE)
})
set_requester(function (request) {
  request %>%
    gsub_request(api_root, "api/", fixed = TRUE)
})

#with_mock_api <- capture_requests

with_mock_api({
  ## this has to skip if offline because the functions
  ## return NULL when offline, but these functions may or may
  ## not be compared against mocked responses

  test_that("core functions return tbl_df", {
    skip_if_offline(host = "echodata.epa.gov")

    expect_s3_class(
      echoAirGetFacilityInfo(
        p_pid = "NC0000003706500036",
        output = "df",
        qcolumns = "3,4,5"
      ),
      "tbl_df"
    )

    expect_s3_class(echoSDWGetMeta(verbose = FALSE),
              "tbl_df")

    expect_s3_class(echoGetCAAPR(p_id = '110000350174'),
              "tbl_df")

    expect_s3_class(echoGetEffluent(p_id = "tx0124362",
                              parameter_code = "50050"),
              "tbl_df")

    expect_s3_class(echoGetReports(
      program = "caa",
      p_id = '110000350174',
      verbose = FALSE
    ),
    "tbl_df")

    expect_s3_class(
      echoGetReports(
        program = "cwa",
        p_id = "tx0124362",
        parameter_code = "50050",
        verbose = FALSE
      ),
      "tbl_df"
    )

    expect_s3_class(echoSDWGetSystems(
      p_co = "Brazos",
      p_st = "tx",
      verbose = FALSE
    ),
    "tbl_df")

    expect_s3_class(
      echoWaterGetFacilityInfo(
        p_pid = "ALR040033",
        output = "df",
        qcolumns = "3,4,5"
      ),
      "tbl_df"
    )

    expect_s3_class(echoWaterGetParams(term = "Oxygen, dissolved"),
              "tbl_df")

    expect_s3_class(echoWaterGetParams(code = "00300"), "tbl_df")

    expect_s3_class(
      echoGetFacilities(
        program = "cwa",
        p_pid = "ALR040033",
        output = "df",
        qcolumns = "1,2,3"
      ),
      "tbl_df"
    )

  })

})

with_mock_api({

  ## this has to skip if offline because the functions
  ## return NULL when offline, but these functions may or may
  ## not be compared against mocked responses

  test_that("core functions return sf", {
    skip_if_offline(host = "echodata.epa.gov")

    expect_is(
      echoAirGetFacilityInfo(
        p_pid = "NC0000003706500036",
        output = "sf",
        verbose = FALSE
      ),
      "sf"
    )

    expect_is(echoWaterGetFacilityInfo(p_pid = "ALR040033", output = "sf"),
              "sf")

  })

})


## checks echoAirGetMeta echoWaterGetMeta
## function returns dataframe and messages as expected


with_mock_api({
  test_that("echoAirGetMeta returns df", {
    skip_if_offline(host = "echodata.epa.gov")

    expect_is(echoAirGetMeta(),
              "tbl_df")

    expect_message(echoAirGetMeta(verbose = TRUE))

    expect_is(echoWaterGetMeta(),
              "tbl_df")

    expect_message(echoWaterGetMeta(verbose = TRUE))
  })

})
