testwd = function(x){
  dir = paste0("RUN-", x)
  if(!file.exists(dir)) dir.create(dir)
  setwd(dir)
}

testrm = function(){
  d1 = getwd()
  setwd("..")
  d2 = getwd()
  d = gsub(d2, "", d1)
  d = gsub("[^[:alnum:]|_|-]", "", d)
  unlink(d, recursive = T)
}

#' @title Function \code{example_datasets}
#' @description Outputs an example data frame of \code{remake} commands to produce datasets.
#' @export
#' @return a data frame
example_datasets = function(){
  out = commands(data1 = df1(n = 10), data2 = df2(n = 20))
  out$check = c(T, F)
  out
}

#' @title Function \code{example_analyses}
#' @description Outputs an example data frame of \code{remake} commands to analyze datasets.
#' @export
#' @return a data frame
example_analyses = function(){
  commands(analysis1 = analyze1(..dataset..), analysis2 = analyze2(..dataset..))
}

