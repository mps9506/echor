

# Handle dots -------------------------------------------------------------

readEchoGetDots <- function(...) {

    matchReturn <- convertLists(...)

    if (anyNA(unlist(matchReturn))) {
        stop("NA's are not allowed in query")
    }

    values <- sapply(matchReturn,
                     function(x) as.character(paste(eval(x),
                                                    collapse = ",",
        sep = "")))
    values
}


convertLists <- function(...) {
    matchReturn <- c(do.call("c",
                             list(...)[sapply(list(...),
                                              class) == "list"]),
        list(...)[sapply(list(...), class) != "list"])
    return(matchReturn)

}

queryList <- function(valuesList) {
  valuesList <- sapply(valuesList,
                       function(x) utils::URLencode(x,
                                                    reserved = TRUE))
  paste(paste(names(valuesList), valuesList, sep = "="), collapse = "&")
}

exclude <- function(list, names) {
    ## return the elements of the list not belonging to names
    member..names <- names(list)
    index <- which(!(member..names %in% names))
    list[index]
}

# data wrangling ----------------------------------------------------------

## handle NULLs,  Pulled from JennyBC's purrr tutorial originally from Zev Ross
safe_extract <- function(l, wut) {
    res <- l[wut]
    null_here <- purrr::map_lgl(res, is.null)
    res[null_here] <- NA
    res
}



# request urls --------------------------------------------------------------

## builds the request URLs

#' Construct URL used in the httr call
#'
#' @param path Character vector, specifies API path to ECHO's webservices
#' @param query Character vector, specifies the parameters sent in the GET request
#'
#' @return URL used in the httr call
#' @keywords internal
#' @noRd
requestURL <- function(path, query) {

    urlBuildList <- structure(list(scheme = "https",
                                   hostname = "ofmpub.epa.gov",
        port = NULL, path = path, query = query), class = "url")
    return(build_url(urlBuildList))
}

#' Returns comma deliminated data from get.download endpoints
#'
#' @param service character string. One of "sdw", "cwa", or "air"
#' @param qid character string. Query identifier.
#' @param qcolumns character string, specifies columns returned in query.
#'
#' @return Returns a dataframe
#' @keywords internal
#'
#' @examples
getDownload <- function(service, qid, qcolumns) {
  ## build the request URL statement
  if (service == "sdw") {
  path <- "echo/sdw_rest_services.get_download"
  } else if (service == "cwa") {
    path <- "echo/cwa_rest_services.get_download"
  } else if (service == "air") {
    path <- "echo/air_rest_services.get_download"
  } else {
    stop("internal error in getDownload, incorrect service argument supplied")
  }
  qid <- paste0("qid=", qid)
  query <- paste(qid, qcolumns, sep = "&")
  getURL <- requestURL(path = path, query = query)

  ## Make the request
  request <- httr::GET(getURL, accept_json())



  info <- httr::content(request, type = "text/csv")

  return(info)
}
# Convert to sf -----------------------------------------------------------

## reads geojson in and produce the sf dataframe
#' Convert from geojson string to sf dataframe
#'
#' @param x character vector, of geojson format
#'
#' @return simple features dataframe
#' @importFrom sf read_sf
#' @keywords internal
#' @noRd
convertSF <- function(x) {

  t <- tempfile("spoutput", fileext = ".geojson")
  write(x, t)
  output <- read_sf(t)
  return(output)
}
