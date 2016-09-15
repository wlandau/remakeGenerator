# library(testthat); library(remakeGenerator);
context("examples")
source("utils.R")

assert_files = function(stage = 0){
  init = strings(code.R, latex.Rnw, markdown.Rmd, workflow.R)
  gen = strings(Makefile, remake.yml)
  run = strings(.remake, coef.csv, latex.tex, markdown.md, mse.pdf)
  if(stage == 0){
    all(!file.exists(c(init, gen, run)))
  } else if(stage == 1){
    all(file.exists(init)) & all(!file.exists(c(gen, run)))
  } else if(stage == 2){
    all(file.exists(c(init, gen))) & all(!file.exists(run))
  } else if(stage == 3){
    all(file.exists(c(init, gen, run)))
  } else if(stage == 4){
    all(file.exists(c(init, gen))) & all(!file.exists(setdiff(run, ".remake")))
  } else {
    stop("Bad stage index in test.")
  }
}

test_that("Examples run as expected", {
  for(i in 1:2){
    testwd(paste0("example", i))
    expect_true(assert_files(0))
    example_remakeGenerator(i)
    expect_true(assert_files(1))
    source("workflow.R")
    expect_true(assert_files(2))
    expect_equal(readLines("Makefile")[-1], 
      readLines(file.path("..", "test-examples", paste0("Makefile", i)))[-1])
    expect_equal(readLines("remake.yml"), 
      readLines(file.path("..", "test-examples", paste0("remake", i, ".yml"))))
    expect_equal(parallelRemake::recallable(), character(0))
    remake::make(verbose = F)
    expect_equal(parallelRemake::recallable(), 
      scan(file.path("..", "test-examples", paste0("recallable", i, ".txt")), 
      what = character(), quiet = T))
    expect_true(assert_files(3))
    tab = read.csv("coef.csv")
    tab0 = read.csv(file.path("..", "test-examples", paste0("coef", i, ".csv")))
    expect_true(mean(unlist(tab[,2:4]) - unlist(tab0[,2:4])) < 10)
    tab[1:12, 2:4] = tab0[1:12, 2:4] = 0
    expect_equal(tab, tab0)
    expect_true(length(readLines("latex.tex")) > 20)
    expect_true(length(readLines("markdown.md")) > 20)
    remake::make("clean", verbose = F)
    expect_true(assert_files(4))
    testrm(paste0("example", i))
  }
})
