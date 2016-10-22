#' @title Function \code{assert_commands}
#' @description Check a data frame of remake commands.
#' Use the \code{\link{help_remakeGenerator}} function to get more help.
#' @seealso \code{\link{help_remakeGenerator}}
#' @export
#' @param x data frame of remake commands
assert_commands = function(x){
  if(is.null(x$target) | any(!nchar(x$target)) | any(!nchar(x$command))) 
    stop("All commands and their targets must be given. For example, write commands(x = data(y), z = 3) instead of commands(x, z) or commands(data(y), 3).")
  if(anyDuplicated(x$target)) stop("Commands must be given unique target names. No duplicate names allowed.")
}

#' @title Function \code{clean_stages}
#' @description Sanitize and check a named list of 
#' data frames defining the stages of the workflow.
#' Use the \code{\link{help_remakeGenerator}} function to get more help.
#' @seealso \code{\link{help_remakeGenerator}}
#' @export
#' @return sanitized list of data frames defining the stages of the workflow
#' @param stages named list of data frames defining the stages of the workflow
clean_stages = function(stages){
  msg = "In function targets(), the supplied data frames must all have names. For example, write targets(datasets = my_data_frame, analyses = another_data_frame) instead of targets(my_data_frame, another_data_frame)."
  stages = lapply(stages, function(x)
    data.frame(lapply(x, factor2character), stringsAsFactors = FALSE))
  if(!length(stages)) return()
  if(is.null(names(stages))) stop(msg)
  if(any(nchar(names(stages)) < 1)) stop(msg)
  stages
}

#' @title Function \code{factor2character}
#' @description Turns a factor into a character and leaves other arguments alone.
#' Use the \code{\link{help_remakeGenerator}} function to get more help.
#' @seealso \code{\link{help_remakeGenerator}}
#' @export
#' @return a non-factor vector
#' @param x a vector, factor or non-factor
factor2character = function(x){
  if(is.factor(x)) x = as.character(x)
  x
}

#' @title Function \code{fake_targets}
#' @description Get a \code{YAML}-like list of fake/phony \code{remake} targets
#' from a named list of data frames defining the stages of the workflow.
#' Use the \code{\link{help_remakeGenerator}} function to get more help.
#' @seealso \code{\link{help_remakeGenerator}}
#' @export
#' @return \code{YAML}-like list of fake/phony \code{remake} targets
#' @param stages named list of data frames defining the stages of the workflow
fake_targets = function(stages){
  out = list(all = list(depends = as.list(names(stages))))
  for(stage in names(stages))
    out[[stage]] = list(depends = as.list(stages[[stage]]$target))
  out
}

#' @title Function \code{finalize_targets}
#' @description Finalize the list of remake targets from 
#' YAML like lists of fake and real targets.
#' Use the \code{\link{help_remakeGenerator}} function to get more help.
#' @seealso \code{\link{help_remakeGenerator}}
#' @export
#' @return \code{YAML}-like list of all \code{remake} targets
#' @param fake_targets \code{YAML}-like list of fake/phony \code{remake} targets
#' @param real_targets \code{YAML}-like list of real 
#' (non-fake/non-phony) \code{remake} targets
finalize_targets = function(fake_targets, real_targets){
  for(i in intersect(names(real_targets), names(fake_targets)))
    fake_targets[[i]] = NULL
  out = c(fake_targets, real_targets)
  if(anyDuplicated(names(out))) stop("Targets must not have duplicate names.")
  out
}

#' @title Function \code{real_targets}
#' @description Get a \code{YAML}-like list of real (non-fake/non-phony) \code{remake} 
#' targets from a named list of data frames defining the stages of the workflow.
#' Use the \code{\link{help_remakeGenerator}} function to get more help.
#' @seealso \code{\link{help_remakeGenerator}}
#' @export
#' @return \code{YAML}-like list of real (non-fake/non-phony) \code{remake} targets
#' @param stages named list of data frames defining the stages of the workflow
real_targets = function(stages){
  out = do.call("c", lapply(stages, function(x) dlply(x, colnames(x), as.list)))
  out = lapply(out, function(x) {attr(x, "vars") = NULL; x})
  names(out) = lapply(out, function(x) x$target)
  out = lapply(out, function(x){
    x$target = NULL
    for(field in c("depends")) if(!is.null(x[[field]]))
      x[[field]] = lapply(unlist(strsplit(x[[field]], split = ",")), stri_trim)
    x
  })
}

#' @title Function \code{unique_random_string}
#' @description Generates a random character string that
#' is different from each of the values in \code{exclude}.
#' @seealso \code{\link{help_remakeGenerator}}
#' @export
#' @return random character string not in \code{exclude}
#' @param exclude excluded values for the returned character string
#' @param n number of characters in the returned character string
unique_random_string = function(exclude = NULL, n = 30){
  while((out <- stri_rand_strings(1, n)) %in% exclude) next
  out
}
