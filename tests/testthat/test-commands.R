# library(testthat); library(remakeGenerator);
context("commands")
source("utils.R")

test_that("Function commands() is correct.", {
  testwd("commands")
  expect_error(assert_commands(data.frame(x = 1:2, command = 1:2)))
  expect_error(assert_commands(data.frame(command = 1:2, target = rep(1, 2))))
  expect_equal(commands(x = 1, y = f(2)), 
    data.frame(target = c("x", "y"), command = c(1, "f(2)"), stringsAsFactors = F))
  testrm("commands")
})
