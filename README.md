# remakeGenerator

`remakeGenerator` is a helper add-on package for [`remake`](https://github.com/richfitz/remake), an awesome reproducible build system for R. If you haven't done so already, go learn [`remake`](https://github.com/richfitz/remake)! Once you do that, you will be ready to use `remakeGenerator`. With `remakeGenerator`, your long and cumbersome workflows will be

- **Quick to set up**. Plan a large workflow with minimal code and a call to the `workflow()` function.
- **Reproducible**. Reproduce computation with `remake::make()` or [GNU Make](https://www.gnu.org/software/make/).
- **Development-friendly**. Thanks to [`remake`](https://github.com/richfitz/remake), whenever you change your code, your next computation will only run the parts that are new or out of date.
- **Parallelizable**. Easily distribute your workflow over multiple parallel processes with [GNU Make](https://www.gnu.org/software/make/).


# Installation

Ensure that [R](https://www.r-project.org/) and [GNU Make](https://www.gnu.org/software/make/) are installed, as well as the dependencies in the [`DESCRIPTION`](https://github.com/wlandau/remakeGenerator/blob/master/DESCRIPTION). Open an R session and run 

```
library(devtools)
install_github("wlandau/remakeGenerator")
```

Alternatively, you can build the package from the source and install it by hand. First, ensure that [git](https://git-scm.com/) is installed. Next, open a [command line program](http://linuxcommand.org/) such as [Terminal](https://en.wikipedia.org/wiki/Terminal_%28OS_X%29) and enter the following commands.

```
git clone git@github.com:wlandau/remakeGenerator.git
R CMD build remakeGenerator
R CMD INSTALL ...
```

where `...` is replaced by the name of the tarball produced by `R CMD build`.

Windows users may need [`Rtools`](https://github.com/stan-dev/rstan/wiki/Install-Rtools-for-Windows) to take full advantage of `remakeGenerator`'s features, particularly to run [Makefiles](https://www.gnu.org/software/make/) with `system("make")`.

# Example 1 Quickstart

Write the files for [Example 1](https://github.com/wlandau/remakeGenerator/tree/master/inst/example1) using

```r
library(remakeGenerator)
example_remakeGenerator(1)
```

Run [`workflow.R`](https://github.com/wlandau/remakeGenerator/blob/master/inst/example1/workflow.R) to produce `remake.yml` and the [Makefile](https://www.gnu.org/software/make/).

```r
source("workflow.R")
```

Then, run the full example directly through [`remake`](https://github.com/richfitz/remake)

```r
remake::make()
```

or with the [Makefile](https://www.gnu.org/software/make/)

```r
system("make")
```

Alternatively, distribute the work four parallel processes with

```r
system("make -j 4")
```

# Deeper look at [`workflow.R`](https://github.com/wlandau/remakeGenerator/blob/master/inst/example1/workflow.R)

[`workflow.R`](https://github.com/wlandau/remakeGenerator/blob/master/inst/example1/workflow.R) is the master plan of the analysis. It arranges the helper functions in [`code.R`](https://github.com/wlandau/remakeGenerator/blob/master/inst/example1/code.R) to

1. Generate some datasets.

```r
library(remakeGenerator)
datasets = commands(
  normal16 = normal_dataset(n = 16),
  poisson32 = poisson_dataset(n = 32),
  poisson64 = poisson_dataset(n = 64)
)
```

2. Analyze each dataset with each of two methods of analysis.

```r
analyses = analyses(
  commands = commands(
    linear = linear_analysis(..dataset..),
    quadratic = quadratic_analysis(..dataset..)), 
  datasets = datasets)
```

3. Summarize each analysis of each dataset

```r
summaries = summaries(
  commands = commands(
    mse = mse_summary(..dataset.., ..analysis..),
    coef = coefficients_summary(..analysis..)), 
  analyses = analyses, datasets = datasets)
```

4. Gather the summaries into manageable lists (or matrices using `gather(..., aggregator = "cbind")`.

```r
mse = gather(summaries[1:6,], target = "mse")
coef = gather(summaries[7:12,], target = "coef")
```

5. Compute output on the summaries.

```r
output = commands(
  coef_table = do.call(I("rbind"), coef),
  coef.csv = write.csv(coef_table, target_name),
  mse_vector = unlist(mse)
)
```

6. Generate plots.

```r
plots = commands(
  mse.pdf = hist(mse_vector, col = I("black"))
)
plots$plot = TRUE
```

7. Compile reports, [`knitr`](http://yihui.name/knitr/) or otherwise.

```r
reports = data.frame(target = strings(markdown.md, latex.tex),
  depends = c("poisson32, coef_table, coef.csv", ""))
reports$knitr = TRUE
```


