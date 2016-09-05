library(testthat)
library(remakeGenerator)

Sys.setenv("R_TESTS" = "")
test_check("remakeGenerator")
