# library(testthat); library(remakeGenerator);
context("evaluations")
source("utils.R")

test_that("Function evaluations() is correct with expand = TRUE.", {
  testwd("evaluationsTRUE")
  expect_equal(evaluations(example_analyses()), example_analyses())
  df = data.frame(target = c("d1", "d2", "d3", "d4"), command = strings(
    f1(mine = 1),
    f2(x, arg1 = ARG1),
    f3(x, arg1 = ARG1, arg2 = ARG2),
    f4(arg1 = ARG1, arg2 = ARG2)
  ), stringsAsFactors = F)
  end1 = data.frame(
    target = c("d1", "d2_1", "d2_2", "d3_1", "d3_2", "d4_1", "d4_2"),
    command = strings(
      f1(mine = 1),
      f2(x, arg1 = 1),
      f2(x, arg1 = 2),
      f3(x, arg1 = 1, arg2 = ARG2),
      f3(x, arg1 = 2, arg2 = ARG2),
      f4(arg1 = 1, arg2 = ARG2),
      f4(arg1 = 2, arg2 = ARG2)),
  stringsAsFactors = F)
  end2 = data.frame(
    target = c("d1", "d2", "d3_10", "d3_11", "d4_10", "d4_11"),
    command = strings(
      f1(mine = 1),
      f2(x, arg1 = ARG1),
      f3(x, arg1 = ARG1, arg2 = 10),
      f3(x, arg1 = ARG1, arg2 = 11),
      f4(arg1 = ARG1, arg2 = 10),
      f4(arg1 = ARG1, arg2 = 11)),
  stringsAsFactors = F)
  end12 = data.frame(
    target = strings(d1, d2_1, d2_2, d3_1_x, d3_1_y, d3_2_x, d3_2_y, d4_1_x, d4_1_y, d4_2_x, d4_2_y),
    command = strings(
      f1(mine = 1),
      f2(x, arg1 = 1),
      f2(x, arg1 = 2),
      f3(x, arg1 = 1, arg2 = x),
      f3(x, arg1 = 1, arg2 = y),
      f3(x, arg1 = 2, arg2 = x),
      f3(x, arg1 = 2, arg2 = y),
      f4(arg1 = 1, arg2 = x),
      f4(arg1 = 1, arg2 = y),
      f4(arg1 = 2, arg2 = x),
      f4(arg1 = 2, arg2 = y)),
  stringsAsFactors = F)

  out1 = evaluations(df, rules = list(ARG1 = 1:2))
  out2 = evaluations(df, rules = list(ARG2 = 10:11))
  out12 = evaluations(df, rules = list(ARG1 = 1:2, ARG2 = strings(x, y)))
  
  expect_equal(out1, end1)
  expect_equal(out2, end2)
  expect_equal(out12, end12)
  
  testrm("evaluationsTRUE")
})

test_that("Function evaluations() is correct with expand = FALSE.", {
  testwd("evaluationsFALSE")
  expect_equal(evaluations(example_analyses(), expand = F), example_analyses())
  df = data.frame(target = c("d1", "d2", "d3", "d4"), command = strings(
    f1(mine = 1),
    f2(x, arg1 = ARG1),
    f3(x, arg1 = ARG1, arg2 = ARG2),
    f4(arg1 = ARG1, arg2 = ARG2)
  ), stringsAsFactors = F)
  end = data.frame(target = c("d1", "d2", "d3", "d4"), command = strings(
    f1(mine = 1),
    f2(x, arg1 = 1),
    f3(x, arg1 = 2, arg2 = x),
    f4(arg1 = 1, arg2 = y)
  ), stringsAsFactors = F)
  out = evaluations(df, rules = list(ARG1 = 1:2, ARG2 = strings(x, y)), expand = F)
  expect_equal(out, end)
  testrm("evaluationsFALSE")
})
