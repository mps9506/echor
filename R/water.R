
# echoWaterGetFacilitiesInfo
# =========================================================

#' Downloads EPA ECHO water facility information
#'
#' Returns a dataframe or simplefeature dataframe of permitted facilities returned by the query.
#' Uses EPA's ECHO API: \url{https://echo.epa.gov/tools/web-services/facility-search-water}.
#' @param output Character string specifying output format. \code{output = 'df'} for a dataframe or \code{output = 'sf'} for a simple features spatial dataframe. See (\url{https://cran.r-project.org/web/packages/sf/vignettes/sf1.html}) for more information about simple features.
#' @param verbose Logical, indicating whether to provide prcessing and retrieval messages. Defaults to FALSE
#' @param \dots Further arguments passed as query parameters in request sent to EPA ECHO's API. For more options see: \url{https://echo.epa.gov/tools/web-services/facility-search-water#!/Facility_Information/get_cwa_rest_services_get_facility_info} for a complete list of parameter options. Examples provided below.
#' @return dataframe or simple feature
#' @import httr
#' @import jsonlite
#' @importFrom sf read_sf
#'
#' @export
#' @examples \dontrun{
#' ## Not run:
#' ## Retrieve table of facilities by bounding box
#' echoWaterGetFacilityInfo(xmin = '-96.407563',
#' ymin = '30.554395',
#' xmax = '-96.25947',
#' ymax = '30.751984',
#' output = 'df')
#'
#' ## Retrieve a geojson by bounding box
#' spatialdata <- echoWaterGetFacilityInfo(xmin = '-96.407563',
#' ymin = '30.554395',
#' xmax = '-96.25947',
#' ymax = '30.751984',
#' output = 'sf')
#'
#' }
#'
echoWaterGetFacilityInfo <- function(output = "df", verbose = FALSE, ...) {
    if (length(list(...)) == 0) {
        stop("No valid arguments supplied")
    }
    ## returns a list of arguments supplied by user
    valuesList <- readEchoGetDots(...)

    ## check if user includes an output argument in dots if included, strip it out
    valuesList <- exclude(valuesList, "output")

    ## generate query the will be pasted into GET URL
    queryDots <- queryList(valuesList)

    if (output == "df") {

        ## build the request URL statement
        path <- "echo/cwa_rest_services.get_facility_info"
        query <- paste("output=JSON", queryDots, sep = "&")
        getURL <- requestURL(path = path, query = query)

        ## Make the request
        request <- GET(getURL, accept_json())

        ## Print status message, need to make this optional
        if (verbose) {
            message("Request URL:", getURL)
            message(http_status(request))
        }

        ## Download JSON as text contentJSON <- content(request, as = 'text')
        info <- content(request)
        ## Read JSON into R info <- fromJSON(contentJSON,simplifyDataFrame = FALSE)

        ## build the output
        len <- purrr::map(info[["Results"]][["Facilities"]], length)  # return a list of lengths
        maxIndex <- which.max(len)  # if a different number of columns is returned per plant, we want to map values to the longest
        # this might fail if a entirely different columns are returned. Need to find out
        # if there is some consisteny in the returned columns

        cNames <- names(info[["Results"]][["Facilities"]][[maxIndex]])

        ## create the output dataframe
        buildOutput <- purrr::map_df(info[["Results"]][["Facilities"]], safe_extract,
            cNames)
        return(buildOutput)
    }

    if (output == "sf") {

        ## build the request URL statement
        path <- "echo/cwa_rest_services.get_facility_info?"
        query <- paste("output=GEOJSON", queryDots, sep = "&")
        getURL <- requestURL(path = path, query = query)

        ## Make the request
        request <- GET(getURL, accept_json())

        ## Print status message, need to make this optional
        if (verbose) {
            message("Request URL:", getURL)
            message(http_status(request))
        }

        ## Download GeoJSON as text
        buildOutput <- content(request, as = "text")

        ## Convert to sf dataframe
        buildOutput <- convertSF(buildOutput)

        return(buildOutput)
    } else {
        stop("output argument = ", output, ", when it should be either 'df' or 'sf'")
    }

}


# echoGetEffluent =========================================================


#' Downloads EPA ECHO DMR records of dischargers with NPDES permits
#' @import httr
#' @import jsonlite
#' @import tibble
#' @param p_id Character string specify the identifier for the service. Required.
#' @param verbose Logical, indicating whether to provide processing and retrieval messages. Defaults to FALSE
#' @param ... Further arguments passed on as query parameters sent to EPA's ECHO API. For more options see: \url{https://echo.epa.gov/tools/web-services/effluent-charts#!/Effluent_Charts/get_eff_rest_services_get_effluent_chart}
#' @return dataframe
#' @export
#'
#' @examples \dontrun{
#' ## Retrieve single DMR for flow
#' echoGetEffluent(p_id = 'tx0119407', parameter_code = '50050')
#' }
echoGetEffluent <- function(p_id, verbose = FALSE, ...) {

    ## should check if character and return error if not
    p_id = paste0("p_id=", p_id)

    ## returns a list of arguments supplied by user
    valuesList <- readEchoGetDots(...)

    ## check if user includes an output argument in dots if included, strip it out
    valuesList <- exclude(valuesList, "output")

    ## generate the intial query
    queryDots <- queryList(valuesList)

    ## build the request URL statement
    path <- "echo/eff_rest_services.get_effluent_chart"
    query <- paste(p_id, queryDots, "output=JSON", sep = "&")
    getURL <- requestURL(path = path, query = query)

    request <- GET(getURL, accept_json())

    if (verbose) {
        message("Request URL:", getURL)
        message(http_status(request))
    }

    info <- content(request)

    ## Obtain permit information used to make the dataframe
    CWPName <- info[["Results"]][["CWPName"]]  #Grabs the permitted name
    SourceID <- info[["Results"]][["SourceId"]]  #Grabs the permitted id
    RegistryID <- info[["Results"]][["RegistryId"]]  #Grabs the registry id
    Location <- info[["Results"]][["CWPStreet"]]  #Location Descriptor
    City <- info[["Results"]][["CWPCity"]]  #Grabs the city on the permit
    State <- info[["Results"]][["CWPState"]]  #Grabs the state on the permit
    Zip <- info[["Results"]][["CWPZip"]]  #Grab the zipcode on the permit
    Status <- info[["Results"]][["CWPZip"]]  #Grab the current permit status
    nOutfalls <- seq_along(info[["Results"]][["PermFeatures"]])  #grab number of outfall features

    output <- data_frame()

    ## can I do this with purr::map? ##
    for (i in nOutfalls) {

        DMR <- info[["Results"]][["PermFeatures"]][[i]][["Parameters"]][[1]][["DischargeMonitoringReports"]]  #Specify the DMRs for the intended outfall
        outfallNumber <- info[["Results"]][["PermFeatures"]][[i]][["PermFeatureNmbr"]]  #Grab the outfall if number

        buildOutput <- tibble(Name = CWPName, Outfall = outfallNumber, ID = SourceID,
            RegistryID = RegistryID, Location = Location, City = City, State = State,
            Zip = Zip, Status = Status, LimitBeginDate = lubridate::dmy(purrr::map_chr(DMR,
                "LimitBeginDate", .default = NA)), LimitEndDate = lubridate::dmy(purrr::map_chr(DMR,
                "LimitEndDate", .default = NA)), LimitValueNmbr = as.numeric(purrr::map_chr(DMR,
                "LimitValueNmbr", .default = NA)), LimitUnitCode = purrr::map_chr(DMR,
                "LimitUnitCode", .default = NA), LimitUnitDesc = purrr::map_chr(DMR,
                "LimitUnitDesc", .default = NA), StdUnitCode = purrr::map_chr(DMR,
                "StdUnitDesc", .default = NA), StdUnitDesc = purrr::map_chr(DMR,
                "StdUnitDesc", .default = NA), LimitValueStdUnit = purrr::map_chr(DMR,
                "LimitValueStdUnit", .default = NA), StatisticalBaseCode = purrr::map_chr(DMR,
                "StatisticalBaseCode", .default = NA), StatisticalBaseDesc = purrr::map_chr(DMR,
                "StatisticalBaseDesc", .default = NA), StatisticalBaseTypeCode = purrr::map(DMR,
                "StatisticalBaseTypeCode", .default = NA), StatisticalBaseTypeDesc = purrr::map(DMR,
                "StatisticalBaseTypeDesc", .default = NA), DMREventId = purrr::map_chr(DMR,
                "DMREventId", .default = NA), MonitoringPeriodEndDate = lubridate::dmy(purrr::map_chr(DMR,
                "MonitoringPeriodEndDate", .default = NA)), DMRFormValueId = purrr::map_chr(DMR,
                "DMRFormValueId", .default = NA), ValueTypeCode = purrr::map(DMR,
                "ValueTypeCode", .default = NA), ValueTypeDesc = purrr::map(DMR,
                "ValueTypeDesc", .default = NA), DMRValueId = purrr::map_chr(DMR,
                "DMRValueId", .default = NA), DMRValueNmbr = as.numeric(purrr::map(DMR,
                "DMRValueNmbr", .default = NA)), DMRUnitCode = purrr::map(DMR, "DMRUnitCode",
                .default = NA), DMRUnitDesc = purrr::map(DMR, "DMRUnitDesc", .default = NA),
            DMRValueStdUnits = as.numeric(purrr::map(DMR, "DMRValueStdUnits", .default = NA)),
            DMRQualifierCode = purrr::map(DMR, "DMRQualifierCode", .default = NA),
            ValueReceivedDate = lubridate::dmy(purrr::map_chr(DMR, "ValueReceivedDate",
                .default = NA)), DaysLate = as.integer(purrr::map(DMR, "DaysLate",
                .default = NA)), NODICode = purrr::map(DMR, "NODICode", .default = NA),
            NODEDesc = purrr::map(DMR, "NODEDesc", .default = NA), ExceedancePct = purrr::map(DMR,
                "ExceedancePct", .default = NA), NPDESViolations = purrr::map(DMR,
                "NPDESViolations", .default = NA))

        output <- rbind(output, buildOutput)

    }

    return(output)

}
