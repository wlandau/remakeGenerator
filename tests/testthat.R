library(remakeGenerator)
library(testthat)

Sys.setenv("R_TESTS" = "")
test_check("remakeGenerator")
