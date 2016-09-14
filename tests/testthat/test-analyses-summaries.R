# library(testthat); library(remakeGenerator);
context("analyses-summaries")
source("utils.R")

d1 = commands(
  normal16 = normal_dataset(n = 16),
  poisson32 = poisson_dataset(n = 32),
  poisson64 = poisson_dataset(n = 64)
)

d2 = commands(
  normal16 = normal_dataset(n = 16),
  out = ls(),
  poisson32 = poisson_dataset(n = 32),
  poisson64 = poisson_dataset(n = 64)
)

a1 = analyses(
  commands = commands(
    linear = linear_analysis(..dataset..),
    quadratic = quadratic_analysis(..dataset..)), 
  datasets = d1)

a2 = analyses(
  commands = commands(
    linear = linear_analysis(..dataset..),
    quadratic = quadratic_analysis(..dataset..)), 
  datasets = d2)

s1 = summaries(
  commands = commands(
    mse = mse_summary(..dataset.., ..analysis..),
    coef = coefficients_summary(..analysis..)), 
  analyses = a1, datasets = d1)

s2 = summaries(
  commands = commands(
    mse = mse_summary(..dataset.., ..analysis..),
    coef = coefficients_summary(..analysis..)), 
  analyses = a2, datasets = d2, gather = strings(c, rbind))

s3 = summaries(
  commands = commands(
    mse = mse_summary(..dataset.., ..analysis..),
    coef = coefficients_summary(..analysis..)), 
  analyses = a2, datasets = d2, gather = NULL)

test_that("Functions analyses() and summaries() are correct.", {
  testwd("analyses-summaries-ok")
  for(x in strings(a1, a2, s1, s2, s3))
    expect_equal(get(x), 
      read.table(file.path("..", "test-analyses-summaries", paste0(x, ".txt")),
        stringsAsFactors = F, head = T))
  testrm()
})
