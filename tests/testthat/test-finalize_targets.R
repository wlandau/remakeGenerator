# library(testthat); library(remakeGenerator);
context("finalize_targets")
source("utils.R")

test_that("Function finalize_targets() is correct.", {
  testwd("finalize_targets")
  d1 = example_datasets()
  d1$depends = c("u, v", "w, x, y, z")
  d2 = example_analyses()
  x = list(datasets = d1, analyses = d2)
  y = fake_targets(x)
  z = real_targets(x)

  ld = list(
    all = list(depends = list("datasets", "analyses")),
    datasets = list(depends = list("data1", "data2")),
    analyses = list(depends = list("analysis1", "analysis2")),
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
    analysis2 = list(command = "analyze2(..dataset..)")
  )

  expect_error(finalize_targets(), NULL)
  expect_error(finalize_targets(d1))
  expect_error(finalize_targets(datasets = d1, analyses = d1))
  expect_equal(finalize_targets(y, z), ld)
  testrm("finalize_targets")
})
