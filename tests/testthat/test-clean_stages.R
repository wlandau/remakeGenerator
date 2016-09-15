# library(testthat); library(remakeGenerator);
context("clean_stages")
source("utils.R")

test_that("Function clean_stages() is correct.", {
  testwd("clean_stages")
  d0 = example_datasets()
  d0$depends = c("u, v", "w, x, y, z")
  d1 = d0
  d1$depends = as.factor(d1$depends)
  d2 = example_analyses()
  x = clean_stages(list(a = d1, b = d2))
  expect_error(clean_stages())
  expect_error(clean_stages(list(d1)))
  expect_error(clean_stages(list(dat = d1, d2)))
  expect_null(clean_stages(list()))
  expect_false(any(unlist(lapply(x, function(y) lapply(y, is.factor)))))
  expect_equal(x, list(a = d0, b = d2))
  testrm("clean_stages")
})
