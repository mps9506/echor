#capture mock data using httptest
#to do: functionalize this so I can use the test files to generate the data

library(httptest)
.mockPaths(here::here("tests/testthat/api"))
api_root <- "https://ofmpub.epa.gov/echo/"
set_redactor(function (response) {
  response %>%
    gsub_response(api_root, "", fixed = TRUE)
})

set_requester(function (request) {
  request %>%
    gsub_request(api_root, "", fixed = TRUE)
})


httptest::start_capturing()
echoAirGetFacilityInfo(
        p_pid = "NC0000003706500036",
        output = "df",
        qcolumns = "3,4,5"
      )
httptest::stop_capturing()
Sys.sleep(10)


httptest::start_capturing()
echoSDWGetMeta(verbose = FALSE)
httptest::stop_capturing()
Sys.sleep(10)


httptest::start_capturing()
echoGetCAAPR(p_id = '110000350174')
httptest::stop_capturing()
Sys.sleep(10)


httptest::start_capturing()
echoGetEffluent(p_id = "tx0119407", parameter_code = "50050")
httptest::stop_capturing()
Sys.sleep(10)


httptest::start_capturing()
echoGetReports(program = "caa",
      p_id = '110000350174',
      verbose = FALSE)
httptest::stop_capturing()
Sys.sleep(10)


httptest::start_capturing()
echoGetReports(
        program = "cwa",
        p_id = "tx0119407",
        parameter_code = "50050",
        verbose = FALSE
      )
httptest::stop_capturing()
Sys.sleep(10)


httptest::start_capturing()
echoSDWGetSystems(
      p_co = "Brazos",
      p_st = "tx",
      verbose = FALSE)
httptest::stop_capturing()
Sys.sleep(10)


httptest::start_capturing()
echoWaterGetFacilityInfo(
        p_pid = "ALR040033",
        output = "df",
        qcolumns = "3,4,5"
      )
httptest::stop_capturing()
Sys.sleep(10)


httptest::start_capturing()
echoWaterGetParams(term = "Oxygen, dissolved")
httptest::stop_capturing()
Sys.sleep(10)


httptest::start_capturing()
echoWaterGetParams(code = "00300")
httptest::stop_capturing()
Sys.sleep(10)


httptest::start_capturing()
echoGetFacilities(
        program = "cwa",
        p_pid = "ALR040033",
        output = "df",
        qcolumns = "1,2,3"
      )
httptest::stop_capturing()
Sys.sleep(10)


httptest::start_capturing()
echoAirGetFacilityInfo(
        p_pid = "NC0000003706500036",
        output = "sf",
        verbose = FALSE
      )
httptest::stop_capturing()
Sys.sleep(10)


httptest::start_capturing()
echoWaterGetFacilityInfo(p_pid = "ALR040033", output = "sf")
httptest::stop_capturing()
Sys.sleep(10)
