#' @title Function \code{example_remakeGenerator}
#' @description Copy a remakeGenerator example to the current working directory.
#' To see the names of all the examples, run \code{\link{list_examples_remakeGenerator}}.
#' @seealso \code{\link{list_examples_remakeGenerator}}, \code{\link{workflow}}
#' @export
#' @param example name of the example. To see all the available example names, 
#' run \code{\link{list_examples_remakeGenerator}}.
example_remakeGenerator = function(example = list_examples_remakeGenerator()){
  example <- match.arg(example)
  dir <- system.file(file.path("examples", example), package = "remakeGenerator")
  if(file.exists(example)) 
    stop("There is already a file or folder named ", example, ".", sep = "")
  file.copy(from = dir, to = getwd(), recursive = TRUE)
  invisible()
}

#' @title Function \code{list_examples_remakeGenerator}
#' @description Return the names of all the remakeGenerator examples.
#' @seealso \code{\link{example_remakeGenerator}}, \code{\link{workflow}}
#' @export
#' @return a names of all the remakeGenerator examples.
list_examples_remakeGenerator = function(){
  list.dirs(system.file("examples", package = "remakeGenerator"), full.names = FALSE, recursive = FALSE)
}
