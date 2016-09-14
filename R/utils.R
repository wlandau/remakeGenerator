#' @title Function \code{assert_commands}
#' @description Check a data frame of remake commands 
#' @export
#' @param x data frame of remake commands
assert_commands = function(x){
  if(is.null(x$target) | any(!nchar(x$target)) | any(!nchar(x$command))) 
    stop("All commands and their targets must be given. For example, write commands(x = data(y), z = 3) instead of commands(x, z) or commands(data(y), 3).")
  if(anyDuplicated(x$target)) stop("Commands must be given unique target names. No duplicate names allowed.")
}

#' @title Function \code{factor2character}
#' @description Turns a factor into a character and leaves other arguments alone.
#' @export 
#' @return a non-factor vector
#' @param x a vector, factor or non-factor
factor2character = function(x){
  if(is.factor(x)) x = as.character(x)
  x
}
