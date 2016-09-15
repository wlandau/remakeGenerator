# library(testthat); library(remakeGenerator);
context("targets")
source("utils.R")

test_that("Function targets() is correct.", {
  testwd("targets")
  d1 = example_datasets()
  d1$depends = c("u, v", "w, x, y, z")
  d2 = example_analyses()

  ld1 = list(
    all = list(depends = list("datasets")),
    datasets = list(depends = list("data1", "data2")),
    data1 = list(
      command = "df1(n = 10)",
      check = TRUE,
      depends = list("u", "v")
    ),
    data2 = list(
      command = "df2(n = 20)",
      check = FALSE,
      depends = list("w", "x", "y", "z")
    )
  )

  ld2 = list(
    all = list(depends = list("analyses")),
    analyses = list(depends = list("analysis1", "analysis2")),
    analysis1 = list(command = "analyze1(..dataset..)"),
    analysis2 = list(command = "analyze2(..dataset..)")
  )

  ld3 = list(
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

  expect_equal(targets(), NULL)
  expect_error(targets(d1))
  expect_error(targets(datasets = d1, analyses = d1))
  expect_equal(targets(datasets = d1), ld1)
  expect_equal(targets(analyses = d2), ld2)
  expect_equal(targets(datasets = d1, analyses = d2), ld3)
  testrm("targets")
})
