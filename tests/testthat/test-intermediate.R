# library(testthat); devtools::load_all();
context("intermediate")
source("utils.R")

test_that("Intermediate targets run as expected", {
  testwd("intermediate")
  example = "basic"
  example_remakeGenerator(example)
  setwd(example)
  
  datasets = commands(
    normal16 = normal_dataset(n = 16),
    poisson32 = poisson_dataset(n = 32),
    poisson64 = poisson_dataset(n = 64))

  analyses = analyses(
    commands = commands(
      linear = linear_analysis(..dataset..),
      quadratic = quadratic_analysis(..dataset..)), 
    datasets = datasets)

  tar = targets(datasets = datasets, analyses = analyses)
  workflow(targets = tar, make_these = "datasets", remake_args = list(verbose = F), sources = "code.R")
  r = parallelRemake::recallable()
  expect_true(all(datasets$target %in% r))
  expect_false(any(analyses$target %in% r))
  workflow(targets = tar, make_these = "linear_poisson64", remake_args = list(verbose = F), 
    sources = "code.R")
  expect_true("linear_poisson64" %in% parallelRemake::recallable())
  setwd("..")
  unlink(example)
  testrm("intermediate")
})
