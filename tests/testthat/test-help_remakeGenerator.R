# library(testthat); library(remakeGenerator)
context("help_remakeGenerator")

test_that("Function help_remakeGenerator() runs correctly", {
  expect_output(help_remakeGenerator())
})
