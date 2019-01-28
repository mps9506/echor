
# downloadDMRs ------------------------------------------------------------


#' Download Multiple DMRs
#'
#' Returns DMRs in a nested list using \code{echoGetEffluent()}. Uses a dataframe with a column of p_id numbers
#' @param df dataframe with column of id numbers
#' @param idColumn unquoted string, name of column containing the p_id permit numbers
#' @param pBar logical, display a progress bar? Defaults to TRUE
#' @param ... additional arguments passed to echoGetEffluent
#'
#' @import dplyr
#' @import rlang
#' @return dataframe df, with a column containing the discharge monitoring reports downloaded with echoGetEffluentSummary
#' @export
#' @examples \donttest{
#' ## This example requires an internet connection to run
#'
#' ## Retrieve multiple DMRs for flow
#'
#' df <- data.frame("p_id" = c('tx0119407', 'tx0132187', 'tx040237'))
#' df <- downloadDMRs(df, p_id)
#' }

downloadDMRs <- function(df, idColumn, pBar = TRUE, ...) {

  idColumn <- enquo(idColumn)
  data <- select(df, !!idColumn)

  if (isTRUE(pBar)) {
    # create the progress bar with a dplyr function.
    pb <- progress_estimated(nrow(df))

    df <- df %>%
      mutate(dmr = purrr::pmap(data,
                               ~ {
                                 # update the progress bar (tick()) and print progress (print())
                                 pb$tick()$print()


                                 echoGetEffluent(p_id = ..1,
                                                        ...)
                               }, ...))
  }

  else {
    df <- df %>%
      mutate(dmr = purrr::pmap(data,
                               ~ {
                                 echoGetEffluent(p_id = ..1,
                                                        ...)
                               }, ...))
  }

  return(df)
}
