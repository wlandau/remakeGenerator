# library(testthat); library(remakeGenerator);
context("fake_targets")
source("utils.R")

test_that("Function fake_targets() is correct.", {
  testwd("fake_targets")
  d1 = example_datasets()
  d1$depends = c("u, v", "w, x, y, z")
  d2 = example_analyses()
  x = list(datasets = d1, analyses = d2)

  ld = list(
    all = list(depends = list("datasets", "analyses")),
    datasets = list(depends = list("data1", "data2")),
    analyses = list(depends = list("analysis1", "analysis2")))

  expect_error(fake_targets(), NULL)
  expect_error(fake_targets(d1))
  expect_error(fake_targets(datasets = d1, analyses = d1))
  expect_equal(fake_targets(x), ld)
  testrm("fake_targets")
})
