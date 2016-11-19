# library(testthat); library(remakeGenerator);
context("commands")
source("utils.R")

test_that("Function commands() is correct.", {
  expect_error(assert_commands(data.frame(x = 1:2, command = 1:2)))
  expect_error(assert_commands(data.frame(command = 1:2, target = rep(1, 2))))
  null = data.frame(target = character(0), command = character(0))
  out = data.frame(target = c("x", "y"), command = c(1, "f(2)"), stringsAsFactors = F)
  expect_equal(commands(), null)
  expect_equal(commands_string(), null)
  expect_equal(commands_batch(), null)
  expect_equal(commands(x = 1, y = f(2)), out)
  a = 1
  b = "f(2)"
  expect_false(identical(commands(x = a, y = b), out))
  expect_equal(commands_string(x = a, y = b), out)
  expect_equal(commands_batch(c(x = a, y = b)), out)
})
