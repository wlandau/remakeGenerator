# library(testthat); library(remakeGenerator);
context("examples")
source("utils.R")

test_that("Examples run as expected", {
  for(i in 1:2){
    testwd(paste0("example", i))
    example_remakeGenerator(i)
    source("workflow.R")
    tmp = system("make -j 8 2>&1", intern = TRUE)
    tmp = system("make clean 2>&1", intern = TRUE)
    testrm()
  }
})
