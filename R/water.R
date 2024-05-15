
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
#' @import progress
#' @importFrom sf st_read
#' @importFrom dplyr bind_rows
#'
#' @export
#' @examples \donttest{
#' ## These examples require an internet connection to run
#'
#' ## Retrieve table of facilities by bounding box
#' echoWaterGetFacilityInfo(p_c1lon = '-96.407563',
#' p_c1lat = '30.554395',
#' p_c2lon = '-96.25947',
#' p_c2lat = '30.751984',
#' p_pcomp = 'POT',
#' output = 'df')
#'
#' ## Retrieve a simple features dataframe by bounding box
#' spatialdata <- echoWaterGetFacilityInfo(p_c2lon = '-96.407563',
#' p_c1lat = '30.554395',
#' p_c2lon = '-96.25947',
#' p_c2lat = '30.751984',
#' p_pcomp = 'POT',
#' output = 'sf')
#'
#' }
#'
echoWaterGetFacilityInfo <- function(output = "df",
                                     verbose = FALSE, ...) {

  ## check connectivity
  if (!isTRUE(check_connectivity())) {
    return(invisible(NULL))
  }

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

  ## build the request URL statement
  #path <- "echo/cwa_rest_services.get_facility_info"
  path <- "echo/cwa_rest_services.get_facilities"
  query <- paste("output=JSON", queryDots, sep = "&")
  getURL <- requestURL(path = path, query = query)

  ## Make the request
  request <- httr::RETRY("GET",
                         url = getURL,
                         httr::accept_json())

  ## Check for valid response for serve, else prints a message and
  ## returns an invisible NULL
  if (!isTRUE(resp_check(request)))
  {
    return(invisible(NULL))
  }

  ## Print status message
  if (isTRUE(verbose)) {
    message("The formatted URL is: ", getURL)
    message(httr::http_status(request))
  }

  info <- httr::content(request)

  ## return the query id
  qid <- info[["Results"]][["QueryID"]]

  ## return the number of records
  n_records <- info[["Results"]][["QueryRows"]]
  n_records <- as.numeric(n_records)

  ## build the output

  ## get qcolumns argument specific to this query
  qcolumns <- queryList(valuesList["qcolumns"])

  ## Find out column types
  colNums <- unlist(strsplit(valuesList[["qcolumns"]], split = ","))
  colNums <- as.numeric(colNums)

  colTypes <- columnsToParse(program = "cwa", colNums)

  ## if df return output from air_rest_services.get_download
  if (output == "df") {
    ## if <= 100000 records use getDownload
    if (n_records <= 100000) {

      buildOutput <- getDownload("cwa",
                                 qid,
                                 qcolumns,
                                 col_types = colTypes)
    } else {

      # number of pages returned is n_records/5000
      pages <- ceiling(n_records/5000)
      # create the progress bar
      pb <- progress_bar$new(total = pages)

      buildOutput <- getQID("cwa",
                            qid,
                            qcolumns,
                            page = 1)
      pb$tick()

      for (i in 2:pages) {
        buildOutput <- bind_rows(buildOutput,
                                 getQID("cwa",
                                        qid,
                                        qcolumns,
                                        page = i))
        Sys.sleep(0.5)
        pb$tick()
      }

    }
    return(buildOutput)
  }

  ## if df return output from air_rest_services.get_geojson
  if (output == "sf") {

    ## echo now returns clusters in a seperate API call (get_info_clusters)
    ## so I think the code below is no longer required.

    ## if returns clusters, there are to many records to
    ## return records via geojson and the request needs to
    ## be more specific. I'm not sure how many records are too
    ## many. If the length of facilities == 0, it means
    ## the query either return no records, or the request returned
    ## clusters and we can stop the function and return a message.
    # if(length(info[["Results"]][["Facilities"]]) == 0) {
    #   if(n_records > 0) {
    #     message("Too many records to return spatial a object, please subset your request and try again.")
    #     return(invisible(NULL))
    #   }
    #   if(n_records == 0) {
    #     message("No records returned in your request")
    #     return(invisible(NULL))
    #   }
    # }
    buildOutput <- getGeoJson("cwa",
                              qid,
                              qcolumns,
                              verbose = verbose)
    if(is.null(buildOutput)) {
      return(invisible(NULL))
    }
    ## Convert to sf dataframe
    buildOutput <- sf::st_read(buildOutput, quiet = TRUE)
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

  ## check connectivity
  if (!isTRUE(check_connectivity())) {
    return(invisible(NULL))
  }

  ## build the request URL statement
  path <- "echo/cwa_rest_services.metadata?output=JSON"
  getURL <- requestURL(path = path, query = NULL)

  ## Make the request
  request <- httr::RETRY("GET",
                         url = getURL,
                         httr::accept_json())

  ## Check for valid response for serve, else prints a message and
  ## returns an invisible NULL
  if (!isTRUE(resp_check(request)))
  {
    return(invisible(NULL))
  }

  ## Print status message, need to make this optional
  if (isTRUE(verbose)) {
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
#'
#' Uses EPA ECHO API to download the Discharge Monitoring Record (DMR) of a single plant, identified with p_id. Please note that the p_id is case sensitive.
#' @param p_id Character string specify the identifier for the service. Required. Case sensitive.
#' @param verbose Logical, indicating whether to provide processing and retrieval messages. Defaults to FALSE
#' @param ... Further arguments passed on as query parameters sent to EPA's ECHO API. For more options see: \url{https://echo.epa.gov/tools/web-services/effluent-charts#!/Effluent_Charts/get_eff_rest_services_get_effluent_chart}
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

  ## check connectivity
  if (!isTRUE(check_connectivity())) {
    return(invisible(NULL))
  }

  ## should check if character and return error if not
  p_id <- paste0("p_id=", p_id)

  ## returns a list of arguments supplied by user
  valuesList <- readEchoGetDots(...)

  ## check if user includes an output argument in dots if included, strip it
  ## out
  valuesList <- exclude(valuesList, "output")

  ## generate the intial query
  queryDots <- queryList(valuesList)

  ## build the request URL statement and download csv as df
  buildOutput <- downloadEffluentChart(p_id = p_id, verbose = verbose, queryDots = queryDots)

  return(buildOutput)

}



downloadEffluentChart <- function(p_id, verbose, queryDots) {
  ## build the request URL statement
  path <- "echo/eff_rest_services.download_effluent_chart"
  query <- paste(p_id, queryDots, sep = "&")
  getURL <- requestURL(path = path, query = query)

  ## Make the request
  request <- httr::RETRY("GET",
                         url = getURL,
                         httr::accept("text/csv"))

  ## Check for valid response for serve, else prints a message and
  ## returns an invisible NULL
  if (!isTRUE(resp_check(request)))
  {
    return(invisible(NULL))
  }

  ## Print status message
  if (isTRUE(verbose)) {
    message("The formatted URL is: ", getURL)
    message(httr::http_status(request))
  }

  info <- httr::content(request, as = "raw")

  info <- readr::read_csv(info, col_names = TRUE,
                          col_types = readr::cols(
                            .default = readr::col_character()
                          ),
                          na = " ",
                          locale = readr::locale(date_format = "%m/%d/%Y"),
                          progress = FALSE, skip_empty_rows = FALSE)
  return(info)
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

  ## check connectivity
  if (!isTRUE(check_connectivity())) {
    return(invisible(NULL))
  }

  request <- httr::RETRY("GET",
                         url = getURL,
                         httr::accept_json())

  ## Check for valid response for serve, else prints a message and
  ## returns an invisible NULL
  if (!isTRUE(resp_check(request)))
  {
    return(invisible(NULL))
  }

  if (isTRUE(verbose)) {
    message("Request URL:", getURL)
    message(httr::http_status(request))
  }

  info <- httr::content(request)

  buildOutput <- purrr::map_df(info[["Results"]][["LuValues"]],
                               safe_extract,
                               c("ValueCode", "ValueDescription"))

  return(buildOutput)
}
