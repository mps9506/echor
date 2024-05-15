
# echoSDWGetMeta ------------------------------------------------------


#' Downloads EPA ECHO Safe Drinking Water Facilities Metadata
#'
#'
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
#' echoSDWGetMeta()
#' }
echoSDWGetMeta <- function(verbose = FALSE){

  ## check connectivity
  if (!isTRUE(check_connectivity())) {
    return(invisible(NULL))
  }

  ## build the request URL statement
  path <- "echo/sdw_rest_services.metadata?output=JSON"
  getURL <- requestURL(path = path, query = NULL)

  ## Make the request
  request <- httr::GET(getURL, httr::accept_json())

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



# echoSDWGetSystems -------------------------------------------------------

#' Downloads public water system information
#'
#' Returns a dataframe of permitted public water systems returned by the query.
#' Uses EPA's ECHO API: \url{https://echo.epa.gov/tools/web-services/facility-search-drinking-water#!/Safe_Drinking_Water/get_sdw_rest_services_get_systems}.
#' @param verbose Logical, indicating whether to provide processing and retrieval messages. Defaults to FALSE
#' @param ... Further arguments passed as query parameters in request sent to EPA ECHO's API. For more options see: \url{https://echo.epa.gov/tools/web-services/facility-search-drinking-water#!/Safe_Drinking_Water/get_sdw_rest_services_get_systems} for a complete list of parameter options. Examples provided below.
#' @import httr
#' @import dplyr
#' @return returns a dataframe
#' @export
#'
#' @examples \donttest{
#' ## These examples require an internet connection to run
#' echoSDWGetSystems(p_co = "Brazos", p_st = "tx")
#' }
echoSDWGetSystems <- function(verbose = FALSE, ...) {

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
    qcolumns <- c(1:76)
    qcolumns <- paste(as.character(qcolumns), collapse = ",")
    valuesList[["qcolumns"]] <- qcolumns
  }

  # check if 1 and 2 are in, if not, insert and order
  valuesList <- insertQColumns(valuesList)

  ## generate query the will be pasted into GET URL
  queryDots <- queryList(valuesList)

  ## build the request URL statement
  path <- "echo/sdw_rest_services.get_systems"
  ## responseset is the maximum number of records return on one page of paginated
  ## results
  responseSet <- 1000
  baseParams <- paste("output=JSON", paste0("responseset=",responseSet), sep="&")
  query <- paste(baseParams, queryDots, sep = "&")
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

  ## Print status message, need to make this optional
  if (isTRUE(verbose)) {
    message("Request URL:", getURL)
    message(httr::http_status(request))
  }

  info <- httr::content(request)

  ## if query returns an error message, print message and return invisible null
  if(length(info$Results$Error$ErrorMessage)>0){
    message(info$Results$Error$ErrorMessage)
    return(invisible(NULL))
  }


  ## return the query id
  qid <- info[["Results"]][["QueryID"]]

  ## return the number of records
  n_records <- info[["Results"]][["QueryRows"]]
  n_records <- as.numeric(n_records)

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

  colTypes <- columnsToParse(program = "sdw", colNums)


  buildOutput <- getDownload("sdw",
                             qid,
                             qcolumns,
                             col_types = colTypes)
  return(buildOutput)
}
