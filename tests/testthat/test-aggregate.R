# library(testthat); library(remakeGenerator);
context("aggregate")
source("utils.R")

test_that("Function aggregate is correct.", {
  testwd("aggregate-ok")
  expect_equal(aggregate(example_analyses()), data.frame(
    target = "target",
    command = "list(analyze1(..dataset..), analyze2(..dataset..))",
    stringsAsFactors = F))
  expect_equal(aggregate(example_analyses(), target = "hi", aggregator = "cbind"), data.frame(
    target = "hi",
    command = "cbind(analyze1(..dataset..), analyze2(..dataset..))",
    stringsAsFactors = F))
  testrm()
})
