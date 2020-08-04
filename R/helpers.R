
# downloadDMRs ------------------------------------------------------------


#' Download Multiple DMRs
#'
#' Returns DMRs in a nested list using \code{echoGetEffluent()}. Uses a dataframe with a column of p_id numbers. Please note that p_id's are case sensitive.
#' @param df dataframe with column of id numbers
#' @param idColumn unquoted string, name of column containing the p_id permit numbers
#' @param pBar logical, display a progress bar? Defaults to TRUE
#' @param verbose logical, indicating whether to provide processing and retrieval messages. Defaults to FALSE. Suggest leaving this FALSE if \code{pBar = TRUE}.
#' @param ... additional arguments passed to echoGetEffluent
#'
#' @import dplyr
#' @import rlang
#' @importFrom tibble as_tibble
#' @importFrom tibble is_tibble
#' @return dataframe df, with a column containing the discharge monitoring reports downloaded with echoGetEffluentSummary
#' @export
#' @examples \donttest{
#' ## This example requires an internet connection to run
#'
#' ## Retrieve multiple DMRs for flow
#'
#' df <- tibble::tibble("id" = c('TX0119407', 'TX0132187'))
#' df <- downloadDMRs(df, id)
#' }

downloadDMRs <- function(df,
                         idColumn,
                         pBar = TRUE,
                         verbose = FALSE,
                         ...) {

  ##  check that df is a tibble or data.frame
  if (is.data.frame(df) == FALSE) {
    stop("argument df must be a data.frame or tibble")
  }

  if (tibble::is_tibble(df) == FALSE) {
    ## convert data.frame to tibble
    df <- tibble::as_tibble(df)
  }

  idColumn <- enquo(idColumn)
  data <- select(df, !!idColumn)

  # capture args to pass to echoGetEffluent
  dots_user <- dots_values(...)

  if (isTRUE(pBar)) {
    # create the progress bar with a dplyr function.
    pb <- progress_estimated(nrow(df))

    df <- df %>%
      mutate(dmr = purrr::pmap(data,
                               ~ {
                                 # update the progress bar (tick()) and print progress (print())
                                 pb$tick()$print()

                                 # sleep for 1 sec between calls to keep from ticking off ECHO
                                 Sys.sleep(5)

                                 echoGetEffluent(p_id = .x,
                                                 verbose = verbose,
                                                 dots_user)
                               }))
  }

  else {
    df <- df %>%
      mutate(dmr = purrr::pmap(data,
                               ~ {
                                 # sleep for 1 sec between calls to keep from ticking off ECHO
                                 Sys.sleep(5)

                                 echoGetEffluent(p_id = .x,
                                                 verbose = verbose,
                                                 dots_user)
                               }))
  }

  return(df)
}
