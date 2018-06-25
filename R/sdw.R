
# echoSDWGetMeta ------------------------------------------------------


#' Downloads EPA ECHO Safe Drinking Water Facilities Metadata
#'
#'
#' @param verbose Logical, indicating whether to provide processing and retrieval messages. Defaults to FALSE
#'
#' @return returns a dataframe
#' @export
#'
#' @examples \donttest{
#' ## These examples require an internet connection to run
#'
#' # returns a dataframe of
#' echoSDWGetMeta()
#' }
echoSDWGetMeta <- function(verbose = FALSE){

  ## build the request URL statement
  path <- "echo/sdw_rest_services.metadata?output=JSON"
  getURL <- requestURL(path = path, query = NULL)

  ## Make the request
  request <- GET(getURL, accept_json())

  ## Print status message, need to make this optional
  if (verbose) {
    message("Request URL:", getURL)
    message(http_status(request))
  }

  info <- content(request)
  info

  ## build the output
  buildOutput <- purrr::map_df(info[["Results"]][["ResultColumns"]],
                               safe_extract,
                               c("ColumnName", "DataType", "DataLength",
                                 "ColumnID", "ObjectName", "Description"))

  return(buildOutput)
}



# echoSDWGetSystems -------------------------------------------------------

#' Downloads public water system information
#'
#' Returns a dataframe of permitted public water systems returned by the query.
#' Uses EPA's ECHO API: \url{https://echo.epa.gov/tools/web-services/facility-search-drinking-water#!/Safe_Drinking_Water/get_sdw_rest_services_get_systems}.
#' @param verbose Logical, indicating whether to provide processing and retrieval messages. Defaults to FALSE
#' @param ... Further arguments passed as query parameters in request sent to EPA ECHO's API. For more options see: \url{https://echo.epa.gov/tools/web-services/facility-search-drinking-water#!/Safe_Drinking_Water/get_sdw_rest_services_get_systems} for a complete list of parameter options. Examples provided below.
#'
#' @return returns a dataframe
#' @export
#'
#' @examples \donttest{
#' ## These examples require an internet connection to run
#' echoSDWGetSystems(p_co = "Brazos", p_st = "tx)
#' }
echoSDWGetSystems <- function(verbose = FALSE, ...) {
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
    qcolumns <- c(1:66)
    qcolumns <- paste(as.character(qcolumns), collapse = ",")
    valuesList[["qcolumns"]] <- qcolumns
  }

  ## generate query the will be pasted into GET URL
  queryDots <- queryList(valuesList)

  ## build the request URL statement
  path <- "echo/sdw_rest_services.get_systems"
  query <- paste("output=JSON", queryDots, sep = "&")
  getURL <- requestURL(path = path, query = query)

  ## Make the request
  request <- GET(getURL, accept_json())

  ## Print status message, need to make this optional
  if (verbose) {
    message("Request URL:", getURL)
    message(http_status(request))
  }

  info <- content(request)

  qid <- info[["Results"]][["QueryID"]]

  ## get qcolumns argument specific to this query
  qcolumns <- queryList(valuesList["qcolumns"])

  ## call new function get_qid
  buildOutput <- getDownload(service = "sdw",
                             qid = qid,
                             qcolumns = qcolumns)
  return(buildOutput)
}
