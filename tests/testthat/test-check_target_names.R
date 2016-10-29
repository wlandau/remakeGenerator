# library(testthat); library(remakeGenerator);
context("check_target_names")
source("utils.R")

test_that("Function check_target_names() is correct.", {
  expect_error(check_target_names())
  expect_silent(check_target_names(c("x", "y")))
  expect_error(check_target_names(c("x", "y", "y")))
  for(y in c("clean", "target_name"))
    expect_error(check_target_names(c("x", y)))
})
