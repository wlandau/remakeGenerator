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
  analyses = a2, datasets = d2)

test_that("Functions analyses() and summaries() are correct.", {
  testwd("analyses-summaries-ok")
  expect_equal(a1, read.table(file.path("..", "test-analyses-summaries", "a1.txt"),
    stringsAsFactors = F, head = T))
  expect_equal(a2, read.table(file.path("..", "test-analyses-summaries", "a2.txt"),
    stringsAsFactors = F, head = T))
  expect_equal(s1, read.table(file.path("..", "test-analyses-summaries", "s1.txt"),
    stringsAsFactors = F, head = T))
  expect_equal(s2, read.table(file.path("..", "test-analyses-summaries", "s2.txt"),
    stringsAsFactors = F, head = T))
  testrm()
})
