# library(testthat); library(remakeGenerator);
context("assert_commands")
source("utils.R")

test_that("Function assert_commands() is correct.", {
  testwd("assert_commands-ok")
  expect_equal(assert_commands(commands(x = 1, y = f(2))), NULL)
  testrm()
})
