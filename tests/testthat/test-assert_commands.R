# library(testthat); library(remakeGenerator);
context("assert_commands")
source("utils.R")

test_that("Function assert_commands() is correct.", {
  testwd("assert_commands")
  expect_error(assert_commands())
  expect_equal(assert_commands(commands(x = 1, y = f(2))), commands(x = 1, y = f(2)))
  testrm("assert_commands")
})
