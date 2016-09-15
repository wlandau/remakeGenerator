# library(testthat); library(remakeGenerator);
context("factor2character")
source("utils.R")

test_that("Function factor2character() is correct.", {
  testwd("factor2character")
  x = LETTERS[1:4]
  y = as.factor(x)
  expect_error(factor2character())
  expect_equal(factor2character(y), x)
  expect_equal(factor2character(1:12), 1:12)
  testrm("factor2character")
})
