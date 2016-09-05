# library(testthat); library(remakeGenerator);
context("commands")
source("utils.R")

test_that("Function commands is correct.", {
  testwd("commands-ok")
  expect_equal(commands(x = 1, y = f(2)), 
    data.frame(target = c("x", "y"), command = c(1, "f(2)"), stringsAsFactors = F))
  testrm()
})
