
## Methods for class prdlist ------------------------------------------------



#' @export
#' @rdname prdlist
as.prdlist <- function(x, ...) {
  UseMethod("as.prdlist", x)
}

#' @export
#' @param x list of prediction frames
#' @param names character vector, the list names, e.g. the names of the experimental
#' @rdname prdlist
as.prdlist.list <- function(x = NULL, names = NULL, ...) {

  if (is.null(x)) x <- list()
  if (is.null(names)) mynames <- names(x) else mynames <- names 

  # if (length(mynames) != length(x)) stop("names argument has wrong length")

  ## Prepare output
  names(x) <- mynames
  class(x) <- c("prdlist", "list")

  return(x)

}


#' @export
c.prdlist <- function(...) {
  
  mylist <- list(...)
  mylist <- lapply(mylist, unclass)
  newlist <- do.call(c, mylist)
  
  as.prdlist(newlist)
  
}

#' @export
"[.prdlist" <- function(x, ...) {
  out <- unclass(x)[...]
  class(out) <- c("prdlist", "list")
  return(out)
}







#' @export
print.prdlist <- function(x, ...) {
  
  mynames <- names(x)
  if (is.null(mynames)) mynames <- rep("NULL", length(x))
  
  for (i in 1:length(x)) {
    cat(mynames[i], ":\n", sep = "")
    print(x[[i]])
  }
  
}


#' @export
#' @param data data list oject
#' @param errfn obsfn object, the error model function to predict sigma
#' @param ... not used right now
#' @rdname as.data.frame.dMod
as.data.frame.prdlist <- function(x, ..., data = NULL, errfn = NULL) {
  
  prediction <- x
  sigma <- NULL
  condition.grid <- attr(data, "condition.grid")
  
  if (!is.null(errfn)) {
    sigma <- as.prdlist(
      lapply(1:length(prediction), 
             function(i) errfn(prediction[[i]], 
                               getParameters(prediction[[i]]), 
                               conditions = names(prediction)[i])[[1]]),
      names = names(prediction)
    )
    sigma <- wide2long(sigma)
  }
  
  prediction <- wide2long(prediction)
  prediction$sigma <- NaN
  if (!is.null(sigma)) {
    common <- intersect(unique(prediction$name), unique(sigma$name))
    prediction$sigma[prediction$name %in% common] <- sigma$value[sigma$name %in% common]
  }
  
  if (!is.null(condition.grid)) {
    for (C in colnames(condition.grid)) {
      rows <- ifelse(is.na(prediction$condition), 1, as.character(prediction$condition))
      prediction[, C] <- condition.grid[rows, C]
    }
    n1 <- nrow(prediction)
  }
  
  
  return(prediction)
  
  
} 

#' @export
#' @param x prediction
#' @rdname plotCombined
plot.prdlist <- function(x, data = NULL, ..., scales = "free", facet = "wrap", transform = NULL) {
  
  prediction <- x
  
  if (is.null(names(prediction))) names(prediction) <- paste0("C", 1:length(prediction))
  if (!is.null(data) && is.null(names(data))) names(data) <- paste0("C", 1:length(data))
  
  plotCombined.prdlist(prediction = prediction, data = data, ..., scales = scales, facet = facet, transform = transform)
  
}


#' @export
#' @rdname plotCombined
#' @importFrom rlang enexprs !!! sym exprs
#' @importFrom dplyr filter left_join
plotCombined.prdlist <- function(prediction, data = NULL, ..., scales = "free", facet = "wrap", transform = NULL, aesthetics = NULL) {
  
  dots <- rlang::enexprs(...)
  mynames <- c("time", "name", "value", "sigma", "condition")
  covtable <- NULL
  
  if (!is.null(data)) {
    rownames_to_condition <- function(covtable) {
      out <- cbind(condition = rownames(covtable), covtable, stringsAsFactors = F)
      out <- out[!duplicated(names(out))]
      return(out)}
    covtable <- rownames_to_condition(covariates(data))

    data <- lbind(data)
    data <- base::merge(data, covtable, by = "condition", all.x = T)
    data <- dplyr::filter(data, ...)
    data <- as.data.frame(data, stringsAsFactors = F)
    
    if (!is.null(transform)) data <- coordTransform(data, transform)
  }
  
  if (!is.null(prediction)) {
    prediction <- cbind(wide2long(prediction), sigma = NA)
    if (!is.null(data)) prediction <- base::merge(prediction, covtable, by = "condition", all.x = T)
    prediction <- as.data.frame(dplyr::filter(prediction, ...), stringsAsFactors = F)
    
    if (!is.null(transform)) prediction <- coordTransform(prediction, transform)
  }
  
  total <- rbind(prediction[, unique(c(mynames, names(covtable)))], data[, unique(c(mynames, names(covtable)))])
  
  
  if (facet == "wrap"){
    aes0 <- list(x = "time", y = "value", ymin = "value - sigma", ymax = "value + sigma", group = "condition", color = "condition")
    aesthetics <- c(aes0[setdiff(names(aes0), names(aesthetics))], aesthetics)
    p <- ggplot(total, do.call("aes_string", aesthetics)) + facet_wrap(~name, scales = scales)}
  if (facet == "grid"){
    aes0 <- list(x = "time", y = "value", ymin = "value - sigma", ymax = "value + sigma")
    aesthetics <- c(aes0[setdiff(names(aes0), names(aesthetics))], aesthetics)
    p <- ggplot(total, do.call("aes_string", aesthetics)) + facet_grid(name ~ condition, scales = scales)}
  if (facet == "wrap_plain"){
    aes0 <- list(x = "time", y = "value", ymin = "value - sigma", ymax = "value + sigma")
    aesthetics <- c(aes0[setdiff(names(aes0), names(aesthetics))], aesthetics)
    p <- ggplot(total, do.call("aes_string", aesthetics)) + facet_wrap(~name*condition, scales = scales)}
  
  if (!is.null(prediction))
    p <- p +  geom_line(data = prediction)
  
  if (!is.null(data))
    p <- p + geom_point(data = data) + geom_errorbar(data = data, width = 0)
  
  attr(p, "data") <- list(data = data, prediction = prediction)
  return(p)
  
  attr(p, "data") <- list(data = data, prediction = prediction)
  return(p)
  
}




#' @export
#' @rdname plotPrediction
#' @importFrom dplyr filter
#' @importFrom rlang enexprs !!!
plotPrediction.prdlist <- function(prediction, ..., scales = "free", facet = "wrap", transform = NULL) {
  
  prediction <- as.data.frame(dplyr::filter(wide2long.list(prediction), ...), stringsAsFactors = F)
  
  if (!is.null(transform)) prediction <- coordTransform(prediction, transform)
  
  if (facet == "wrap")
    p <- ggplot(prediction, aes(x = time, y = value, group = condition, color = condition)) + 
      facet_wrap(~name, scales = scales)
  if (facet == "grid")
    p <- ggplot(prediction, aes(x = time, y = value)) + facet_grid(name ~ condition, scales = scales)
  
  p <- p + geom_line() 
  
  attr(p, "data") <- prediction
  return(p)
  
}



## Methods for class prdframe ----------------------------
#' @export
#' @rdname plotCombined
plot.prdframe <- function(x, data = NULL, ..., scales = "free", facet = "wrap", transform = NULL) {
  
  prediction <- x
  
  prediction <- list("C1" = prediction)
  if (!is.null(data) && is.data.frame(data))
    data <- list("C1" = data)
  
  
  plotCombined.prdlist(prediction = prediction, data = data, ..., scales = scales, facet = facet, transform = transform)
  
}

#' @export
print.prdframe <- function(x, ...) {
  
  derivs <- ifelse(!is.null(attr(x, "deriv")), yes = "yes", no = "no")
  sensitivities <- ifelse(!is.null(attr(x, "sensitivities")), yes = "yes", no = "no")
  
  attr(x, "deriv") <- NULL
  attr(x, "sensitivities") <- NULL
  attr(x, "parameters") <- NULL
  
  print(unclass(x))
  cat("\n")
  cat("The prediction contains derivatives: ", derivs, "\n", sep = "")
  
  
}


## Methods for class prdfn ----------------------------------

#' @export
print.prdfn <- function(x, ...) {
  
  conditions <- attr(x, "conditions")
  parameters <- attr(x, "parameters")
  mappings <- attr(x, "mappings")
  
  cat("Prediction function:\n")
  str(args(x))
  cat("\n")
  cat("... conditions:", paste0(conditions, collapse = ", "), "\n")
  cat("... parameters:", paste0(parameters, collapse = ", "), "\n")
 
}

#' @export
summary.prdfn <- function(object,...) {
  
  x <- object
  
  conditions <- attr(x, "conditions")
  parameters <- attr(x, "parameters")
  mappings <- attr(x, "mappings")
  
  cat("Details:\n")
  if (!inherits(x, "composed")) {
    
    output <- lapply(1:length(mappings), function(C) {
      
      list(
        equations = attr(mappings[[C]], "equations"),
        events = attr(mappings[[C]], "events"),
        forcings = attr(mappings[[C]], "forcings"),
        parameters = attr(mappings[[C]], "parameters")
      )
      
    })
    names(output) <- conditions
    
    #print(output, ...)
    output
    
  } else {
    
    cat("\nObject is composed. See original objects for more details.\n")
    
  }
}

#' @export
print.obsfn <- function(x, ...) {
  
  conditions <- attr(x, "conditions")
  parameters <- attr(x, "parameters")
  mappings <- attr(x, "mappings")
  
  cat("Observation function:\n")
  str(args(x))
  cat("\n")
  cat("... conditions:", paste0(conditions, collapse = ", "), "\n")
  cat("... parameters:", paste0(parameters, collapse = ", "), "\n")
 
}

#' @export
summary.obsfn <- function(object, ...) {
  
  x <- object
  
  conditions <- attr(x, "conditions")
  parameters <- attr(x, "parameters")
  mappings <- attr(x, "mappings")
  
  cat("Details:\n")
  if (!inherits(x, "composed")) {
    
    output <- lapply(1:length(mappings), function(C) {
      
      list(
        equations = attr(mappings[[C]], "equations"),
        states = attr(mappings[[C]], "states"),
        parameters = attr(mappings[[C]], "parameters")
      )
      
    })
    names(output) <- conditions
    
    #print(output, ...)
    output
    
  } else {
    
    cat("\nObject is composed. See original objects for more details.\n")
    
  }
}


