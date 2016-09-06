# library(testthat); library(remakeGenerator);
context("examples")
source("utils.R")

test_that("Examples run as expected", {
  for(i in 1:2){
    testwd(paste0("example", i))
    example_remakeGenerator(i)
    source("workflow.R")
    expect_true(file.exists("Makefile"))
    remake::make()
    remake::make("clean")
    testrm()
  }
})
