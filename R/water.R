
# echoWaterGetFacilitiesInfo
# =========================================================

#' Downloads EPA ECHO water facility information
#'
#' Returns a dataframe or simplefeature dataframe of permitted facilities returned by the query.
#' Uses EPA's ECHO API: \url{https://echo.epa.gov/tools/web-services/facility-search-water}.
#' @param output Character string specifying output format. \code{output = 'df'} for a dataframe or \code{output = 'sf'} for a simple features spatial dataframe. See (\url{https://CRAN.R-project.org/package=sf}) for more information about simple features.
#' @param verbose Logical, indicating whether to provide processing and retrieval messages. Defaults to FALSE
#' @param \dots Further arguments passed as query parameters in request sent to EPA ECHO's API. For more options see: \url{https://echo.epa.gov/tools/web-services/facility-search-water#!/Facility_Information/get_cwa_rest_services_get_facility_info} for a complete list of parameter options. Examples provided below.
#' @return returns a dataframe or simple features dataframe
#' @import httr
#'
#' @export
#' @examples \donttest{
#' ## These examples require an internet connection to run
#'
#' ## Retrieve table of facilities by bounding box
#' echoWaterGetFacilityInfo(xmin = '-96.407563',
#' ymin = '30.554395',
#' xmax = '-96.25947',
#' ymax = '30.751984',
#' output = 'df')
#'
#' ## Retrieve a simple features dataframe by bounding box
#' spatialdata <- echoWaterGetFacilityInfo(xmin = '-96.407563',
#' ymin = '30.554395',
#' xmax = '-96.25947',
#' ymax = '30.751984',
#' output = 'sf')
#'
#' }
#'
echoWaterGetFacilityInfo <- function(output = "df",
                                     verbose = FALSE, ...) {
    if (length(list(...)) == 0) {
        stop("No valid arguments supplied")
    }
    ## returns a list of arguments supplied by user
    valuesList <- readEchoGetDots(...)

    ## check if user includes an output argument in dots if included, strip it
    ## out
    valuesList <- exclude(valuesList, "output")

    ## check if qcolumns argument is provided by user
    ## if user does not provide qcolumns, provide a sensible default
    if (!("qcolumns" %in% names(valuesList))) {
      qcolumns <- c(1:11,14,23,24,25,26,30,36,58,60,63,64,65,67,86,206)
      qcolumns <- paste(as.character(qcolumns), collapse = ",")
      valuesList[["qcolumns"]] <- qcolumns
    }

    # check if 1 and 2 are in, if not, insert and order
    valuesList <- insertQColumns(valuesList)

    ## generate query the will be pasted into GET URL
    queryDots <- queryList(valuesList)

    if (output == "df") {

        ## build the request URL statement
        path <- "echo/cwa_rest_services.get_facility_info"
        query <- paste("output=JSON", queryDots, sep = "&")
        getURL <- requestURL(path = path, query = query)

        ## Make the request
        request <- httr::GET(getURL, httr::accept_json())

        ## Print status message
        if (verbose) {
            message("The formatted URL is: ", getURL)
            message(httr::http_status(request))
        }

        info <- httr::content(request)

        qid <- info[["Results"]][["QueryID"]]

        ## build the output

        ## get qcolumns argument specific to this query
        qcolumns <- queryList(valuesList["qcolumns"])

        ## Find out column types
        colNums <- unlist(strsplit(valuesList[["qcolumns"]], split = ","))
        colNums <- as.numeric(colNums)

        ## ECHO always returns columns 1 and 2
        ## regardless of the url request.
        ## In order to correctly sort and identify column
        ## types, insert 1 and 2 into the request so
        ## metadat is looked up correctly
        if (!1 %in% colNums) { colNums <- append(colNums, 1)}
        if (!2 %in% colNums) { colNums <- append(colNums, 2)}
        colNums <- sort(colNums)

        colTypes <- columnsToParse(program = "cwa", colNums)

        buildOutput <- getDownload("cwa",
                                   qid,
                                   qcolumns,
                                   col_types = colTypes)
        return(buildOutput)

        }

    if (output == "sf") {

        ## build the request URL statement
        path <- "echo/cwa_rest_services.get_facility_info"
        query <- paste("output=GEOJSON", queryDots, sep = "&")
        getURL <- requestURL(path = path, query = query)

        ## Make the request
        request <- httr::GET(getURL, httr::accept_json())

        ## Print status message, need to make this optional
        if (verbose) {
            message("Request URL:", getURL)
            message(httr::http_status(request))
        }

        ## Download GeoJSON as text
        buildOutput <- httr::content(request, as = "text")

        ## Convert to sf dataframe
        buildOutput <- convertSF(buildOutput)
        return(buildOutput)
    } else {
        stop("output argument = ", output,
             ", when it should be either 'df' or 'sf'")
    }

}

# echoWaterGetMeta ============================================================

#' Downloads EPA ECHO Water Facility Metadata
#'
#' Returns variable name and descriptions for parameters returned by \code{\link{echoWaterGetFacilityInfo}}
#' @param verbose Logical, indicating whether to provide processing and retrieval messages. Defaults to FALSE
#'
#' @return returns a dataframe
#' @import httr
#' @importFrom purrr map_df
#' @export
#'
#' @examples \donttest{
#' ## These examples require an internet connection to run
#'
#' # returns a dataframe of
#' echoWaterGetMeta()
#' }
echoWaterGetMeta <- function(verbose = FALSE){

  ## build the request URL statement
  path <- "echo/cwa_rest_services.metadata?output=JSON"
  getURL <- requestURL(path = path, query = NULL)

  ## Make the request
  request <- httr::GET(getURL, httr::accept_json())

  ## Print status message, need to make this optional
  if (verbose) {
    message("Request URL:", getURL)
    message(httr::http_status(request))
  }

  info <- httr::content(request)
  info

  ## build the output
  buildOutput <- purrr::map_df(info[["Results"]][["ResultColumns"]],
                               safe_extract,
                               c("ColumnName", "DataType", "DataLength",
                                 "ColumnID", "ObjectName", "Description"))

  return(buildOutput)
}


# echoGetEffluent =========================================================


#' Downloads EPA ECHO DMR records of dischargers with NPDES permits
#' @param p_id Character string specify the identifier for the service. Required.
#' @param verbose Logical, indicating whether to provide processing and retrieval messages. Defaults to FALSE
#' @param ... Further arguments passed on as query parameters sent to EPA's ECHO API. For more options see: \url{https://echo.epa.gov/tools/web-services/effluent-charts#!/Effluent_Charts/get_eff_rest_services_get_effluent_chart}
#' @import httr
#' @importFrom lubridate dmy
#' @importFrom purrr map map_chr
#' @importFrom tibble tibble
#' @return Returns a dataframe.
#' @export
#'
#' @examples \donttest{
#' ## This example requires an internet connection to run
#'
#' ## Retrieve single DMR for flow
#'
#' echoGetEffluent(p_id = 'tx0119407', parameter_code = '50050')
#' }
echoGetEffluent <- function(p_id, verbose = FALSE, ...) {

    ## should check if character and return error if not
    p_id <- paste0("p_id=", p_id)

    ## returns a list of arguments supplied by user
    valuesList <- readEchoGetDots(...)

    ## check if user includes an output argument in dots if included, strip it
    ## out
    valuesList <- exclude(valuesList, "output")

    ## generate the intial query
    queryDots <- queryList(valuesList)

    ## build the request URL statement
    path <- "echo/eff_rest_services.get_effluent_chart"
    query <- paste(p_id, queryDots, "output=JSON", sep = "&")
    getURL <- requestURL(path = path, query = query)

    request <- httr::GET(getURL, httr::accept_json())

    if (verbose) {
        message("Request URL:", getURL)
        message(httr::http_status(request))
    }

    info <- httr::content(request)

    ## Obtain permit information used to make the dataframe
    CWPName <- info[["Results"]][["CWPName"]]
    SourceID <- info[["Results"]][["SourceId"]]
    RegistryID <- info[["Results"]][["RegistryId"]]
    Location <- info[["Results"]][["CWPStreet"]]
    City <- info[["Results"]][["CWPCity"]]
    State <- info[["Results"]][["CWPState"]]
    Zip <- info[["Results"]][["CWPZip"]]
    Status <- info[["Results"]][["CWPZip"]]
    nOutfalls <- seq_along(info[["Results"]][["PermFeatures"]])

    output <- data_frame()

    ## can I do this with purr::map? ##
    for (i in nOutfalls) {

        #Specify the DMRs for the intended outfall
        DMR <- info[["Results"]][["PermFeatures"]][[i]][["Parameters"]][[1]][["DischargeMonitoringReports"]]

        #Grab the outfall if number
        outfallNumber <- info[["Results"]][["PermFeatures"]][[i]][["PermFeatureNmbr"]]

        # Begin Exclude Linting
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
          DMRUnitDesc = purrr::map(DMR, "DMRUnitDesc", .default = NA),
          DMRValueStdUnits = as.numeric(purrr::map(DMR, "DMRValueStdUnits", .default = NA)),
          DMRQualifierCode = purrr::map(DMR, "DMRQualifierCode", .default = NA),
          ValueReceivedDate = lubridate::dmy(purrr::map_chr(DMR, "ValueReceivedDate", .default = NA)),
          DaysLate = as.integer(purrr::map(DMR, "DaysLate", .default = NA)),
          NODICode = purrr::map(DMR, "NODICode", .default = NA),
          NODEDesc = purrr::map(DMR, "NODEDesc", .default = NA),
          ExceedancePct = purrr::map(DMR, "ExceedancePct", .default = NA),
          NPDESViolations = purrr::map(DMR, "NPDESViolations", .default = NA))
        # End Exclude Linting
        output <- rbind(output, buildOutput)

    }

    return(output)

}



# echoWaterGetParams ------------------------------------------------------

#' Search parameter codes for Clean Water Act permits on EPA ECHO
#'
#' Returns a dataframe of parameter codes and descriptions.
#' @import httr
#' @importFrom purrr map_df
#' @importFrom utils URLencode
#'
#' @param term Character string specifying the parameter search term. Partial or complete search phrase or word.
#' @param code Character string specifying the parameter search code value.
#' @param verbose Logical, indicating whether to provide processing and retrieval messages. Defaults to FALSE
#'
#' @return Returns a dataframe.
#' @export
#' @examples \donttest{
#' ## These examples require an internet connection to run
#'
#' ## Retrieve parameter codes for dissolved oxygen
#' echoWaterGetParams(term = "Oxygen, dissolved")
#'
#' echoWaterGetParams(code = "00300")
#' }
echoWaterGetParams <- function(term = NULL, code = NULL, verbose = FALSE){

  path <- "echo/rest_lookups.cwa_parameters"

  # check if both arguments are null, return error if true
  if (is.null(term)) {
    if (is.null(code)) {
      stop("No valid arguments provided")
    }
    else{
      ## build the request URL statement using code argument
      code <- paste0("search_code=", code)
      query <- paste("output=JSON", code, sep = "&")
      getURL <- requestURL(path = path, query = query)
    }
  }
  else{
    # check if both arguments are assigned, return error if true
    if (!is.null(code)) {
      stop("Please specify only a single argument")
    }
    else{
      ## build the request URL statement for term argument
      term <- utils::URLencode(term, reserved = TRUE)
      term <- paste0("search_term=", term)
      query <- paste("output=JSON", term, sep = "&")
      getURL <- requestURL(path = path, query = query)
    }
  }

  request <- httr::GET(getURL, httr::accept_json())

  if (verbose) {
    message("Request URL:", getURL)
    message(httr::http_status(request))
  }

  info <- httr::content(request)

  buildOutput <- purrr::map_df(info[["Results"]][["LuValues"]],
                               safe_extract,
                               c("ValueCode", "ValueDescription"))

  return(buildOutput)
}
