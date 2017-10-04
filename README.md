# Drake, the successor to remakeGenerator

[Drake](https://github.com/wlandau-lilly/drake) is a newer, standalone, [CRAN-published](https://CRAN.R-project.org/package=drake) [Make](https://www.gnu.org/software/make/)-like build system. It has the convenience of [remakeGenerator](https://github.com/wlandau/remakeGenerator), the reproducibility of [remake](https://github.com/richfitz/remake), and more comprehensive built-in parallel computing functionality than [parallelRemake](https://github.com/wlandau/parallelRemake). `Drake` has far surpassed `remakeGenerator`, so `remakeGenerator` will only be minimally maintained going forward.

# remakeGenerator

[![Travis-CI Build Status](https://travis-ci.org/wlandau/remakeGenerator.svg?branch=master)](https://travis-ci.org/wlandau/remakeGenerator)
[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/wlandau/remakeGenerator?branch=master&svg=true)](https://ci.appveyor.com/project/wlandau/remakeGenerator)
[![codecov.io](https://codecov.io/github/wlandau/remakeGenerator/coverage.svg?branch=master)](https://codecov.io/github/wlandau/remakeGenerator?branch=master)
[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/remakeGenerator)](http://cran.r-project.org/package=remakeGenerator)

The `remakeGenerator` package is a helper add-on for [`remake`](https://github.com/richfitz/remake), a [Makefile](https://www.gnu.org/software/make/)-like reproducible build system for R. If you haven't done so already, go learn [`remake`](https://github.com/richfitz/remake)! Once you do that, you will be ready to use `remakeGenerator`. With `remakeGenerator`, your long and cumbersome workflows will be

- **Quick to set up**. You can plan a large workflow with a small amount of code.
- **Reproducible**. Reproduce computation with `remake::make()` or [GNU Make](https://www.gnu.org/software/make/).
- **Development-friendly**. Thanks to [`remake`](https://github.com/richfitz/remake), whenever you change your code, your next computation will only run the parts that are new or out of date.
- **Parallelizable**. Distribute your workflow over multiple parallel processes with a single flag in [GNU Make](https://www.gnu.org/software/make/).

The `remakeGenerator` package accomplishes this by generating [YAML](http://yaml.org/) files for [`remake`](https://github.com/richfitz/remake) that would be too big to type manually.

# Installation

First, ensure that [R](https://www.r-project.org/) is installed, as well as the dependencies in the [`DESCRIPTION`](https://github.com/wlandau/remakeGenerator/blob/master/DESCRIPTION). To install the [latest CRAN release](https://cran.r-project.org/web/packages/remakeGenerator/), run

```r
install.packages("remakeGenerator")
```

To install the development version, get the [devtools](https://cran.r-project.org/web/packages/devtools/) package and then run 

```r
devtools::install_github("wlandau/remakeGenerator", build = TRUE)
```

If you specify a tag, you can install a GitHub release.

```r
devtools::install_github("wlandau/remakeGenerator@v0.1.0", build = TRUE)
```


# Rtools for Windows users

Windows users may need [`Rtools`](https://github.com/stan-dev/rstan/wiki/Install-Rtools-for-Windows) to take full advantage of `remakeGenerator`'s features, specifically to run [Makefiles](https://www.gnu.org/software/make/) with `system("make")`.

# Tutorial

The [online package vignette](https://github.com/wlandau/remakeGenerator/blob/master/vignettes/remakeGenerator.Rmd) has a complete tutorial. You can the load the compiled version from an R session.

```r
vignette("remakeGenerator")
```


# Help and troubleshooting

Use the `help_remakeGenerator()` function to obtain a collection of helpful links. For troubleshooting, please refer to [TROUBLESHOOTING.md](https://github.com/wlandau/remakeGenerator/blob/master/TROUBLESHOOTING.md) on the [GitHub page](https://github.com/wlandau/remakeGenerator) for instructions.


# Acknowledgements

This package stands on the shoulders of [Rich FitzJohn](https://richfitz.github.io/)'s [`remake`](https://github.com/richfitz/remake) package.
