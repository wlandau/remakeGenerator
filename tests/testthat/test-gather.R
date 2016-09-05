# library(testthat); library(remakeGenerator);
context("gather")
source("utils.R")

test_that("Function gather is correct.", {
  testwd("gather-ok")
  expect_equal(gather(example_analyses()), data.frame(
    target = "target",
    command = "list(analyze1(..dataset..), analyze2(..dataset..))",
    stringsAsFactors = F))
  expect_equal(gather(example_analyses(), target = "hi", aggregator = "cbind"), data.frame(
    target = "hi",
    command = "cbind(analyze1(..dataset..), analyze2(..dataset..))",
    stringsAsFactors = F))
  testrm()
})
