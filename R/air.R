
# echoAirGetFacilityInfo --------------------------------------------------

#' Downloads permitted air discharger information from EPA ECHO
#' @import httr
#' @import jsonlite
#' @param ... see \url{https://echo.epa.gov/tools/web-services/facility-search-water#!/Facility_Information/get_air_rest_services_get_facility_info} for a complete list of parameter options. Examples provided below.
#' @param output character string specifying output format. One of "JSON" or "GEOJSON"
#'
#' @return dataframe or geojson suitable for plotting
#' @export
#'
#' @examples\dontrun{
#' ## Not run:
#' ## Retrieve table of facilities by bounding box
#' echoAirGetFacilityInfo(xmin = "-96.407563",
#' ymin = "30.554395",
#' xmax = "-96.25947",
#' ymax = "30.751984",
#' output = "JSON")
#'
#' ## Retrieve a geojson by bounding box
#' spatialdata <- echoAirGetFacilityInfo(xmin = "-96.407563",
#' ymin = "30.554395",
#' xmax = "-96.25947",
#' ymax = "30.751984",
#' output = "GEOJSON")
#'
#' leaflet() %>%
#'     addTiles() %>%
#'     addGeoJSON(geojson = spatialdata)
#' }
echoAirGetFacilityInfo <- function(..., output) {

  ## returns a list of arguments supplied by user
  valuesList <- readEchoGetDots(...)

  if (output == "JSON") {

    ## build the request URL statement
    baseURL <- "https://ofmpub.epa.gov/echo/air_rest_services.get_facility_info?"
    appendURL <- paste(paste(names(valuesList),valuesList,sep="="),collapse="&")
    getURL <- paste0(baseURL,appendURL)

    ## Make the request
    request <- GET(getURL, accept_json())

    ## Print status message, need to make this optional
    print(paste("# Status message:", http_status(request)))

    ## Download JSON as text
    contentJSON <- content(request, as = "text")

    ## Read JSON into R
    info <- fromJSON(contentJSON,simplifyDataFrame = FALSE)

    ## build the output
    len <- purrr::map(info[["Results"]][["Facilities"]], length) # return a list of lengths
    maxIndex <- which.max(len) # if a different number of columns is returned per plant, we want to map values to the longest
    # this might fail if a entirely different columns are returned. Need to find out if there is some
    # consisteny in the returned columns

    cNames <- names(info[["Results"]][["Facilities"]][[maxIndex]])

    ## create the output dataframe
    buildOutput <- purrr::map_df(info[["Results"]][["Facilities"]], safe_extract, cNames)
  }

  if(output == "GEOJSON") {

    ## build the request URL statement
    baseURL <- "https://ofmpub.epa.gov/echo/air_rest_services.get_facility_info?output=GEOJSON&"
    appendURL <- paste(paste(names(valuesList),valuesList,sep="="),collapse="&")
    getURL <- paste0(baseURL,appendURL)

    ## Make the request
    request <- GET(getURL, accept_json())

    ## Print status message, need to make this optional
    print(paste("# Status message:", http_status(request)))

    ## Download GeoJSON as text
    buildOutput <- content(request, as = "text")

  }

  return(buildOutput)

}



# echoGetcaapr ------------------------------------------------------------

#' Download EPA ECHO emissions inventory report data
#'
#' @import httr
#' @import jsonlite
#' @import tibble
#' @import dplyr
#' @param ...
#'
#' @return dataframe
#' @export
#'
#' @examples \dontrun{
#' echoGetCAAPR(p_id = "110000350174")
#' }
#'
echoGetCAAPR <- function(...) {
  ## returns a list of arguments supplied by user
  valuesList <- readEchoGetDots(...)

  ## build the request URL statement
  baseURL <- "https://ofmpub.epa.gov/echo/caa_poll_rpt_rest_services.get_caapr?"
  appendURL <- paste(paste(names(valuesList),valuesList,sep="="),collapse="&")
  getURL <- paste0(baseURL,appendURL,'&output=json')

  request <- GET(getURL, accept_json())
  print(paste("# Status message:", http_status(request))) ## make this optional

  info <- content(request)

  ## Emissions data is provided in wide format
  pollutant <- map_df(info[["Results"]][["CAAPollRpt"]][["Pollutants"]],safe_extract,
                      c("Pollutant", "UnitsOfMeasure", "Year1", "Year2",
                        "Year3", "Year4", "Year5", "Year6", "Year7",
                        "Year8", "Year9", "Year10", "Program"))
  ## Change emissions data from wide to narrow
  pollutant <- tidyr::gather(pollutant, Year, Discharge, Year1:Year10)

  ## Year1 <- TRI_year_01... etc Note: Certainly a better way to do this.
  pollutant <- pollutant %>%
    mutate(Year = case_when(
      Year == "TRI_year_01" ~ info[["Results"]][["TRI_year_01"]],
      Year == "TRI_year_02" ~ info[["Results"]][["TRI_year_02"]],
      Year == "TRI_year_03" ~ info[["Results"]][["TRI_year_03"]],
      Year == "TRI_year_04" ~ info[["Results"]][["TRI_year_04"]],
      Year == "TRI_year_05" ~ info[["Results"]][["TRI_year_05"]],
      Year == "TRI_year_06" ~ info[["Results"]][["TRI_year_06"]],
      Year == "TRI_year_07" ~ info[["Results"]][["TRI_year_07"]],
      Year == "TRI_year_08" ~ info[["Results"]][["TRI_year_08"]],
      Year == "TRI_year_09" ~ info[["Results"]][["TRI_year_09"]],
      Year == "TRI_year_10" ~ info[["Results"]][["TRI_year_10"]]
    ))

  ## build output dataframe
  buildOutput <- tibble(
    Name = info[["Results"]][["CAAPollRpt"]][["RegistryIDs"]][[1]][["FacilityName"]],
    SourceID = info[["Results"]][["CAAPollRpt"]][["RegistryIDs"]][[1]][["SourceId"]],
    Street = info[["Results"]][["CAAPollRpt"]][["RegistryIDs"]][[1]][["Street"]],
    City = info[["Results"]][["CAAPollRpt"]][["RegistryIDs"]][[1]][["City"]],
    State = info[["Results"]][["CAAPollRpt"]][["RegistryIDs"]][[1]][["State"]],
    Zip = info[["Results"]][["CAAPollRpt"]][["RegistryIDs"]][[1]][["Zip"]],
    County = info[["Results"]][["CAAPollRpt"]][["RegistryIDs"]][[1]][["County"]],
    Region = info[["Results"]][["CAAPollRpt"]][["RegistryIDs"]][[1]][["Region"]],
    Latitude = info[["Results"]][["CAAPollRpt"]][["RegistryIDs"]][[1]][["Latitude"]],
    Longitude = info[["Results"]][["CAAPollRpt"]][["RegistryIDs"]][[1]][["Longitude"]],
    Pollutant = pollutant$Pollutant,
    UnitsOfMeasure = pollutant$UnitsOfMeasure,
    Program = pollutant$Program,
    Year = pollutant$Year,
    Discharge = pollutant$Discharge
    )

  return(buildOutput)
}
