#' Downloads self reported discharge and emissions data
#'
#' @param program Character, one of \code{program = 'caa'}, \code{program = 'cwa'}, or \code{program = 'nncr'}. \code{'caa'} retrieves facilities permitted under the Clean Air Act, \code{'cwa'} retrieves facilities permitted under the Clean Water Act, and \code{'nncr'} retrieves NPDES Noncompliance Report (NNCR) data for a facility or NPDES permit.
#' @param p_id Character string specify the identifier for the service. For \code{program = 'nncr'}, this is treated as the NPDES permit ID (\code{permits__npdes_id}). Required.
#' @param verbose Logical, indicating whether to provide processing and retrieval messages. Defaults to FALSE.
#' @param ... Further arguments passed on as query parameters sent to EPA's ECHO API.
#'
#' @return Returns a dataframe
#' @export
echoGetReports <- function(program, p_id, verbose = FALSE, ...) {
  if (program == "caa") {

    echoGetCAAPR(p_id = p_id, verbose = verbose, ...)

  } else if (program == "cwa") {

    echoGetEffluent(p_id = p_id, verbose = verbose, ...)

  } else if (program == "nncr") {

    echoNNCRGetReport(permits__npdes_id = p_id, verbose = verbose, ...)

  } else {

    stop("the argument 'program' must be specified as one of 'caa', 'cwa', or 'nncr' ")

  }
}
