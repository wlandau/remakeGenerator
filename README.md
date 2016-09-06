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

# Walk through [`workflow.R`](https://github.com/wlandau/remakeGenerator/blob/master/inst/example1/workflow.R)

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

With these stages of the workflow planned, `workflow.R` gathers all the 
[`remake`](https://github.com/richfitz/remake) targets in one [YAML](http://yaml.org/)-like list

```r
targets = targets(datasets = datasets, analyses = analyses, summaries = summaries, 
  mse = mse, coef = coef, output = output, plots = plots, reports = reports)
```

and generates the [`remake.yml`](https://github.com/richfitz/remake) file and [Makefile](https://www.gnu.org/software/make/) to run or update the workflow reporducibly.


```r
workflow(targets, sources = "code.R", packages = "MASS", 
  begin = c("# prepend this", "# to the Makefile"))
```

All that remains is to actually run or update the workflow with `remake::make()` or `system("make")` or `system("make -j 4")`, etc.


# The framework

At each stage (`datasets`, `analyses`, `summaries`, `mse`, etc.), the user supplies named R commands. The commands are then arranged into a data frame. For example,

```r
> datasets
     target                 command
1  normal16  normal_dataset(n = 16)
2 poisson32 poisson_dataset(n = 32)
3 poisson64 poisson_dataset(n = 64)
```

The `target` is the name of the object to be generated, and `command` is a field in the [`remake.yml`](https://github.com/richfitz/remake) file. When additional fields are introduced in future versions of [`remake`](https://github.com/richfitz/remake) file, the user can simply add to them to the data frame. In [`workflow.R`](https://github.com/wlandau/remakeGenerator/blob/master/inst/example1/workflow.R), the `plot` and `knitr` fields were already added manually in the `plots` and `reports` data frames, respectively. Recall from [`remake`](https://github.com/richfitz/remake) that setting `plot` to `TRUE` automatically sends output to a plot

```r
> plots
   target                            command plot
1 mse.pdf hist(mse_vector, col = I("black")) TRUE
```

and setting `knitr` to `TRUE` compiles `.md` and `.tex` target files from `.Rmd` and `.Rnw` files, respectively.

```r
> reports
       target                         depends knitr
1 markdown.md poisson32, coef_table, coef.csv  TRUE
2   latex.tex   
```

# Running intermediate targets

You can run each stage by itself (conditional, of course, on the dependencies). For example, to just run the summaries and nothing else afterwards, use 

```r
remake::make("summaries")
```

or

```r
system("make summaries")
```

To clean up your work and remove all files generated from running the workflow

```r
remake::make("clean")
```

or

```r
system("make clean")
```

# Where's my output?

Intermediate objects such as datasets, analyses, and summaries are maintained in [`remake`](https://github.com/richfitz/remake)'s hidden [`storr`](https://github.com/richfitz/storr) cache (`.remake/objects/`). At any point in the workflow, you check the available objects using `recallable()` and load an object using `recall()`. After running Example 1, you can load the `parallelRemake` package and explore. 

```r
> library(parallelRemake)
> recallable()
 [1] "coef"                     "coef_linear_normal16"    
 [3] "coef_linear_poisson32"    "coef_linear_poisson64"   
 [5] "coef_quadratic_normal16"  "coef_quadratic_poisson32"
 [7] "coef_quadratic_poisson64" "coef_table"              
 [9] "linear_normal16"          "linear_poisson32"        
[11] "linear_poisson64"         "mse"                     
[13] "mse_linear_normal16"      "mse_linear_poisson32"    
[15] "mse_linear_poisson64"     "mse_quadratic_normal16"  
[17] "mse_quadratic_poisson32"  "mse_quadratic_poisson64" 
[19] "mse_vector"               "normal16"                
[21] "poisson32"                "poisson64"               
[23] "quadratic_normal16"       "quadratic_poisson32"     
[25] "quadratic_poisson64"     
> recall("normal16")
            x        y
1   1.5500328 4.226192
2   1.4714371 4.374820
3   0.4906371 6.228053
4   1.0086720 4.945609
5   1.3360642 5.619259
6   1.4899272 4.920836
7   0.7046544 4.926668
8   1.4092923 4.030779
9   2.5636956 6.026149
10 -0.5202316 4.368160
11  0.5540340 4.760691
12  1.6256007 4.722436
13  1.3210316 3.838017
14  0.8247446 2.708511
15  2.7262725 5.878415
16  2.3565342 4.445811
> 
```

Just be sure to avoid `recall()` and `recallable()` in your serious workflows since changes using these funcitons are not tracked. 

# Example 2



