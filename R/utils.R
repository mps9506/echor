

# Handle dots -------------------------------------------------------------

readEchoGetDots <- function(...) {
    
    if (length(list(...)) == 0) {
        stop("No arguments supplied")
    }
    
    matchReturn <- convertLists(...)
    
    if (anyNA(unlist(matchReturn))) {
        stop("NA's are not allowed in query")
    }
    
    values <- sapply(matchReturn, function(x) as.character(paste(eval(x), collapse = ",", 
        sep = "")))
    values
}


convertLists <- function(...) {
    matchReturn <- c(do.call("c", list(...)[sapply(list(...), class) == "list"]), 
        list(...)[sapply(list(...), class) != "list"])
    return(matchReturn)
    
}

exclude <- function(list, names) {
    ## return the elements of the list not belonging to names
    member..names <- names(list)
    index <- which(!(member..names %in% names))
    list[index]
}

# data wrangling ----------------------------------------------------------

## handle NULLs - Pulled from JennyBC's purrr tutorial originally from Zev Ross
safe_extract <- function(l, wut) {
    res <- l[wut]
    null_here <- purrr::map_lgl(res, is.null)
    res[null_here] <- NA
    res
}



# request urls --------------------------------------------------------------

## builds the request URLs
requestURL <- function(path, query) {
    
    urlBuildList <- structure(list(scheme = "https", hostname = "ofmpub.epa.gov", 
        port = NULL, path = path, query = query), class = "url")
    return(build_url(urlBuildList))
}
