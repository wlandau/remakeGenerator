#' @title Function \code{analyses}
#' @description Produces a data frame of \code{remake} analysis commands.
#' Use the \code{\link{help_remakeGenerator}} function to get more help.
#' @details Use the \code{\link{help_remakeGenerator}} function to get more help.
#' @seealso \code{\link{help_remakeGenerator}}
#' @export 
#' @return Preprocessed data frame of \code{remake} analysis commands
#' @param commands output of the \code{\link{commands}} function.
#' @param datasets Data frame of commands to generate datasets
analyses = function(commands, datasets){
  evaluate(commands, wildcard = "..dataset..", values = datasets$target)
}

#' @title Function \code{summaries}
#' @description Produces a data frame of \code{remake} summary commands.
#' Use the \code{\link{help_remakeGenerator}} function to get more help.
#' @details Use the \code{\link{help_remakeGenerator}} function to get more help.
#' @seealso \code{\link{help_remakeGenerator}}
#' @export 
#' @return preprocessed data frame of \code{remake} summary commands
#' @param commands Data frame output of the \code{\link{commands}} function.
#' @param analyses Data frame of \code{remake} commands to generate analyses.
#' @param datasets Data frame of \code{remake} commands to generate datasets.
#' @param gather Character vector, names of functions to gather the summaries.
#' If not \code{NULL}, length must be the number of rows in the \code{commands}
#' argument.
summaries = function(commands, analyses, datasets, gather = rep("list", dim(commands)[1])){
  out = commands
  group = paste(colnames(out), collapse = "_")
  out[[group]] = out$target
  out = evaluate(out, wildcard = "..analysis..", values = analyses$target)
  out = evaluate(out, wildcard = "..dataset..", values = datasets$target, expand = FALSE)
  if(is.null(gather)) return(out[setdiff(names(out), group)])
  top = ddply(out, group, function(x){
    y = x[[group]][1]
    gather(x, target = y, gather = gather[which(y == commands$target)])
  })
  out[[group]] = top[[group]] = NULL
  rbind(top, out)
}
