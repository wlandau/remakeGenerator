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
#' \code{\link{commands_string}} and \code{\link{commands_batch}} are similar.
#' Use the \code{\link{help_remakeGenerator}} function to get more help.
#' @details Use the \code{\link{help_remakeGenerator}} function to get more help.
#' @seealso \code{\link{commands_string}}, \code{\link{commands_batch}}, 
#' \code{\link{help_remakeGenerator}}
#' @export
#' @return data frame of remake targets and commands
#' @param ... commands named with their respective targets
commands = function(...) {
  commands_batch(structure(as.list(match.call()[-1]), class = "uneval"))
}

#' @title Function \code{commands_string}
#' @description Similar to \code{\link{commands}} except that commands are
#' parsed as strings rather than symbols. \code{\link{commands_batch}} is
#' another alternative.
#' Use the \code{\link{help_remakeGenerator}} function to get more help.
#' @details Use the \code{\link{help_remakeGenerator}} function to get more help.
#' @seealso \code{\link{commands}}, \code{\link{commands_batch}},
#' \code{\link{help_remakeGenerator}}
#' @export
#' @return data frame of remake targets and commands
#' @param ... commands named with their respective targets
commands_string = function(...) {
  commands_batch(list(...))
}

#' @title Function \code{commands_batch}
#' @description Similar to \code{\link{commands}} except that commands are
#' given as a named character vector with targets as names and commands as elements.
#' \code{\link{commands_string}} is another alternative.
#' Use the \code{\link{help_remakeGenerator}} function to get more help.
#' @details Use the \code{\link{help_remakeGenerator}} function to get more help.
#' @seealso \code{\link{commands}}, \code{\link{commands_string}},
#' \code{\link{help_remakeGenerator}}
#' @export
#' @return data frame of remake targets and commands
#' @param x named character vector with targets as names and commands as elements
commands_batch = function(x = NULL) {
  if(!length(x)) return(data.frame(target = character(0), command = character(0)))
  out = data.frame(target = names(x), command = as.character(x), stringsAsFactors = FALSE)
  rownames(out) = NULL
  assert_commands(out)
  out
}

#' @title Function \code{targets}
#' @description Puts a named collection of data frames of \code{remake} 
#' commands all together to make a YAML-like list of targets.
#' Unnamed arguments are permitted for data frames with exactly one row.
#' Targets \code{"all"}, \code{"clean"}, and \code{"target_name"},  
#' are already used by \code{remake} and cannot be overwritten by the user.
#' In addition, all target names must be unique. For instance,
#' \code{targets(d = data.frame(target = c("x", "x"), command = c("ls()", "ls()")))}
#' is illegal, and so is 
#' \code{targets(x = data.frame(target = c("x", "y"), command = c("ls()", "ls()")))}.
#' Use the \code{\link{help_remakeGenerator}} function to get more help.
#' @details Use the \code{\link{help_remakeGenerator}} function to get more help.
#' @seealso \code{\link{help_remakeGenerator}}
#' @export 
#' @return YAML-like list of targets.
#' @param ... Named collection of data frames of \code{remake} commands.
targets = function(...){
  if(!length(stages <- clean_stages(list(...)))) return()
  out = c(fake_targets(stages), real_targets(stages))
  check_target_names(names(out))
  out
}

#' @title Function \code{workflow}
#' @description Write and execute a Makefile to run a remake workflow.
#'   Use the \code{\link{help_remakeGenerator}} function to get more help.
#' @details Use the \code{\link{help_remakeGenerator}} function to get more help.
#' @seealso \code{\link{help_remakeGenerator}}
#' @export 
#' @param targets YAML-like list of targets, which you can generate by supplying
#'   data frames of remake commands to the \code{\link{targets}} function.
#' @param make_these names of the remake targets to makle
#' @param sources Character vector of R source files or their containing folders.
#' @param packages Character vector of packages
#' @param remakefile Character, name of the \code{remake} file to generate. 
#'   Should be in the current working directory.
#' @param makefile Deprecated. The name of the Makefile will always be 'Makefile'.
#' @param prepend Character vector of lines to prepend to the Makefile
#' @param begin Use "prepend" instead.
#' @param clean Deprecated. The Makefile is no longer stand alone, so it does not need 'clean'.
#'   Use \code{remake::make("clean")}.
#' @param remake_args Fully-named list of additional arguments to \code{remake::make}.
#'   You cannot set \code{target_names} or \code{remake_file} this way because those
#'   names are reserved.
#' @param run logical, whether to actually run the Makefile or just write it.
#' @param command character scalar, command to run to execute the Makefile.
#'   \code{command} and \code{args} will be used to call 
#'   \code{system2(command = command, args = args)} to run the \code{Makefile}.
#'   For example, to execute the \code{Makefile} using 4 parallel jobs
#'   while suppressing output to the console, use 
#'   \code{makefile(..., command = "make", args = c("--jobs=4", "-s"))}.
#'   Passing \code{command = NULL} will generate the yaml file and not run a
#'   command.
#' @param args character vector of arguments to the specified \code{command}.
#'   \code{command} and \code{args} will be used to call
#'   \code{system2(command = command, args = args)} to run the \code{Makefile}.
#'   For example, to execute the \code{Makefile} using 4 parallel jobs
#'   while suppressing output to the console, use
#'   \code{makefile(..., command = "make", args = c("--jobs=4", "-s"))}.
workflow = function(targets = NULL, make_these = "all", sources = NULL, packages = NULL,
  remakefile = "remake.yml", makefile = NULL, prepend = NULL,
  begin = NULL, clean = NULL, remake_args = list(verbose = TRUE), run = TRUE,
  command = "make", args = character(0)){
  if(!is.null(begin)){
    warning("'begin' is deprecated. Use 'prepend' instead.")
    if(!length(prepend)) prepend = begin
  }
  if(!is.null(makefile)) warning("The 'makefile' argument is deprecated. The Makefile is always called 'Makefile' now.")
  if(!is.null(clean)) warning("The 'clean' argument is deprecated. Use remake::make('clean').")
  yaml = list(packages = packages, sources = sources, targets = targets)
  write(as.yaml(yaml), remakefile)
  yaml_yesno_truefalse(remakefile)
  packages = unique(c("methods", packages))
  if(!is.null(command)){
    makefile(targets = make_these, remakefiles = remakefile, 
           prepend = prepend, remake_args = remake_args, run = run,
           command = command, args = args)
  }
}
