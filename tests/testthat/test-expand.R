# library(testthat); library(remakeGenerator);
context("expand")
source("utils.R")

test_that("Function expand() is correct.", {
  testwd("expand")
  expect_equal(expand(example_datasets()), example_datasets())
  expect_equal(expand(example_datasets(), values = c("rep1", "rep2", "rep3")), data.frame(
    target = c("data1_rep1", "data1_rep2", "data1_rep3", 
      "data2_rep1", "data2_rep2", "data2_rep3"),
    command = c("df1(n = 10)", "df1(n = 10)", "df1(n = 10)", 
      "df2(n = 20)", "df2(n = 20)", "df2(n = 20)"),
    check = c(T, T, T, F, F, F),
    stringsAsFactors = F))
  testrm("expand")
})
