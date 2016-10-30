# library(testthat); library(remakeGenerator);
context("examples")
source("utils.R")

assert_files = function(stage = 0){
  init = strings(code.R, latex.Rnw, markdown.Rmd, workflow.R)
  gen = strings(Makefile, remake.yml)
  run = strings(.remake, coef.csv, latex.tex, markdown.md, mse.pdf)
  if(stage == 1){
    all(file.exists(init)) & all(!file.exists(c(gen, run)))
  } else if(stage == 2){
    all(file.exists(c(init, gen))) & all(!file.exists(run))
  } else if(stage == 3){
    all(file.exists(c(init, gen, run)))
  } else {
    stop("Bad stage index in test.")
  }
}

test_that("Basic checks on functions for examples are met.", {
  expect_silent(list_examples_remakeGenerator())
  expect_gt(length(list_examples_remakeGenerator()), 0)
  expect_error(example_remakeGenerator("asldjflkdsjfkahjsdljfkhaslkdjflkjasdlfkjasldkf"))
})

test_that("Basic and flexible examples run as expected", {
  testwd("basic-flexible")
  for(i in c("basic", "flexible")){
    example_remakeGenerator(i)
    setwd(i)
    expect_true(assert_files(1))
    source("workflow.R")
    expect_true(assert_files(2))
    expect_equal(readLines("Makefile")[-1], 
      readLines(file.path("..", "..", "test-examples", paste0("Makefile_", i)))[-1])
    expect_equal(readLines("remake.yml"), 
      readLines(file.path("..", "..", "test-examples", paste0("remake_", i, ".yml"))))
    expect_equal(parallelRemake::recallable(), character(0))
    remake::make(verbose = F)
    expect_equal(parallelRemake::recallable(), 
      scan(file.path("..", "..", "test-examples", paste0("recallable_", i, ".txt")), 
      what = character(), quiet = T))
    expect_true(assert_files(3))
    tab = read.csv("coef.csv")
    tab0 = read.csv(file.path("..", "..", "test-examples", paste0("coef_", i, ".csv")))
    expect_true(mean(unlist(tab[,2:4]) - unlist(tab0[,2:4])) < 10)
    tab[1:12, 2:4] = tab0[1:12, 2:4] = 0
    expect_equal(tab, tab0)
    expect_true(length(readLines("latex.tex")) > 20)
    expect_true(length(readLines("markdown.md")) > 20)
    setwd("..")
    unlink(i)
  }
  testrm("basic-flexible")
})
