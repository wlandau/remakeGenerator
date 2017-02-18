# library(testthat); devtools::load_all();
context("workflow")
source("utils.R")

test_that("Function workflow() is correct.", {
  testwd("workflow")
  example = "basic"
  example_remakeGenerator(example)
  setwd(example)
  x = readLines("workflow.R")[-1]
  unlink("workflow.R")
  writeLines(x, "workflow.R")
  expect_error(is.matrix(parallelRemake::recall("coef")))
  expect_false(file.exists("latex.tex"))
  expect_false(file.exists("markdown.md"))
  source("workflow.R")
  expect_true(is.matrix(recall("coef")))
  expect_true(file.exists("latex.tex"))
  expect_true(file.exists("markdown.md"))
  setwd("..")
  unlink(example, recursive = TRUE)
  testrm("workflow")
})

test_that("Function workflow(..., run = F) doesn't run the Makefile.", {
  testwd("workflow-no-makefile")
  dat = commands(
    normal16 = normal_dataset(n = 16),
    poisson32 = poisson_dataset(n = 32),
    poisson64 = poisson_dataset(n = 64))
  targ = targets(dat = dat)
  workflow(targ, run = F)
  expect_error(parallelRemake::recall("normal16"))
  expect_true(file.exists("Makefile"))
  testrm("workflow-no-makefile")
})
