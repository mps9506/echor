
# NNCR helpers ================================================================
#
# The NPDES Noncompliance Report (NNCR) REST services are a newer, separate
# service group from the classic QID-based ECHO REST services used elsewhere
# in this package (e.g. cwa_rest_services). They live under
# echo/nncr_services/ on the same echodata.epa.gov host, return JSON directly
# (no output=JSON/qcolumns machinery), and use Django-style field lookups
# (e.g. permit_state, permit_state__in, permit_state__icontains) along with
# limit/offset pagination (`count`, `next`, `previous`, `data`).

#' Build a request URL for an NNCR REST service path
#'
#' @param path Character string, the NNCR service path, e.g. `"search/"`.
#' @param query Character string or `NULL`, the query string to append.
#' @importFrom httr build_url
#' @return URL used in the httr call
#' @keywords internal
#' @noRd
nncrRequestURL <- function(path, query = NULL) {
  requestURL(path = paste0("echo/nncr_services/", path), query = query)
}

#' GET a single page from an NNCR REST service
#'
#' @param getURL Character string, a fully formed request URL.
#' @param verbose Logical, whether to print status messages.
#' @import httr
#' @return A parsed list (from JSON) on success, or `NULL` (invisibly) on failure.
#' @keywords internal
#' @noRd
nncrGetPage <- function(getURL, verbose = FALSE) {
  request <- httr::RETRY("GET", url = getURL, httr::accept_json())

  if (isTRUE(verbose)) {
    message("The formatted URL is: ", getURL)
    message(httr::http_status(request))
  }

  if (!(request$status_code %in% c(200, 202))) {
    info <- tryCatch(httr::content(request), error = function(e) NULL)
    if (!is.null(info) && !is.null(info$status)) {
      message(info$status)
    } else {
      resp_check(request)
    }
    return(invisible(NULL))
  }

  httr::content(request)
}

#' Download all pages of results from an NNCR REST service
#'
#' Follows the `next` link returned by the service (limit/offset pagination)
#' until all matching records have been retrieved.
#'
#' @param path Character string, the NNCR service path, e.g. `"search/"`.
#' @param query Character string or `NULL`, the query string to send with the
#'   initial request.
#' @param verbose Logical, whether to print status messages.
#' @return A list of records (each itself a list), or `NULL` (invisibly) on failure.
#' @keywords internal
#' @noRd
nncrGetAllPages <- function(path, query, verbose = FALSE) {
  getURL <- nncrRequestURL(path, query)
  results <- list()

  repeat {
    info <- nncrGetPage(getURL, verbose = verbose)
    if (is.null(info)) {
      return(invisible(NULL))
    }

    results <- c(results, info[["data"]])

    if (is.null(info[["next"]])) {
      break
    }
    getURL <- info[["next"]]
  }

  results
}

#' Coerce a list of NNCR JSON records into a tibble
#'
#' NNCR JSON records mix scalar fields with nested list fields (e.g.
#' \code{permits}, \code{ps_violations}) and use JSON \code{null} for missing
#' scalars, which \code{httr}/\code{jsonlite} parse as R \code{NULL}. Neither
#' of those play well with \code{\link[dplyr]{bind_rows}} directly: a bare
#' \code{NULL} field drops the whole record, and a nested (possibly empty)
#' list field is treated as contributing zero rows instead of a single
#' list-column value. This helper drops \code{NULL} scalar fields (so
#' \code{bind_rows} fills them in as \code{NA} of the appropriate type from
#' other records) and wraps list fields so they become proper list-columns.
#'
#' @param records A list of records (each a named list), as returned by
#'   \code{\link{nncrGetAllPages}}.
#' @importFrom dplyr bind_rows
#' @return A tibble.
#' @keywords internal
#' @noRd
nncrRecordsToTibble <- function(records) {
  prepRecord <- function(x) {
    x <- x[!vapply(x, is.null, logical(1))]
    x[] <- lapply(x, function(v) if (is.list(v)) list(v) else v)
    x
  }
  dplyr::bind_rows(lapply(records, prepRecord))
}


# echoNNCRGetQuarters =========================================================

#' Downloads available NPDES Noncompliance Report (NNCR) fiscal year quarters
#'
#' Returns the fiscal year quarters (`fy_quarter`) available for use with
#' \code{\link{echoNNCRGetSearch}}, \code{\link{echoNNCRGetViolations}}, and
#' \code{\link{echoGetReports}}, along with the quarter's date range and
#' release status. Uses EPA's ECHO API:
#' \url{https://echo.epa.gov/tools/web-services/npdes-noncompliance-report}.
#'
#' @param verbose Logical, indicating whether to provide processing and retrieval messages. Defaults to FALSE.
#' @return Returns a dataframe.
#' @import httr
#' @importFrom dplyr bind_rows
#' @export
#' @examples \donttest{
#' ## This example requires an internet connection to run
#'
#' echoNNCRGetQuarters()
#' }
echoNNCRGetQuarters <- function(verbose = FALSE) {

  ## check connectivity
  if (!isTRUE(check_connectivity())) {
    return(invisible(NULL))
  }

  getURL <- nncrRequestURL("quarters/")
  info <- nncrGetPage(getURL, verbose = verbose)

  if (is.null(info)) {
    return(invisible(NULL))
  }

  nncrRecordsToTibble(info[["data"]])
}


# echoNNCRGetSearch ============================================================

#' Searches the NPDES Noncompliance Report (NNCR)
#'
#' Returns a dataframe of permits and their summarized violation counts for a
#' given fiscal year quarter, matching the search criteria. Uses EPA's ECHO
#' API: \url{https://echo.epa.gov/tools/web-services/npdes-noncompliance-report}.
#' @param verbose Logical, indicating whether to provide processing and retrieval messages. Defaults to FALSE.
#' @param \dots Further arguments passed as query parameters in the request sent
#'   to EPA ECHO's API. \code{fy_quarter} is required; see
#'   \code{echoNNCRGetQuarters} for valid values. For a complete list of
#'   parameter options, including Django-style field lookups such as
#'   \code{permit_state__in} or \code{permit_name__icontains}, see the web
#'   services documentation linked above.
#' @return Returns a dataframe.
#' @import httr
#' @importFrom dplyr bind_rows
#' @seealso \code{\link{echoNNCRGetQuarters}}
#' @export
#' @examples \donttest{
#' ## This example requires an internet connection to run
#'
#' echoNNCRGetSearch(fy_quarter = "FY24Q4", permit_state = "TX")
#' }
echoNNCRGetSearch <- function(verbose = FALSE, ...) {

  ## check connectivity
  if (!isTRUE(check_connectivity())) {
    return(invisible(NULL))
  }

  if (length(list(...)) == 0) {
    stop("No valid arguments supplied")
  }

  valuesList <- readEchoGetDots(...)

  if (!("fy_quarter" %in% names(valuesList))) {
    stop("Argument 'fy_quarter' is required, e.g. fy_quarter = 'FY24Q4'. ",
         "See echoNNCRGetQuarters() for valid values.")
  }

  query <- queryList(valuesList)

  data <- nncrGetAllPages("search/", query = query, verbose = verbose)

  if (is.null(data)) {
    return(invisible(NULL))
  }

  nncrRecordsToTibble(data)
}


# echoNNCRGetViolations ========================================================

#' Downloads detailed NPDES Noncompliance Report (NNCR) violations
#'
#' Returns a dataframe of detailed violation records for a given fiscal year
#' quarter, optionally filtered to a single facility (\code{frs_id}) or NPDES
#' permit (\code{npdes_id}). Uses EPA's ECHO API:
#' \url{https://echo.epa.gov/tools/web-services/npdes-noncompliance-report}.
#' @param verbose Logical, indicating whether to provide processing and retrieval messages. Defaults to FALSE.
#' @param \dots Further arguments passed as query parameters in the request sent
#'   to EPA ECHO's API. \code{fy_quarter} is required; see
#'   \code{echoNNCRGetQuarters} for valid values. For a complete list of
#'   parameter options, see the web services documentation linked above.
#' @return Returns a dataframe.
#' @import httr
#' @importFrom dplyr bind_rows
#' @seealso \code{\link{echoNNCRGetQuarters}}
#' @export
#' @examples \donttest{
#' ## This example requires an internet connection to run
#'
#' echoNNCRGetViolations(fy_quarter = "FY24Q4", npdes_id = "TX0119407")
#' }
echoNNCRGetViolations <- function(verbose = FALSE, ...) {

  ## check connectivity
  if (!isTRUE(check_connectivity())) {
    return(invisible(NULL))
  }

  if (length(list(...)) == 0) {
    stop("No valid arguments supplied")
  }

  valuesList <- readEchoGetDots(...)

  if (!("fy_quarter" %in% names(valuesList))) {
    stop("Argument 'fy_quarter' is required, e.g. fy_quarter = 'FY24Q4'. ",
         "See echoNNCRGetQuarters() for valid values.")
  }

  query <- queryList(valuesList)

  data <- nncrGetAllPages("violations/", query = query, verbose = verbose)

  if (is.null(data)) {
    return(invisible(NULL))
  }

  nncrRecordsToTibble(data)
}


# echoNNCRGetReport ============================================================

#' Downloads a NPDES Noncompliance Report (NNCR) facility/permit report
#'
#' Returns compliance and enforcement history for one or more facilities or
#' NPDES permits at a time, across all available quarters. Uses EPA's ECHO
#' API: \url{https://echo.epa.gov/tools/web-services/npdes-noncompliance-report}.
#' @param verbose Logical, indicating whether to provide processing and retrieval messages. Defaults to FALSE.
#' @param \dots Further arguments passed as query parameters in the request sent
#'   to EPA ECHO's API. One of \code{frs_id}, \code{frs_id__in},
#'   \code{permits__npdes_id}, or \code{permits__npdes_id__in} is required. For
#'   a complete list of parameter options, see the web services documentation
#'   linked above.
#' @return Returns a dataframe. Nested facility, permit, and violation-level
#'   detail returned by the service is preserved as list-columns.
#' @import httr
#' @importFrom dplyr bind_rows
#' @export
#' @examples \donttest{
#' ## This example requires an internet connection to run
#'
#' echoNNCRGetReport(permits__npdes_id = "TX0119407")
#' }
echoNNCRGetReport <- function(verbose = FALSE, ...) {

  ## check connectivity
  if (!isTRUE(check_connectivity())) {
    return(invisible(NULL))
  }

  if (length(list(...)) == 0) {
    stop("No valid arguments supplied")
  }

  valuesList <- readEchoGetDots(...)

  query <- queryList(valuesList)

  data <- nncrGetAllPages("report/", query = query, verbose = verbose)

  if (is.null(data)) {
    return(invisible(NULL))
  }

  nncrRecordsToTibble(data)
}
