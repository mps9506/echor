

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

#' Safely handle nulls
#'
#' @param l list
#' @param wut element
#' @importFrom purrr map_lgl
#' @keywords internal
#' @noRd
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
#' @importFrom httr build_url
#' @return URL used in the httr call
#' @keywords internal
#' @noRd
requestURL <- function(path, query) {

    urlBuildList <- structure(list(scheme = "https",
                                   hostname = "echodata.epa.gov",
        port = NULL, path = path, query = query), class = "url")
    return(httr::build_url(urlBuildList))
}

#' Returns comma deliminated data from get.download endpoints
#'
#' @param service character string. One of "sdw", "cwa", or "caa"
#' @param qid character string. Query identifier.
#' @param qcolumns character string, specifies columns returned in query.
#' @param col_types One of NULL, a cols() specification, or a string.
#'
#' @return Returns a dataframe
#' @import httr
#' @importFrom readr read_csv locale
#' @importFrom rlang is_error
#' @keywords internal
#' @noRd
getDownload <- function(service, qid, qcolumns, col_types = NULL) {
  ## build the request URL statement
  if (service == "sdw") {
  path <- "echo/sdw_rest_services.get_download"
  } else if (service == "cwa") {
    path <- "echo/cwa_rest_services.get_download"
  } else if (service == "caa") {
    path <- "echo/air_rest_services.get_download"
  } else {
    stop("internal error in getDownload, incorrect service argument supplied")
  }
  qid <- paste0("qid=", qid)
  query <- paste(qid, qcolumns, sep = "&")
  getURL <- requestURL(path = path, query = query)

  ## Make the request
  request <- httr::RETRY("GET", getURL)


  ## Check for valid response for serve, else returns error
  resp_check(request)

  info <- httr::content(request, as = "raw")

  info <- readr::read_csv(info, col_names = TRUE,
                  col_types = col_types,
                  #na = " ", ## new readr seems to parse this correctly
                  locale = readr::locale(date_format = "%m/%d/%Y"))

  return(info)
}

#' Return paginated data from get_qid endpoint
#'
#'
#' @return a dataframe
#'
#' @keywords internal
#' @importFrom tidyr unnest_wider
#' @noRd
getQID <-function(service, qid, qcolumns, page) {
  ## build the request URL statement
  if (service == "sdw") {
    path <- "echo/sdw_rest_services.get_qid"
  } else if (service == "cwa") {
    path <- "echo/cwa_rest_services.get_qid"
  } else if (service == "caa") {
    path <- "echo/air_rest_services.get_qid"
  } else {
    stop("internal error in getQID, incorrect service argument supplied")
  }
  qid <- paste0("qid=", qid)
  page <- paste0("pageno=", page)
  query <- paste(qid, page, qcolumns, sep = "&")
  getURL <- requestURL(path = path, query = query)

  ## Make the request
  request <- httr::RETRY("GET",
                         url = getURL,
                         httr::accept_json())


  ## Check for valid response for serve, else returns error
  resp_check(request)

  info <- httr::content(request)

  ## rectangle info
  info <- as_tibble(info$Results)
  ## select data we want to return
  info <- select(info, "Facilities")
  ## rectangle the nested response
  info <- unnest_wider(info, "Facilities")
  return(info)
}

#' Returns geojson from get.geojson endpoints
#'
#' @param service character string. One of "cwa", or "caa"
#' @param qid character string. Query identifier.
#' @param qcolumns character string, specifies columns returned in query.
#'
#' @return Returns a dataframe
#' @import httr
#' @importFrom readr read_csv locale
#' @keywords internal
#' @noRd
getGeoJson <- function(service, qid, qcolumns) {
  ## build the request URL statement
  if (service == "cwa") {
    path <- "echo/cwa_rest_services.get_geojson"
  } else if (service == "caa") {
    path <- "echo/air_rest_services.get_geojson"
  } else {
    stop("internal error in getDownload, incorrect service argument supplied")
  }
  qid <- paste0("qid=", qid)
  query <- paste(qid, qcolumns, sep = "&")
  getURL <- requestURL(path = path, query = query)

  ## Make the request
  request <- httr::RETRY("GET", getURL)

  ## Check for valid response for serve, else prints a message and
  ## returns an invisible NULL
  if (!isTRUE(resp_check(request)))
  {
    return(invisible(NULL))
  }

  info <- httr::content(request, as = "text", encoding = "UTF-8")

  return(info)
}

# Clean up qcolumns ------------------------------------------------------

insertQColumns <- function(valuesList) {

  qcolumns <- unlist(strsplit(valuesList[["qcolumns"]], split = ","))
  # unlist qcolumns into a numeric vector
  # check if 1 and 2 are in, if not, insert and order
  if (!1 %in% qcolumns) { qcolumns <- append(qcolumns, 1)}
  if (!2 %in% qcolumns) { qcolumns <- append(qcolumns, 2)}
  qcolumns <- as.character(sort(as.numeric(qcolumns)))

  qcolumns <- paste(as.character(qcolumns), collapse = ",")

  valuesList[["qcolumns"]] <- qcolumns

  return(valuesList)
}




# Specify column types to parse -------------------------------------------

#' Create character vector to parse columns
#'
#' @param program character
#' @param colNums qcolumns
#'
#' @import httr
#' @importFrom plyr mapvalues
#' @importFrom purrr map
#' @noRd
#' @keywords internal
columnsToParse <- function(program, colNums) {

  if (program == "caa") {
    meta <- httr::content(httr::GET(url = "https://echodata.epa.gov/echo/air_rest_services.metadata?output=JSON"))
  } else if (program == "cwa") {
    meta <- httr::content(httr::GET(url = "https://echodata.epa.gov/echo/cwa_rest_services.metadata?output=JSON"))
  } else if (program == "sdw") {
    meta <- httr::content(httr::GET(url = "https://echodata.epa.gov/echo/sdw_rest_services.metadata?output=JSON"))
  } else {
    stop("Incorrect argument specified in columnsToParse(). program should be a character == to 'caa', 'cwa', or 'sdw'")}

  col_types <- purrr::map(meta[["Results"]][["ResultColumns"]], "DataType")[c(colNums)]
  col_types <- unlist(col_types)
  col_types <- plyr::mapvalues(col_types, from = c("VARCHAR2", "CHAR", "NUMBER", "DATE"),
                               to = c("c", "c", "d", "D"),
                               warn_missing = FALSE)
  col_types <- paste(col_types, sep = "", collapse = "")
  return(col_types)
}


#' Check responses
#'
#' Checks for valid server response and passes silently or produces a
#' useful message.
#' @param response response a [httr::GET()] request result returned from the API
#'
#' @return nothing if check is passed, or an informative message if not passed.
#' @keywords internal
resp_check <- function(response) {

  ## note that this was changed from stopping and providing an
  ## error to passing an invisible response to comply with CRAN.
  ## I'd prefer for this to stop with an error message here, but I
  ## don't make the rules.

  ## httr message_for_status to do all this
  ## but this function allows some more
  ## informative messages to be created

  if(response$status_code == 202 | response$status_code == 200) {
    return(TRUE) #all good!
  }
  else if(response$status_code == 413) {
    message("Payload too large, shorten request.")
    return(FALSE)
  }
  else if(response$status_code == 429) {
    message("Too many requests. Please wait.")
    return(FALSE)
  }
  else if(response$status_code == 500) {
    message("There was a server error, try again later.")
    return(FALSE)
  }
  else if(response$status_code == 503) {
    message("The service is unavailable, try again later.")
    return(FALSE)
  }
  else {
    message_for_status(response)
    return(FALSE)
  }
}



#' Check connectivity
#'
#' @param host a string with a hostname
#'
#' @return logical value
#' @keywords internal
#' @noRd
#' @importFrom curl nslookup
has_internet_2 <- function(host) {
  !is.null(nslookup(host, error = FALSE))
}


check_connectivity <- function() {
  ## check connectivity
  if (!has_internet_2("echodata.epa.gov")) {
    message("No connection to echodata.epa.gov available")
    return(invisible(NULL))
  } else {TRUE}
}
