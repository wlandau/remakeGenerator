# library(testthat); library(remakeGenerator);
context("intermediate")
source("utils.R")

test_that("Intermediate targets run as expected", {
  testwd("intermediate")
  example_remakeGenerator(1)
  source("workflow.R")

  datasets = commands(
    normal16 = normal_dataset(n = 16),
    poisson32 = poisson_dataset(n = 32),
    poisson64 = poisson_dataset(n = 64))

  analyses = analyses(
    commands = commands(
      linear = linear_analysis(..dataset..),
      quadratic = quadratic_analysis(..dataset..)), 
    datasets = datasets)

  summaries = summaries(
    commands = commands(
      mse = mse_summary(..dataset.., ..analysis..),
      coef = coefficients_summary(..analysis..)), 
    analyses = analyses, datasets = datasets, gather = strings(c, rbind))
  
  dat = datasets$target
  ana = c(dat, analyses$target)
  sum = c(ana, summaries$target)
  out = c(ana, sort(summaries$target)[1:7])
  plo = c(ana, sort(summaries$target)[8:14])
  rep = out

  for(x in strings(datasets, analyses, summaries, output, plots, reports)){
    remake::make(x)
    expect_equal(sort(parallelRemake::recallable()), sort(get(substr(x, 0, 3))))
    remake::make("clean", verbose = F)
  }

  remake::make("mse_linear_poisson32")
  expect_equal(sort(parallelRemake::recallable()), 
    sort(strings(linear_poisson32, mse_linear_poisson32, poisson32)))
  testrm("intermediate")
})
