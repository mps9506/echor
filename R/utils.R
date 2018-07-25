

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
                                   hostname = "ofmpub.epa.gov",
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
#' @importFrom httr GET content accept_json
#' @importFrom readr read_csv locale
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
  request <- httr::GET(getURL)

  info <- httr::content(request, as = "raw")

  info <- readr::read_csv(info, col_names = TRUE,
                  col_types = col_types,
                  na = " ",
                  locale = readr::locale(date_format = "%m/%d/%Y"))

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
  output <- sf::read_sf(t)
  unlink(t)
  return(output)
}



# Specify column types to parse -------------------------------------------

columnsToParse <- function(program, colNums) {

  if (program == "caa") {
    meta <- httr::content(httr::GET(url = "https:///ofmpub.epa.gov/echo/air_rest_services.metadata?output=JSON"))
  } else if (program == "cwa") {
    meta <- httr::content(httr::GET(url = "https:///ofmpub.epa.gov/echo/cwa_rest_services.metadata?output=JSON"))
  } else if (program == "sdw") {
    meta <- httr::content(httr::GET(url = "https:///ofmpub.epa.gov/echo/sdw_rest_services.metadata?output=JSON"))
  } else {
    stop("Incorrect argument specified in columnsToParse(). program should be a character == to 'caa', 'cwa', or 'sdw'")}

  col_types <- purrr::map(meta[["Results"]][["ResultColumns"]], "DataType")[c(colNums)]
  col_types <- unlist(col_types)
  col_types <- recode(col_types, " 'VARCHAR2' = 'c';
                             'CHAR' = 'c';
                             'NUMBER' = 'n';
                             'DATE' = 'D'")
  col_types <- paste(col_types, sep = "", collapse = "")
  }



# recode ------------------------------------------------------------------


## borrowed from car package https://github.com/cran/car
recode <- function(var, recodes, as.factor, as.numeric = TRUE, levels){
  lo <- -Inf
  hi <- Inf
  recodes <- gsub("\n|\t", " ", recodes)
  recode.list <- rev(strsplit(recodes, ";")[[1]])
  is.fac <- is.factor(var)
  if (missing(as.factor)) as.factor <- is.fac
  if (is.fac) var <- as.character(var)
  result <- var
  for (term in recode.list) {
    if (0 < length(grep(":", term))) {
      range <- strsplit(strsplit(term, "=")[[1]][1],":")
      low <- try(eval(parse(text = range[[1]][1])), silent = TRUE)
      if (class(low) == "try-error") {
        stop("\n  in recode term: ", term,
             "\n  message: ", low)
      }
      high <- try(eval(parse(text = range[[1]][2])), silent = TRUE)
      if (class(high) == "try-error") {
        stop("\n  in recode term: ", term,
             "\n  message: ", high)
      }
      target <- try(eval(parse(text = strsplit(term, "=")[[1]][2])), silent = TRUE)
      if (class(target) == "try-error") {
        stop("\n  in recode term: ", term,
             "\n  message: ", target)
      }
      result[(var >= low) & (var <= high)] <- target
    }
    else if (0 < length(grep("^else=", squeezeBlanks(term)))) {
      target <- try(eval(parse(text = strsplit(term, "=")[[1]][2])), silent = TRUE)
      if (class(target) == "try-error") {
        stop("\n  in recode term: ", term,
             "\n  message: ", target)
      }
      result[1:length(var)] <- target
    }
    else {
      set <- try(eval(parse(text = strsplit(term, "=")[[1]][1])), silent = TRUE)
      if (class(set) == "try-error") {
        stop("\n  in recode term: ", term,
             "\n  message: ", set)
      }
      target <- try(eval(parse(text = strsplit(term, "=")[[1]][2])), silent = TRUE)
      if (class(target) == "try-error") {
        stop("\n  in recode term: ", term,
             "\n  message: ", target)
      }
      for (val in set) {
        if (is.na(val)) result[is.na(var)] <- target
        else result[var == val] <- target
      }
    }
  }
  if (as.factor) {
    result <- if (!missing(levels)) factor(result, levels = levels)
    else as.factor(result)
  }
  else if (as.numeric && (!is.numeric(result))) {
    result.valid <- na.omit(result)
    opt <- options("warn" = -1)
    result.valid <- as.numeric(result.valid)
    options(opt)
    if (!any(is.na(result.valid))) result <- as.numeric(result)
  }
  result
}

## borrowed from car package https://github.com/cran/car
squeezeBlanks <- function(text){
  gsub(" *", "",  text)
}
