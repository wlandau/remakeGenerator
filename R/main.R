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

expand = function(x, values = NULL){
  if(!length(values)) return(x)
  i = 1:dim(x)[1]
  x = x[rep(i, each = length(values)),]
  values = values[rep(i, times = length(values))]
  x$target = paste(x$target, values, sep = "_")
  x
}

evaluate = function(x, wildcard = NULL, values = NULL, expand_x = TRUE){
  if(expand_x) x = expand(x, values)
  x$command = Vectorize(function(value, command) gsub(wildcard, value, command))(values, x$command)
  x
}

aggregate = function(x, name = "target", aggregator = "list"){
  command = paste(x$command, collapse = ", ")
  command = paste0(aggregator, "(", command, ")")
  data.frame(target = name, command = command)
}
