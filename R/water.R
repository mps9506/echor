
# echoWaterGetFacilitiesInfo =========================================================

#' Downloads EPA ECHO water facility data
#'
#' \code{echoWaterGetFacilityInfo()} downloads specified permitted water discharger facility information
#' using EPA's ECHO API (\url{https://echo.epa.gov/tools/web-services/facility-search-water}), \code{\link[httr]{GET}}, and \code{jsonlite}.
#'
#' @param \dots see \url{https://echo.epa.gov/tools/web-services/facility-search-water#!/Facility_Information/get_cwa_rest_services_get_facility_info} for a complete list of parameter options. Examples provided below.
#' @param output character string specifying output format. One of "JSON" or "GEOJSON"
#' @return The output will be a tibble of facility details
#' @import httr
#' @import jsonlite
#' @import tibble
#' @return A data frame, the number of variables will depend on the reporting requirements of the retrived plants
#'
#' @export
#' @examples \dontrun{
#' ## Not run:
#' ## Retrieve table of facilities by bounding box
#' echoWaterGetFacilityInfo(xmin = "-96.407563", ymin = "30.554395", xmax = "-96.25947", ymax = "30.751984", output = "JSON")
#'
#' ## Retrieve a geojson by bounding box
#' spatialdata <- echoWaterGetFacilityInfo(xmin = "-96.407563", ymin = "30.554395", xmax = "-96.25947", ymax = "30.751984", output = "GEOJSON")
#' leaflet() %>%
#'     addTiles() %>%
#'     addGeoJSON(geojson = spatialdata)
#' }
#'
echoWaterGetFacilityInfo <- function(..., output) {

  ## returns a list of arguments supplied by user
  valuesList <- readEchoGetDots(...)

  if (output == "JSON") {

    ## build the request URL statement
    baseURL <- "https://ofmpub.epa.gov/echo/cwa_rest_services.get_facility_info?"
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
    baseURL <- "https://ofmpub.epa.gov/echo/cwa_rest_services.get_facility_info?output=GEOJSON&"
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


# echoGetEffluent =========================================================


#' Downloads EPA ECHO DMR records
#'
#' @param ...
#'
#' @return
#' @export
#'
#' @examples \dontrun{
#' ## Retrieve single DMR for flow
#' echoGetEffluent(p_id = "tx0119407", parameter_code = "50050")
#' }
echoGetEffluent <- function(...) {

  ## returns a list of arguments supplied by user
  valuesList <- readEchoGetDots(...)

  ## build the request URL statement
  baseURL <- "https://ofmpub.epa.gov/echo/eff_rest_services.get_effluent_chart?"
  appendURL <- paste(paste(names(valuesList),valuesList,sep="="),collapse="&")
  getURL <- paste0(baseURL,appendURL,'&output=json')

  request <- GET(getURL, accept_json())
  print(paste("# Status message:", http_status(request))) ## make this optional

  info <- content(request)

  ## Obtain permit information used to make the dataframe
  CWPName <- info[["Results"]][["CWPName"]] #Grabs the permitted name
  SourceID <- info[["Results"]][["SourceId"]] #Grabs the permitted id
  RegistryID <- info[["Results"]][["RegistryId"]] #Grabs the registry id
  Location <- info[["Results"]][["CWPStreet"]] #Location Descriptor
  City <- info[["Results"]][["CWPCity"]] #Grabs the city on the permit
  State <- info[["Results"]][["CWPState"]] #Grabs the state on the permit
  Zip <- info[["Results"]][["CWPZip"]] #Grab the zipcode on the permit
  Status <- info[["Results"]][["CWPZip"]] #Grab the current permit status
  nOutfalls <- seq_along(info[["Results"]][["PermFeatures"]]) #grab number of outfall features

  output <- data_frame()

  ## can I do this with purr::map? ##
  for (i in nOutfalls){

    DMR <- info[["Results"]][["PermFeatures"]][[i]][["Parameters"]][[1]][["DischargeMonitoringReports"]] #Specify the DMRs for the intended outfall
    outfallNumber <- info[["Results"]][["PermFeatures"]][[i]][["PermFeatureNmbr"]] #Grab the outfall if number

    buildOutput <- tibble(
      Name = CWPName,
      Outfall = outfallNumber,
      ID = SourceID,
      RegistryID = RegistryID,
      Location = Location,
      City = City,
      State = State,
      Zip = Zip,
      Status = Status,
      LimitBeginDate = lubridate::dmy(purrr::map_chr(DMR, "LimitBeginDate", .default = NA)),
      LimitEndDate = lubridate::dmy(purrr::map_chr(DMR, "LimitEndDate", .default = NA)),
      LimitValueNmbr = as.numeric(purrr::map_chr(DMR, "LimitValueNmbr", .default = NA)),
      LimitUnitCode = purrr::map_chr(DMR, "LimitUnitCode", .default = NA),
      LimitUnitDesc = purrr::map_chr(DMR, "LimitUnitDesc", .default = NA),
      StdUnitCode = purrr::map_chr(DMR, "StdUnitDesc", .default = NA),
      StdUnitDesc = purrr::map_chr(DMR, "StdUnitDesc", .default = NA),
      LimitValueStdUnit = purrr::map_chr(DMR, "LimitValueStdUnit", .default = NA),
      StatisticalBaseCode = purrr::map_chr(DMR, "StatisticalBaseCode", .default = NA),
      StatisticalBaseDesc = purrr::map_chr(DMR, "StatisticalBaseDesc", .default = NA),
      StatisticalBaseTypeCode = purrr::map(DMR, "StatisticalBaseTypeCode", .default = NA),
      StatisticalBaseTypeDesc = purrr::map(DMR, "StatisticalBaseTypeDesc", .default = NA),
      DMREventId = purrr::map_chr(DMR, "DMREventId", .default = NA),
      MonitoringPeriodEndDate = lubridate::dmy(purrr::map_chr(DMR, "MonitoringPeriodEndDate", .default = NA)),
      DMRFormValueId = purrr::map_chr(DMR, "DMRFormValueId", .default = NA),
      ValueTypeCode = purrr::map(DMR, "ValueTypeCode", .default = NA),
      ValueTypeDesc = purrr::map(DMR, "ValueTypeDesc", .default = NA),
      DMRValueId = purrr::map_chr(DMR, "DMRValueId", .default = NA),
      DMRValueNmbr = as.numeric(purrr::map(DMR, "DMRValueNmbr", .default = NA)),
      DMRUnitCode = purrr::map(DMR, "DMRUnitCode", .default = NA),
      DMRUnitDesc = purrr::map(DMR, "DMRUnitDesc",.default = NA),
      DMRValueStdUnits = as.numeric(purrr::map(DMR, "DMRValueStdUnits", .default = NA)),
      DMRQualifierCode = purrr::map(DMR, "DMRQualifierCode", .default = NA),
      ValueReceivedDate = lubridate::dmy(purrr::map_chr(DMR, "ValueReceivedDate", .default = NA)),
      DaysLate = as.integer(purrr::map(DMR, "DaysLate", .default = NA)),
      NODICode = purrr::map(DMR, "NODICode", .default = NA),
      NODEDesc = purrr::map(DMR, "NODEDesc", .default = NA),
      ExceedancePct = purrr::map(DMR, "ExceedancePct", .default = NA),
      NPDESViolations = purrr::map(DMR, "NPDESViolations", .default = NA)
    )

    output <- rbind(output, buildOutput)

  }

  return(output)

}
