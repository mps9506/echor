
# echoAirGetFacilityInfo --------------------------------------------------

#' Downloads EPA ECHO permitted air emitter information
#'
#' Returns a dataframe or simplefeature dataframe of permitted facilities returned by the query.
#' Uses EPA's ECHO API: \url{https://echo.epa.gov/tools/web-services/facility-search-air#!/Facilities/get_air_rest_services_get_facility_info}
#' @param output Character string specifying output format. \code{output = 'df'} for a dataframe or \code{output = 'sf'} for a simple features spatial dataframe. See (\url{https://CRAN.R-project.org/package=sf}) for more information about simple features.
#' @param verbose Logical, indicating whether to provide processing and retrieval messages. Defaults to FALSE
#' @param ... Further arguments passed as query parameters in request sent to EPA ECHO's API. For more options see: \url{https://echo.epa.gov/tools/web-services/facility-search-water#!/Facility_Information/get_air_rest_services_get_facility_info} for a complete list of parameter options. Examples provided below.
#' @import httr
#' @importFrom sf st_read
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
    qcolumns <- c(1:5,22,23)
    qcolumns <- paste(as.character(qcolumns), collapse = ",")
    valuesList[["qcolumns"]] <- qcolumns
  }

  # check if 1 and 2 are in, if not, insert and order
  valuesList <- insertQColumns(valuesList)

  ## generate query the will be pasted into GET URL
  queryDots <- queryList(valuesList)

  ## build the request URL statement
  path <- "echo/air_rest_services.get_facility_info"
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

  ## Print status message, need to make this optional
  if (isTRUE(verbose)) {
    message("Request URL:", getURL)
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

  ## Find out column types so they are parsed correctly
  colNums <- unlist(strsplit(valuesList[["qcolumns"]], split = ","))
  colNums <- as.numeric(colNums)

  colTypes <- columnsToParse(program = "caa", colNums)

  ## if df return output from air_rest_services.get_download
  if (output == "df") {

    if (n_records <= 100000) {

      buildOutput <- getDownload("caa",
                                 qid,
                                 qcolumns,
                                 col_types = colTypes)
    } else {

      # number of pages returned is n_records/5000
      pages <- ceiling(n_records/5000)
      # create the progress bar
      pb <- progress_bar$new(total = pages)

      buildOutput <- getQID("caa",
                            qid,
                            qcolumns,
                            page = 1)
      pb$tick()

      for (i in 2:pages) {
        buildOutput <- bind_rows(buildOutput,
                                 getQID("caa",
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

    ## if returns clusters, there are to many records to
    ## return records via geojson and the request needs to
    ## be more specific. I'm not sure how many records are too
    ## many. If the length of facilities == 0, it means
    ## the query either return no records, or the request returned
    ## clusters and we can stop the function and return a message.
    if(length(info[["Results"]][["Facilities"]]) == 0) {
      if(n_records > 0) {
        stop("Too many records to return spatial a object, please subset your request and try again.")
      }
      if(n_records == 0) {
        stop("No records returned in your request")
      }
    }

    buildOutput <- getGeoJson("caa",
                              qid,
                              qcolumns)
    if(is.null(buildOutput)) {
      return(invisible(NULL))
    }
    ## Convert to sf dataframe
    buildOutput <- sf::st_read(buildOutput)

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

  ## check connectivity
  if (!isTRUE(check_connectivity())) {
    return(invisible(NULL))
  }

  ## build the request URL statement
  path <- "echo/air_rest_services.metadata?output=JSON"
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


# echoGetcaapr ------------------------------------------------------------

#' Download EPA ECHO emissions inventory report data
#'
#' @param p_id character string specify the identifier for the service. Required.
#' @param verbose Logical, indicating whether to provide processing and retrieval messages. Defaults to FALSE
#' @param ... Additional arguments
#' @importFrom purrr map_df
#' @importFrom tidyr gather_ pivot_longer
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

  ## check connectivity
  if (!isTRUE(check_connectivity())) {
    return(invisible(NULL))
  }

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

  ## check connectivity
  if (!isTRUE(check_connectivity())) {
    return(invisible(NULL))
  }

  ## build the request URL statement
  path <- "echo/caa_poll_rpt_rest_services.get_caapr"
  query <- paste(p_id, queryDots, sep = "&")
  getURL <- requestURL(path = path, query = query)

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
  #     pollutant <- tidyr::gather_(pollutant, "Year", "Discharge", c("Year1",
  #                                                                   "Year2",
  #                                                                   "Year3",
  #                                                                   "Year4",
  #                                                                   "Year5",
  #                                                                   "Year6",
  #                                                                   "Year7",
  #                                                                   "Year8",
  #                                                                   "Year9",
  #                                                                   "Year10"))
  pollutant <- tidyr::pivot_longer(pollutant,
                                   cols = -c("Pollutant", "UnitsOfMeasure", "Program"),
                                   names_to = "Year",
                                   values_to = "Discharge")


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


  ## I should refactor this
  Name <- if(is.null(info[["Results"]][["CAAPollRpt"]][["RegistryIDs"]][[1]][["FacilityName"]])) {
    NA_character_
  } else {
    info[["Results"]][["CAAPollRpt"]][["RegistryIDs"]][[1]][["FacilityName"]]
  }
  SourceID <- if(is.null(info[["Results"]][["CAAPollRpt"]][["RegistryIDs"]][[1]][["SourceId"]])) {
    NA_character_
  } else {
    info[["Results"]][["CAAPollRpt"]][["RegistryIDs"]][[1]][["SourceId"]]
  }
  Street <- if(is.null(info[["Results"]][["CAAPollRpt"]][["RegistryIDs"]][[1]][["Street"]])) {
    NA_character_
  } else {
    info[["Results"]][["CAAPollRpt"]][["RegistryIDs"]][[1]][["Street"]]
  }
  City <- if(is.null(info[["Results"]][["CAAPollRpt"]][["RegistryIDs"]][[1]][["City"]])) {
    NA_character_
  } else {
    info[["Results"]][["CAAPollRpt"]][["RegistryIDs"]][[1]][["City"]]
  }
  State <- if(is.null(info[["Results"]][["CAAPollRpt"]][["RegistryIDs"]][[1]][["State"]])) {
    NA_character_
  } else{
    info[["Results"]][["CAAPollRpt"]][["RegistryIDs"]][[1]][["State"]]
  }
  Zip <- if(is.null(info[["Results"]][["CAAPollRpt"]][["RegistryIDs"]][[1]][["Zip"]])) {
    NA_character_
  } else {
    info[["Results"]][["CAAPollRpt"]][["RegistryIDs"]][[1]][["Zip"]]
  }
  County <- if(is.null(info[["Results"]][["CAAPollRpt"]][["RegistryIDs"]][[1]][["County"]])) {
    NA_character_
  } else {
    info[["Results"]][["CAAPollRpt"]][["RegistryIDs"]][[1]][["County"]]
  }
  Region <- if(is.null(info[["Results"]][["CAAPollRpt"]][["RegistryIDs"]][[1]][["Region"]])) {
    NA_character_
  } else {
    info[["Results"]][["CAAPollRpt"]][["RegistryIDs"]][[1]][["Region"]]
  }
  Latitude <- if(is.null(info[["Results"]][["CAAPollRpt"]][["RegistryIDs"]][[1]][["Latitude"]])) {
    NA
  } else {
    info[["Results"]][["CAAPollRpt"]][["RegistryIDs"]][[1]][["Latitude"]]
  }
  Longitude <- if(is.null(info[["Results"]][["CAAPollRpt"]][["RegistryIDs"]][[1]][["Longitude"]])) {
    NA
  } else {
    info[["Results"]][["CAAPollRpt"]][["RegistryIDs"]][[1]][["Longitude"]]
  }

  ## build output dataframe
  buildOutput <- tibble::tibble(
    Name = Name,
    SourceID = SourceID,
    Street = Street,
    City = City,
    State = State,
    Zip = Zip,
    County = County,
    Region = Region,
    Latitude = as.numeric(Latitude),
    Longitude = as.numeric(Longitude),
    Pollutant = as.factor(pollutant$Pollutant),
    UnitsOfMeasure = as.factor(pollutant$UnitsOfMeasure),
    Program = as.factor(pollutant$Program),
    Year = as.integer(pollutant$Year),
    Discharge = as.numeric(gsub(",", "", pollutant$Discharge))
  )

  return(buildOutput)

}
