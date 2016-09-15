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

test_that("Function workflow(..., makefile = NULL) turns off the makefile.", {
  testwd("workflow-no-makefile")
  dat = commands(
    normal16 = normal_dataset(n = 16),
    poisson32 = poisson_dataset(n = 32),
    poisson64 = poisson_dataset(n = 64))
  targ = targets(dat = dat)
  workflow(targ, makefile = NULL)
  expect_equal(readLines("remake.yml"), 
    readLines(file.path("..", "test-workflow", "remake-no-makefile.yml")))
  expect_false(file.exists("Makefile"))
  testrm("workflow-no-makefile")
})
