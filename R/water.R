
# echoGetFacilities =========================================================

#' Downloads EPA ECHO facility data
#'
#' \code{echoGetEffluent()} downloads specified wastewater discharge montitoring
#' report data using ECHO API, \code{\link[httr]{GET}}, and \code{jsonlite}.
#'
#' @param \dots see \url{https://echo.epa.gov/tools/web-services/facility-search-water#!/Facility_Information/get_cwa_rest_services_get_facility_info} for a complete list of parameter options. Examples provided below.
#'
#' @return The output will be a tibble of facility details
#' @import httr
#' @import jsonlite
#' @import tibble
#' @return A data frame, the number of variables will depend on the reporting requirements of the retrived plants
#'
#' @export
#' @examples \dontrun{
#' ## Not run:
#' ## Retrieve facilities by bounding box
#' echoGetFacilities(xmin = "-96.407563", ymin = "30.554395", xmax = "-96.25947", ymax = "30.751984")
#' }
#'
echoGetFacilities <- function(...) {

  ## returns a list of arguments supplied by user
  valuesList <- readEchoGetDots(...)

  ## build the request URL statement
  baseURL <- "https://ofmpub.epa.gov/echo/cwa_rest_services.get_facility_info?"
  appendURL <- paste(paste(names(valuesList),valuesList,sep="="),collapse="&")
  getURL <- paste0(baseURL,appendURL)

  ## Make the request
  request <- GET(getURL, accept_json())

  ## Print status message, need to make this optional
  print(paste("# Status message:", http_status(request)))

  ## Download JSON as text
  contentJSON <- content(request, as = "text")

  ## Read JSON into R
  info <- fromJSON(contentJSON,simplifyDataFrame = FALSE)

  ### build the output.
  ### Output will depend on what the state and individual permit report requires.
  ### A better method would be to map the variable names from retrieved plant
  ### and build output from that with map

  len <- purrr::map(info[["Results"]][["Facilities"]], length) # return a list of lengths
  maxIndex <- which.max(len) # if a different number of columns is returned per plant, we want to map values to the longest
  # this might fail if a entirely different columns are returned. Need to find out if there is some
  # consisteny in the returned columns
  cNames <- names(info[["Results"]][["Facilities"]][[maxIndex]])

  ## create the output dataframe
  buildOutput <- purrr::map_df(info[["Results"]][["Facilities"]], safe_extract, cNames)

  return(buildOutput)

}


# echoGetEffluent =========================================================


echoGetEffluent <- function(...) {

  ## returns a list of arguments supplied by user
  valuesList <- readEchoGetDots(...)

  ## build the request URL statement
  baseURL <- "https://ofmpub.epa.gov/echo/eff_rest_services.get_effluent_chart?"
  appendURL <- paste(paste(names(valuesList),valuesList,sep="="),collapse="&")
  getURL <- paste0(baseURL,appendURL,'&output=json')

  request <- GET(getURL, accept_json())
  print(paste("# Status message:", http_status(request)))

  info <- content(request, as = "text")
  return(info)

  ## test <- jsonlite::fromJSON("https://ofmpub.epa.gov/echo/eff_rest_services.get_effluent_chart?p_id=tx0119407&parameter_code=50050&output=JSON")

  ## info <- fromJSON(contentJSON,simplifyDataFrame = FALSE) #read as a JSON

  ### build the output
  ### need to map each outfall
  ## plantInfoColumns <- names(info[["Results"]][2:16])
  ## df1 <- purrr::map_df(info, safe_extract, plantInfoColumns)
  ## return(df1)

}
