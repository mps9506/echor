
# echoAirGetFacilityInfo --------------------------------------------------

#' Downloads EPA ECHO permitted air emitter information
#'
#' Returns a dataframe or simplefeature dataframe of permitted facilities returned by the query.
#' Uses EPA's ECHO API: \url{https://echo.epa.gov/tools/web-services/facility-search-air#!/Facilities/get_air_rest_services_get_facility_info}
#' @param output Character string specifying output format. \code{output = 'df'} for a dataframe or \code{output = 'sf'} for a simple features spatial dataframe. See (\url{https://CRAN.R-project.org/package=sf}) for more information about simple features.
#' @param verbose Logical, indicating whether to provide processing and retrieval messages. Defaults to FALSE
#' @param ... Further arguments passed as query parameters in request sent to EPA ECHO's API. For more options see: \url{https://echo.epa.gov/tools/web-services/facility-search-water#!/Facility_Information/get_air_rest_services_get_facility_info} for a complete list of parameter options. Examples provided below.
#' @import httr
#' @return dataframe or sf dataframe suitable for plotting
#' @export
#'
#' @examples\donttest{
#' ## These examples require an internet connection to run
#'
#' ## Retrieve table of facilities by bounding box
#' echoAirGetFacilityInfo(xmin = '-96.407563',
#' ymin = '30.554395',
#' xmax = '-96.25947',
#' ymax = '30.751984',
#' output = 'df')
#'
#' ## Retrieve a simple features dataframe by bounding box
#' spatialdata <- echoAirGetFacilityInfo(xmin = '-96.407563',
#' ymin = '30.554395',
#' xmax = '-96.25947',
#' ymax = '30.751984',
#' output = 'sf')
#'
#' }
echoAirGetFacilityInfo <- function(output = "df", verbose = FALSE, ...) {
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
      qcolumns <- c(1:5,22,23)
      qcolumns <- paste(as.character(qcolumns), collapse = ",")
      valuesList[["qcolumns"]] <- qcolumns
    }

    # check if 1 and 2 are in, if not, insert and order
    valuesList <- insertQColumns(valuesList)

    ## generate query the will be pasted into GET URL
    queryDots <- queryList(valuesList)

    if (output == "df") {

      ## build the request URL statement
      path <- "echo/air_rest_services.get_facility_info"
      query <- paste("output=JSON", queryDots, sep = "&")
      getURL <- requestURL(path = path, query = query)

        ## Make the request
        request <- httr::GET(getURL, httr::accept_json())

        ## Print status message, need to make this optional
        if (verbose) {
          message("Request URL:", getURL)
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

        colTypes <- columnsToParse(program = "caa", colNums)

        buildOutput <- getDownload("caa",
                                   qid,
                                   qcolumns,
                                   col_types = colTypes)
        return(buildOutput)
        }

    if (output == "sf") {

        ## build the request URL statement
        path <- "echo/air_rest_services.get_facility_info"
        query <- paste("output=GEOJSON", queryDots, sep = "&")
        getURL <- requestURL(path = path, query = query)

        ## Make the request
        request <- httr::GET(getURL, httr::accept_json())

        ## Print status message, need to make this optional
        print(paste("# Status message:", httr::http_status(request)))

        ## Download GeoJSON as text
        buildOutput <- httr::content(request, as = "text")

        ## Convert to sf dataframe
        buildOutput <- convertSF(buildOutput)

        return(buildOutput)

    }
    else {
      stop("output argument = ", output,
           ", when it should be either 'df' or 'sf'")
    }

}

# echoAirGetMeta ============================================================

#' Downloads EPA ECHO Air Facility Metadata
#'
#' Returns variable name and descriptions for parameters returned by \code{\link{echoAirGetFacilityInfo}}
#' @param verbose Logical, indicating whether to provide processing and retrieval messages. Defaults to FALSE
#' @import httr
#' @importFrom purrr map_df
#' @return returns a dataframe
#' @export
#'
#' @examples \donttest{
#' ## These examples require an internet connection to run
#'
#' # returns a dataframe of
#' echoAirGetMeta()
#' }
echoAirGetMeta <- function(verbose = FALSE){

  ## build the request URL statement
  path <- "echo/air_rest_services.metadata?output=JSON"
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


# echoGetcaapr ------------------------------------------------------------

#' Download EPA ECHO emissions inventory report data
#'
#' @param p_id character string specify the identifier for the service. Required.
#' @param verbose Logical, indicating whether to provide processing and retrieval messages. Defaults to FALSE
#' @param ... Additional arguments
#' @importFrom purrr map_df
#' @importFrom tidyr gather_
#' @importFrom tibble tibble
#' @import httr
#' @import dplyr
#' @return dataframe
#' @export
#'
#' @examples \donttest{
#' ## This example requires an internet connection to run
#'
#' echoGetCAAPR(p_id = '110000350174')
#' }
#'
echoGetCAAPR <- function(p_id, verbose = FALSE, ...) {

    # check that p_id is a character
    if (!is.character(p_id)) {
        stop("p_id must be a character")
    }


    ## should check if character and return error if not
    p_id <- paste0("p_id=", p_id)

    ## returns a list of arguments supplied by user
    valuesList <- readEchoGetDots(...)

    ## check if user includes an output argument in dots if included, strip it
    ## out
    valuesList <- exclude(valuesList, "output")

    ## generate the intial query
    queryDots <- paste(paste(names(valuesList), valuesList, sep = "="),
                       collapse = "&")

    ## build the request URL statement
    path <- "echo/caa_poll_rpt_rest_services.get_caapr"
    query <- paste(p_id, queryDots, "output=JSON", sep = "&")
    getURL <- requestURL(path = path, query = query)

    request <- httr::GET(getURL, httr::accept_json())

    if (verbose) {
        message("Request URL:", getURL)
        message(httr::http_status(request))
    }

    info <- httr::content(request)

    ## Emissions data is provided in wide format
    pollutant <- purrr::map_df(
      info[["Results"]][["CAAPollRpt"]][["Pollutants"]],
      safe_extract,
      c("Pollutant", "UnitsOfMeasure", "Year1",
        "Year2", "Year3", "Year4",
        "Year5", "Year6", "Year7",
        "Year8", "Year9", "Year10",
        "Program"))
    ## Change emissions data from wide to narrow
    pollutant <- tidyr::gather_(pollutant, "Year", "Discharge", c("Year1",
                                                                  "Year2",
                                                                  "Year3",
                                                                  "Year4",
                                                                  "Year5",
                                                                  "Year6",
                                                                  "Year7",
                                                                  "Year8",
                                                                  "Year9",
                                                                  "Year10"))


    pollutant <- pollutant %>%
      mutate(Year = case_when(Year == "Year1" ~
                                info[["Results"]][["TRI_year_01"]],
        Year == "Year2" ~ info[["Results"]][["TRI_year_02"]],
        Year == "Year3" ~ info[["Results"]][["TRI_year_03"]],
        Year == "Year4" ~ info[["Results"]][["TRI_year_04"]],
        Year == "Year5" ~ info[["Results"]][["TRI_year_05"]],
        Year == "Year6" ~ info[["Results"]][["TRI_year_06"]],
        Year == "Year7" ~ info[["Results"]][["TRI_year_07"]],
        Year == "Year8" ~ info[["Results"]][["TRI_year_08"]],
        Year == "Year9" ~ info[["Results"]][["TRI_year_09"]],
        Year == "Year10" ~ info[["Results"]][["TRI_year_10"]]))

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
      Latitude = as.numeric(info[["Results"]][["CAAPollRpt"]][["RegistryIDs"]][[1]][["Latitude"]]),
      Longitude = as.numeric(info[["Results"]][["CAAPollRpt"]][["RegistryIDs"]][[1]][["Longitude"]]),
      Pollutant = as.factor(pollutant$Pollutant), UnitsOfMeasure = as.factor(pollutant$UnitsOfMeasure),
      Program = as.factor(pollutant$Program), Year = as.integer(pollutant$Year),
      Discharge = as.numeric(gsub(",", "", pollutant$Discharge))  #handle commas
)

    return(buildOutput)
}
