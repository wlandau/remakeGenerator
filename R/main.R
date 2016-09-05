#' @title Function \code{strings}
#' @description Turns expressions into character strings
#' @export 
#' @return a character vector
#' @param ... expressions to turn into characters
strings = function(...){
  args = structure(as.list(match.call()[-1]), class = "uneval")
  keys = names(args)
  out = as.character(args)
  names(out) = keys
  out
}

#' @title Function \code{assert_commands}
#' @description Check a data frame of remake commands 
#' @export
#' @param x data frame of remake commands
assert_commands = function(x){
  if(is.null(x$target) | any(!nchar(x$target)) | any(!nchar(x$command))) 
    stop("All commands and their targets must be given. For example, write commands(x = data(y), z = 3) instead of commands(x, z) or commands(data(y), 3).")
  if(anyDuplicated(x$target)) stop("Commands must be given unique targets. No duplicates allowed.")
}

#' @title Function \code{commands}
#' @description Turn a collection of R expressions into 
#' a data frame of remake targets and commands. 
#' @export
#' @return data frame of remake targets and commands
#' @param ... commands named with their respective targets
commands = function(...) {
  args = structure(as.list(match.call()[-1]), class = "uneval")
  if(!length(args)) return()
  x = data.frame(target = names(args), command = as.character(args), stringsAsFactors = F)
  rownames(x) = NULL
  assert_commands(x)
  x
}

#' @title Function \code{expand}
#' @description Expands a dataframe of remake commands by duplicating rows.
#' @export 
#' @return an expanded data frame
#' @param x argument data frame
#' @param values values to expand over
expand = function(x, values = NULL){
  if(!length(values)) return(x)
  i = 1:dim(x)[1]
  x = x[rep(i, each = length(values)),]
  values = values[rep(i, times = length(values))]
  x$target = paste(x$target, values, sep = "_")
  x
}

#' @title Function \code{evaluate}
#' @description Evaluate the wildcards in the commands of a data frame
#' @export 
#' @return an evaluated data frame
#' @param x argument data frame
#' @param wildcard character string to replace with elements of \code{values}.
#' @param values values to replace the wildcard in the remake commands. Must be
#' the same length as \code{x$command} if \code{expand_x} is \code{TRUE}.
#' @param expand_x \code{TRUE}/\code{FALSE} value. If \code{TRUE}, \code{x} will 
#' expand over \code{values}. If \code{FALSE}, the elements of \code{values} will 
#' simply replace the wildcard in the respective elements of \code{x$commands}.
evaluate = function(x, wildcard = NULL, values = NULL, expand_x = TRUE){
  if(expand_x) x = expand(x, values)
  x$command = Vectorize(function(value, command) gsub(wildcard, value, command))(values, x$command)
  x
}

#' @title Function \code{aggregate}
#' @description Aggregate the targets of a previous set of remake commands. 
#' @export 
#' @return data frame to aggregate the targets
#' @param x argument data frame
#' @param name name of aggregated object
#' @param aggregator function to aggregate the targets
aggregate = function(x, name = "target", aggregator = "list"){
  command = paste(x$command, collapse = ", ")
  command = paste0(aggregator, "(", command, ")")
  data.frame(target = name, command = command)
}
