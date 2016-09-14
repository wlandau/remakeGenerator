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

#' @title Function \code{targets}
#' @description Put the data frames of remake commands all together to make a
#' YAML-like list of targets
#' @export 
#' @return YAML-like list of targets
#' @param ... data frames of remake commands
targets = function(...){
  stages = lapply(list(...), function(x)
    data.frame(lapply(x, factor2character), stringsAsFactors = FALSE))
  stage_names = names(stages)
  if(!length(stages)) return()

  msg = "In function targets(), the supplied data frames must all have names. For example, write targets(datasets = my_data_frame, analyses = another_data_frame) instead of targets(my_data_frame, another_data_frame)."
  if(is.null(stage_names)) stop(msg)
  if(any(nchar(stage_names) < 1)) stop(msg)

  fake_targets = list(all = list(depends = as.list(stage_names)))
  for(stage in stage_names)
    fake_targets[[stage]] = list(depends = as.list(stages[[stage]]$target))

  real_targets = do.call("c", lapply(stages, function(x) dlply(x, colnames(x), as.list)))
  real_targets = lapply(real_targets, function(x) {attr(x, "vars") = NULL; x})
  names(real_targets) = lapply(real_targets, function(x) x$target)
  real_targets = lapply(real_targets, function(x){
    x$target = NULL
    for(field in c("depends")) if(!is.null(x[[field]]))
      x[[field]] = lapply(unlist(strsplit(x[[field]], split = ",")), stri_trim)
    x
  })

  for(i in intersect(names(real_targets), names(fake_targets)))
    fake_targets[[i]] = NULL
  out = c(fake_targets, real_targets)
  if(anyDuplicated(names(out))) stop("Targets must not have duplicate names.")
  out
}

#' @title Function \code{workflow}
#' @description Write the files for a remake workflow
#' @export 
#' @param targets YAML-like list of targets, which you can generate by supplying
#' data frames of remake commands to the \code{targets()} function.
#' @param sources Character vector of R source files
#' @param packages Character vector of packages
#' @param remakefile Character, name of the \code{remake} file to generate. Should be in the current working directory.
#' @param makefile Character, name of the Makefile. Should be in the current
#' working directory. Set to \code{NULL} to suppress the writing of the Makefile.
#' @param begin Character vector of lines to prepend to the Makefile.
#' @param clean Character vector of extra shell commands for \code{make clean}.
#' @param remake_args Fully-named list of additional arguments to \code{remake::make}.
#' You cannot set \code{target_names} or \code{remake_file} this way.
workflow = function(targets = NULL, sources = NULL, packages = NULL,
  remakefile = "remake.yml", makefile = "Makefile", 
  begin = NULL, clean = NULL, remake_args = list()){
  yaml = list(packages = packages, sources = sources, targets = targets)
  write(as.yaml(yaml), remakefile)
  yaml_yesno_truefalse(remakefile)
  if(!is.null(makefile)) 
    write_makefile(makefile = makefile, remakefiles = remakefile, begin = begin, 
      clean = clean, remake_args = remake_args)
}
