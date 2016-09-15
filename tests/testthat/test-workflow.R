# library(testthat); library(remakeGenerator);
context("workflow")
source("utils.R")

test_that("Function workflow() is correct.", {
  testwd("workflow")
  example_remakeGenerator(1)
  source("workflow.R")
  expect_equal(readLines("Makefile")[-1], 
     readLines(file.path("..", "test-workflow", "Makefile"))[-1])
  expect_equal(readLines("remake.yml"), 
    readLines(file.path("..", "test-workflow", "remake.yml")))
  testrm("workflow")
})
