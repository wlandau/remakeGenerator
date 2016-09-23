# remakeGenerator

[![Travis-CI Build Status](https://travis-ci.org/wlandau/remakeGenerator.svg?branch=master)](https://travis-ci.org/wlandau/remakeGenerator)
[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/wlandau/remakeGenerator?branch=master&svg=true)](https://ci.appveyor.com/project/wlandau/remakeGenerator)
[![codecov.io](https://codecov.io/github/wlandau/remakeGenerator/coverage.svg?branch=master)](https://codecov.io/github/wlandau/remakeGenerator?branch=master)

The `remakeGenerator` package is a helper add-on for [`remake`](https://github.com/richfitz/remake), a [Makefile](https://www.gnu.org/software/make/)-like reproducible build system for R. If you haven't done so already, go learn [`remake`](https://github.com/richfitz/remake)! Once you do that, you will be ready to use `remakeGenerator`. With `remakeGenerator`, your long and cumbersome workflows will be

- **Quick to set up**. You can plan a large workflow with a small amount of code.
- **Reproducible**. Reproduce computation with `remake::make()` or [GNU Make](https://www.gnu.org/software/make/).
- **Development-friendly**. Thanks to [`remake`](https://github.com/richfitz/remake), whenever you change your code, your next computation will only run the parts that are new or out of date.
- **Parallelizable**. Distribute your workflow over multiple parallel processes with a single flag in [GNU Make](https://www.gnu.org/software/make/).

The `remakeGenerator` package accomplishes this by generating [YAML](http://yaml.org/) files for [`remake`](https://github.com/richfitz/remake) that would be too big to type manually.

# Installation

Ensure that [R](https://www.r-project.org/) is installed, as well as the dependencies in the [`DESCRIPTION`](https://github.com/wlandau/remakeGenerator/blob/master/DESCRIPTION). Then, you can install one of the [stable releases](https://github.com/wlandau/remakeGenerator/releases). Download `remakeGenerator_<VERSION>.tar.gz` (where `<VERSION>` is the version number), open an R session, and run the following.

```r
install.packages("remakeGenerator_<VERSION>.tar.gz", repos = NULL, type = "source")
```

To install the development version, get the [devtools](https://cran.r-project.org/web/packages/devtools/) package and then run

```
devtools::install_github("wlandau/remakeGenerator")
```


# Rtools for Windows users

Windows users may need [`Rtools`](https://github.com/stan-dev/rstan/wiki/Install-Rtools-for-Windows) to take full advantage of `remakeGenerator`'s features, specifically to run [Makefiles](https://www.gnu.org/software/make/) with `system("make")`.

# Tutorial

The [online package vignette](https://github.com/wlandau/remakeGenerator/blob/master/vignettes/remakeGenerator.Rmd) has a complete tutorial.


# Help and troubleshooting

Use the `help_remakeGenerator()` function to obtain a collection of helpful links. For troubleshooting, please refer to [TROUBLESHOOTING.md](https://github.com/wlandau/remakeGenerator/blob/master/TROUBLESHOOTING.md) on the [GitHub page](https://github.com/wlandau/remakeGenerator) for instructions.


# Acknowledgements

This package stands on the shoulders of [Rich FitzJohn](https://richfitz.github.io/)'s [`remake`](https://github.com/richfitz/remake) package, an understanding of which is a prerequisite for this one.
