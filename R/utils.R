
readEchoGetDots <- function(...){

  if(length(list(...)) == 0){
    stop("No arguments supplied")
  }

  matchReturn <- convertLists(...)

  if(anyNA(unlist(matchReturn))){
    stop("NA's are not allowed in query")
  }

  values <- sapply(matchReturn, function(x) as.character(paste(eval(x),collapse=",",sep="")))
  values
}


convertLists <- function(...){
  matchReturn <- c(do.call("c",list(...)[sapply(list(...), class) == "list"]), #get the list parts
                   list(...)[sapply(list(...), class) != "list"]) # get the non-list parts
  return(matchReturn)

}


#' Internal function to safely map a dataframe from a nested list with NULL values
#'
#' @param l
#' @param wut
#'

safe_extract <- function(l, wut) {
  res <- l[wut]
  null_here <- purrr::map_lgl(res, is.null)
  res[null_here] <- NA
  res
}
