# library(testthat); devtools::load_all();
context("examples")
source("utils.R")

assert_files = function(stage = 0){
  init = strings(code.R, latex.Rnw, markdown.Rmd, workflow.R)
  gen = strings(Makefile, remake.yml)
  run = strings(.remake, coef.csv, latex.tex, markdown.md, mse.pdf)
  if(stage == 1){
    all(file.exists(init)) & all(!file.exists(c(gen, run)))
  } else if(stage == 2){
    all(file.exists(c(init, gen)))
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
    x = readLines("workflow.R")[-1]
    unlink("workflow.R")
    writeLines(x, "workflow.R")
    expect_equal(parallelRemake::recallable(), character(0))
    source("workflow.R")
    expect_true(assert_files(2))
    expect_true(length(parallelRemake::recallable()) > 1)
    setwd("..")
    unlink(i, recursive = TRUE)
  }
  testrm("basic-flexible")
})
