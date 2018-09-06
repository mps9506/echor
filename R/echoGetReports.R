#' Downloads self reported discharge and emissions data
#'
#' @param program Character, either \code{program = 'caa'} or \code{program = 'cwa'}. \code{'caa'} retrieves facilities permitted under the Clean Air Act, \code{'cwa'} retreives facilites permitted under the Clean Water Act.
#' @param p_id Character string specify the identifier for the service. Required.
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

  } else {

    stop("the argument 'program' must be specified as one of 'caa' or 'cwa' ")

  }
}
