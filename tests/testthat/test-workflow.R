# library(testthat); devtools::load_all();
context("workflow")
source("utils.R")

test_that("deprecations", {
  expect_warning(expect_error(workflow(NULL, begin = "#hi", makefile = "bla")))
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
