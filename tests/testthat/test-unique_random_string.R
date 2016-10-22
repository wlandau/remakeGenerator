# library(testthat); library(remakeGenerator);
context("unique_random_string")
source("utils.R")

test_that("Function unique_random_string() is correct.", {
  for(i in c(23, 37, 5)) expect_equal(nchar(unique_random_string(n = i)), i)
  exclude = c(1:9, letters, LETTERS)
  for(i in 1:10) expect_equal("0", unique_random_string(exclude, n = 1))
  exclude = c(0:9, letters[-5], LETTERS)
  for(i in 1:10) expect_equal("e", unique_random_string(exclude, n = 1))
})
