
# downloadDMRs ------------------------------------------------------------


#' Title
#'
#' @param df dataframe with column of id numbers
#' @param nColumn unquoted string, name of column containing the p_id permit numbers
#' @param pBar logical, display a progress bar? Defaults to TRUE
#' @param ... additional arguments passed to echoGetEffluentSummary
#'
#' @import dplyr
#' @import rlang
#' @return dataframe df, with a column containing the discharge monitoring reports downloaded with echoGetEffluentSummary
#' @export

downloadDMRs <- function(df, nColumn, pBar = TRUE, ...) {

  nColumn <- enquo(nColumn)
  data <- select(df, !!nColumn)

  if (isTRUE(pBar)) {
    # create the progress bar with a dplyr function.
    pb <- progress_estimated(nrow(df))

    df <- df %>%
      mutate(dmr = purrr::pmap(data,
                               ~ {
                                 # update the progress bar (tick()) and print progress (print())
                                 pb$tick()$print()


                                 echoGetEffluentSummary(p_id = ..1,
                                                        ...)
                               }, ...))
  }

  else {
    df <- df %>%
      mutate(dmr = purrr::pmap(data,
                               ~ {
                                 echoGetEffluentSummary(p_id = ..1,
                                                        ...)
                               }, ...))
  }

  return(df)
}
