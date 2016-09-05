# library(testthat); library(remakeGenerator);
context("evaluate")
source("utils.R")

test_that("Function evaluate is correct.", {
  testwd("evaluate-ok")
  expect_equal(evaluate(example_analyses()), example_analyses())
  expect_equal(evaluate(example_analyses(), wildcard = "..dataset.."), example_analyses())
  expect_equal(evaluate(example_analyses(), values = 1:3), example_analyses())
  expect_error(evaluate(example_analyses(), wildcard = "..dataset..", 
    values = c("data1", "data2", "data3"), expand = F))
  expect_equal(
    evaluate(example_analyses(), wildcard = "..dataset..", 
      values = c("data1", "data2"), expand = F), 
    data.frame(
      target = c("analysis1", "analysis2"),
      command = c("analyze1(data1)", "analyze2(data2)"),
      stringsAsFactors = F))
  expect_equal(
    evaluate(example_analyses(), wildcard = "..dataset..", 
      values = c("data1", "data2", "data3"), expand = T), 
    data.frame(
      target = c("analysis1_data1", "analysis1_data2", "analysis1_data3", 
        "analysis2_data1", "analysis2_data2", "analysis2_data3"),
      command = c("analyze1(data1)", "analyze1(data2)", "analyze1(data3)", 
        "analyze2(data1)", "analyze2(data2)", "analyze2(data3)"),
      stringsAsFactors = F))
  testrm()
})
