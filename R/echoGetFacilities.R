#' Downloads permitted facility information
#'
#' Provides interface for downloading facility information from Clean Air Act, Clean Water Act, and Safe Drinking Water Act permitted facilities.
#'
#' @param program Character, either \code{program = 'caa'}, \code{program = 'cwa'}, or \code{program = 'sdw'}. \code{'caa'} retrieves facilities permitted under the Clean Air Act, \code{'cwa'} retreives facilites permitted under the Clean Water Act, and \code{'sdw'} retrives facililtes permitted under the the Safe Drinking Water Act.
#' @param output Character string specifying output format. \code{output = 'df'} for a dataframe or \code{output = 'sf'} for a simple features spatial dataframe. \code{'sf'} only applies to CAA and CWA queries.
#' @param verbose Logical, indicating whether to provide processing and retrieval messages. Defaults to FALSE.
#' @param ... Further arguments passed as query parameters in request sent to EPA ECHO's API.
#'
#' @return dataframe or sf dataframe suitable for plotting
#' @export
echoGetFacilities <- function(program, output = "df", verbose = FALSE, ...) {
  if (program == "caa") {

    echoAirGetFacilityInfo(output = output, verbose = verbose, ...)

    } else if (program == "cwa") {

      echoWaterGetFacilityInfo(output = output, verbose = verbose, ...)

      } else if (program == "sdw") {

        if (output == "sf") {

          stop("if argument 'program' == 'sdw', argument 'output' must == 'df'")

        } else if (output == "df") {

          echoSDWGetSystems(verbose = verbose, ...)
        }

  } else {

    stop("the argument 'program' must be specified as one of 'caa', 'cwa', or 'sdw' ")

    }
}
