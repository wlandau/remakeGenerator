#' @title Function \code{example_remakeGenerator}
#' @description Write files to generate an example workflow.
#' Use the \code{\link{help_remakeGenerator}} function to get more help.
#' @seealso \code{\link{help_remakeGenerator}}
#' @export
#' @param index index of example (1, 2, etc.)
example_remakeGenerator = function(index = 1){
  stopifnot(index %in% 1:2)
  example = paste0("example", index)
  dir = system.file(example, package = "remakeGenerator")
  for(file in list.files(dir)){
    path = system.file(example, file, package = "remakeGenerator")
    if (!file.exists(path)) stop("File ", file, 
      " is missing from installed package remakeGenerator.", call.=FALSE)
    contents = readLines(path)
    write(contents, file)
  }
}
