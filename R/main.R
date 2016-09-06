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
  d1 = each = dim(x)[1]
  x = x[rep(1:dim(x)[1], each = length(values)),]
  values = rep(values, times = d1)
  x$target = paste(x$target, values, sep = "_")
  row.names(x) = NULL
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
#' @param expand_x If \code{TRUE}, loop over \code{values} when evaluating the wildcard,
#' creating more rows in the output data frame. Otherwise, each occurance of the wildcard
#' is replaced with the next entry in the \code{values} vector, and the values are recycled.
evaluate = function(x, wildcard = NULL, values = NULL, expand_x = TRUE){
  if(is.null(wildcard) | is.null(values)) return(x)
  matches = grepl(wildcard, x$command)
  if(!length(matches)) return()
  y = x[matches,]
  if(expand_x) y = expand(y, values)
  values = rep(values, length.out = dim(y)[1])
  y$command = Vectorize(function(value, command) gsub(wildcard, value, command))(values, y$command)
  rownames(x) = rownames(y) = NULL
  rbind(y, x[!matches,])
}

#' @title Function \code{gather}
#' @description Aggregate/gather the targets of a previous set of remake commands. 
#' @export 
#' @return data frame with a command to gather the targets in \code{x}
#' @param x argument data frame
#' @param target name of aggregated output object
#' @param aggregator function used to gather the targets
gather = function(x, target = "target", aggregator = "list"){
  command = paste(x$target, collapse = ", ")
  command = paste0(aggregator, "(", command, ")")
  data.frame(target = target, command = command, stringsAsFactors = F)
}

factor2character = function(x){
  if(is.factor(x)) x = as.character(x)
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

  msg = "In function targets(), the supplied data frames must have names. For example, write targets(datasets = my_data_frame, analyses = another_data_frame) instead of targets(my_data_frame, another_data_frame)"
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

#' @title Function \code{analyses}
#' @description Helper function for the user. Preprocess a data frame of analysis commands.
#' @export 
#' @return preprocessed data frame of analysis commands
#' @param commands output of \code{commands(...)}
#' @param datasets Data frame of commands to generate datasets
analyses = function(commands, datasets){
  evaluate(commands, wildcard = "..dataset..", values = datasets$target)
}

#' @title Function \code{summaries}
#' @description Helper function for the user. Preprocess a data frame of summary commands.
#' @export 
#' @return preprocessed data frame of analysis commands
#' @param commands output of \code{commands(...)}
#' @param analyses Data frame of commands to generate analyses
#' @param datasets Data frame of commands to generate datasets
summaries = function(commands, analyses, datasets){
  commands = evaluate(commands, wildcard = "..analysis..", values = analyses$target)
  evaluate(commands, wildcard = "..dataset..", values = datasets$target, expand_x = FALSE)
}

#' @title Function \code{example_remakeGenerator}
#' @description Write files to generate an example workflow.
#' Refer to the generated README.md for further instructions.
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
