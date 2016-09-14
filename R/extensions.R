#' @title Function \code{analyses}
#' @description Helper function for the user. Preprocess a data frame of analysis commands.
#' @export 
#' @return preprocessed data frame of analysis commands
#' @param commands output of \code{commands(...)}
#' @param datasets Data frame of commands to generate datasets
analyses = function(commands, datasets){
  evaluate(commands, wildcard = "..dataset..", values = datasets$target)
}

#' @title Function \code{summaries}
#' @description Helper function for the user. Preprocess a data frame of summary commands.
#' @export 
#' @return preprocessed data frame of analysis commands
#' @param commands Data frame output of \code{commands(...)}
#' @param analyses Data frame of commands to generate analyses
#' @param datasets Data frame of commands to generate datasets
#' @param gather Character vector, names of functions to gather the summaries.
#' If not \code{NULL}, length must be the number of rows in \code{commands}.
summaries = function(commands, analyses, datasets, gather = rep("list", dim(commands)[1])){
  out = commands
  group = paste(colnames(out), collapse = "_")
  out[[group]] = out$target
  out = evaluate(out, wildcard = "..analysis..", values = analyses$target)
  out = evaluate(out, wildcard = "..dataset..", values = datasets$target, expand = FALSE)
  if(is.null(gather)){
    out[[group]] = NULL
    return(out)
  }
  top = ddply(out, group, function(x){
    y = x[[group]][1]
    gather(x, target = y, gather = gather[which(y == commands$target)])
  })
  out[[group]] = top[[group]] = NULL
  rbind(top, out)
}
