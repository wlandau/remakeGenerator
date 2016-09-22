#' @title Function \code{strings}
#' @description Turns unquoted symbols into character strings.
#' Use the \code{\link{help_remakeGenerator}} function to get more help.
#' @details Use the \code{\link{help_remakeGenerator}} function to get more help.
#' @seealso \code{\link{help_remakeGenerator}}
#' @export 
#' @return a character vector
#' @param ... unquoted symbols to turn into character strings.
strings = function(...){
  args = structure(as.list(match.call()[-1]), class = "uneval")
  keys = names(args)
  out = as.character(args)
  names(out) = keys
  out
}

#' @title Function \code{commands}
#' @description Turns a named collection of \code{remake} commands into 
#' a data frame of \code{remake} targets and \code{remake} commands.
#' Use the \code{\link{help_remakeGenerator}} function to get more help.
#' @details Use the \code{\link{help_remakeGenerator}} function to get more help.
#' @seealso \code{\link{help_remakeGenerator}}
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
#' @description Puts a named collection of data frames of \code{remake} 
#' commands all together to make a YAML-like list of targets.
#' Use the \code{\link{help_remakeGenerator}} function to get more help.
#' @details Use the \code{\link{help_remakeGenerator}} function to get more help.
#' @seealso \code{\link{help_remakeGenerator}}
#' @export 
#' @return YAML-like list of targets.
#' @param ... Named collection of data frames of \code{remake} commands.
targets = function(...){
  if(!length(stages <- clean_stages(list(...)))) return()
  fake_targets = fake_targets(stages)
  real_targets = real_targets(stages)
  finalize_targets(fake_targets, real_targets)
}

#' @title Function \code{workflow}
#' @description Writes the files for a remake workflow.
#' Use the \code{\link{help_remakeGenerator}} function to get more help.
#' @details Use the \code{\link{help_remakeGenerator}} function to get more help.
#' @seealso \code{\link{help_remakeGenerator}}
#' @export 
#' @param targets YAML-like list of targets, which you can generate by supplying
#' data frames of remake commands to the \code{\link{targets}} function.
#' @param sources Character vector of R source files
#' @param packages Character vector of packages
#' @param remakefile Character, name of the \code{remake} file to generate. 
#' Should be in the current working directory.
#' @param makefile Character, name of the Makefile. Should be in the current
#' working directory. Set to \code{NULL} to suppress the writing of the Makefile.
#' @param begin Character vector of lines to prepend to the Makefile.
#' @param clean Character vector of extra Makefile commands for \code{make clean}.
#' @param remake_args Fully-named list of additional arguments to \code{remake::make}.
#' You cannot set \code{target_names} or \code{remake_file} this way because those
#' names are reserved.
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
