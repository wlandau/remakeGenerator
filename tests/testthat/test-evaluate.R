# library(testthat); library(remakeGenerator);
context("evaluate")
source("utils.R")

test_that("Function evaluate() is correct with args wildcard and values.", {
  testwd("evaluate")
  expect_equal(evaluate(example_analyses()), example_analyses())
  expect_equal(evaluate(example_analyses(), wildcard = "..dataset.."), example_analyses())
  expect_equal(evaluate(example_analyses(), values = 1:3), example_analyses())
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

  dat = rbind(example_analyses()[1,], c("goof", "ls()"), example_analyses()[2,])
  expect_equal(
    evaluate(dat, wildcard = "..dataset..", 
      values = c("data1", "data2"), expand = F), 
    data.frame(
      target = c("analysis1", "goof", "analysis2"),
      command = c("analyze1(data1)", "ls()", "analyze2(data2)"),
      stringsAsFactors = F))
  expect_equal(
    evaluate(dat, wildcard = "..dataset..", 
      values = c("data1", "data2", "data3"), expand = T), 
    data.frame(
      target = c("analysis1_data1", "analysis1_data2", "analysis1_data3", 
        "goof", "analysis2_data1", "analysis2_data2", "analysis2_data3"),
      command = c("analyze1(data1)", "analyze1(data2)", "analyze1(data3)", 
        "ls()", "analyze2(data1)", "analyze2(data2)", "analyze2(data3)"),
      stringsAsFactors = F))

  testrm("evaluate")
})

test_that("Function evaluate() is correct using the rules arg with expand = TRUE.", {
  testwd("evaluateTRUE")
  expect_equal(evaluate(example_analyses()), example_analyses())
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
  
  out1 = evaluate(df, rules = list(ARG1 = 1:2))
  out2 = evaluate(df, rules = list(ARG2 = 10:11))
  out12 = evaluate(df, rules = list(ARG1 = 1:2, ARG2 = strings(x, y)))
  
  expect_equal(out1, end1)
  expect_equal(out2, end2)
  expect_equal(out12, end12)
  
  testrm("evaluateTRUE")
})

test_that("Function evaluate() is correct using the rules arg with expand = FALSE.", {
  testwd("evaluateFALSE")
  expect_equal(evaluate(example_analyses(), expand = F), example_analyses())
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
  out = evaluate(df, rules = list(ARG1 = 1:2, ARG2 = strings(x, y)), expand = F)
  expect_equal(out, end)
  testrm("evaluateFALSE")
})

test_that("Function evaluate() interprets arguments correctly", {
  df = data.frame(target = c("d1", "d2", "d3", "d4"), command = strings(
    f1(mine = 1),
    f2(x, arg1 = ARG1),
    f3(x, arg1 = ARG1, arg2 = ARG2),
    f4(arg1 = ARG1, arg2 = ARG2)
  ), stringsAsFactors = F)
  expect_error(evaluate(df, rules = "WRONG!"))
  end = data.frame(
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
  out1 = evaluate(df, rules = list(ARG1 = 1:2, ARG2 = strings(x, y)), wildcard = "ARG1")
  out2 = evaluate(df, rules = list(ARG1 = 1:2, ARG2 = strings(x, y)), wildcard = "ARG2")
  out3 = evaluate(df, rules = list(ARG1 = 1:2, ARG2 = strings(x, y)), values = 10:11)
  out4 = evaluate(df, rules = list(ARG1 = 1:2, ARG2 = strings(x, y)),
    wildcard = "ARG1", values = 5:6)
  out5 = evaluate(df, rules = list(ARG1 = 1:2, ARG2 = strings(x, y)), 
    wildcard = "ARG2", values = 7:8)
  for(i in 1:5) expect_equal(end, get(paste0("out", i)))
})

