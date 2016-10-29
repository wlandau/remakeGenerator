# library(testthat); library(remakeGenerator);
context("real_targets")
source("utils.R")

test_that("Function real_targets() is correct.", {
  testwd("real_targets")
  d1 = example_datasets()
  d1$depends = c("u, v", "w, x, y, z")
  d2 = example_analyses()
  x = list(datasets = d1, analyses = d2)

  ld = list(
    data1 = list(
      command = "df1(n = 10)",
      check = TRUE,
      depends = list("u", "v")
    ),
    data2 = list(
      command = "df2(n = 20)",
      check = FALSE,
      depends = list("w", "x", "y", "z")
    ),
    analysis1 = list(command = "analyze1(..dataset..)"),
    analysis2 = list(command = "analyze2(..dataset..)"))

  expect_error(real_targets())
  expect_error(real_targets(d1))
  expect_error(real_targets(datasets = d1, analyses = d1))
  expect_equal(real_targets(x), ld)
  testrm("real_targets")
})
