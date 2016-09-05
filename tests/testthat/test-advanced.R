# library(testthat); library(remakeGenerator);
context("advanced")
source("utils.R")

test_that("Advanced example runs as expected", {
  testwd("advanced")
  testrm()
})
