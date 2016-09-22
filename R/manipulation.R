#' @title Function \code{expand}
#' @description Expands a dataframe of remake commands by duplicating rows.
#' Use the \code{\link{help_remakeGenerator}} function to get more help.
#' @details Use the \code{\link{help_remakeGenerator}} function to get more help.
#' @seealso \code{\link{help_remakeGenerator}}
#' @export 
#' @return an expanded data frame
#' @param x argument data frame
#' @param values values to expand over
expand = function(x, values = NULL){
  if(!length(values)) return(x)
  d1 = each = dim(x)[1]
  x = x[rep(1:dim(x)[1], each = length(values)),]
  values = rep(values, times = d1)
  x$target = paste(x$target, values, sep = "_")
  row.names(x) = NULL
  x
}

#' @title Function \code{evaluate}
#' @description Evaluates the wildcard placeholders of a data frame of \code{remake} commands.
#' Use the \code{\link{help_remakeGenerator}} function to get more help.
#' @details Use the \code{\link{help_remakeGenerator}} function to get more help.
#' @seealso \code{\link{help_remakeGenerator}}
#' @export 
#' @return an evaluated data frame
#' @param x argument data frame
#' @param wildcard character string to replace with elements of \code{values}.
#' @param values values to replace the wildcard in the remake commands. Must be
#' the same length as \code{x$command} if \code{expand} is \code{TRUE}.
#' @param expand If \code{TRUE}, loop over \code{values} when evaluating the wildcard,
#' creating more rows in the output data frame. Otherwise, each occurance of the wildcard
#' is replaced with the next entry in the \code{values} vector, and the values are recycled.
evaluate = function(x, wildcard = NULL, values = NULL, expand = TRUE){
  if(is.null(wildcard) | is.null(values)) return(x)
  matches = grepl(wildcard, x$command)
  if(!length(matches)) return()
  y = x[matches,]
  if(expand) y = expand(y, values)
  values = rep(values, length.out = dim(y)[1])
  y$command = Vectorize(function(value, command) gsub(wildcard, value, command))(values, y$command)
  rownames(x) = rownames(y) = NULL
  out = rbind(y, x[!matches,])
  rownames(out) = NULL
  out
}

#' @title Function \code{gather}
#' @description Aggregate/gather the targets of a previous set of remake commands.
#' Use the \code{\link{help_remakeGenerator}} function to get more help.
#' @details Use the \code{\link{help_remakeGenerator}} function to get more help.
#' @seealso \code{\link{help_remakeGenerator}}
#' @export 
#' @return data frame with a command to gather the targets in \code{x}
#' @param x argument data frame
#' @param target name of aggregated output object
#' @param gather function used to gather the targets
gather = function(x, target = "target", gather = "list"){
  command = paste(x$target, "=", x$target)
  command = paste(command, collapse = ", ")
  command = paste0(gather, "(", command, ")")
  data.frame(target = target, command = command, stringsAsFactors = F)
}
