#' @title Function \code{help_remakeGenerator}
#' @description Prints links for tutorials, troubleshooting, bug reports, etc.
#' @seealso \code{\link{workflow}}
#' @export
help_remakeGenerator = function(){
  cat(
#    "The package vignette has a full tutorial, and it is available at the following webpages.",
#    "    https://CRAN.R-project.org/package=remakeGenerator/vignettes/remakeGenerator.html",
#    "    https://cran.r-project.org/web/packages/remakeGenerator/vignettes/remakeGenerator.html",
    "The vignette of the development version has a full tutorial at the webpage below.",
    "    http://will-landau.com/remakeGenerator/articles/remakeGenerator.html",
    "For troubleshooting, navigate to the link below.",
    "    https://github.com/wlandau/remakeGenerator/blob/master/TROUBLESHOOTING.md",
    "To submit bug reports, usage questions, feature requests, etc., navigate to the link below.",
    "    https://github.com/wlandau/remakeGenerator/issues",
  sep = "\n")
}
