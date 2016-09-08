# remakeGenerator

The `remakeGenerator` package is a helper add-on for [`remake`](https://github.com/richfitz/remake), an awesome reproducible build system for R. If you haven't done so already, go learn [`remake`](https://github.com/richfitz/remake)! Once you do that, you will be ready to use `remakeGenerator`. With `remakeGenerator`, your long and cumbersome workflows will be

- **Quick to set up**. You can plan a large workflow with a small amount of code.
- **Reproducible**. Reproduce computation with `remake::make()` or [GNU Make](https://www.gnu.org/software/make/).
- **Development-friendly**. Thanks to [`remake`](https://github.com/richfitz/remake), whenever you change your code, your next computation will only run the parts that are new or out of date.
- **Parallelizable**. Distribute your workflow over multiple parallel processes with a single flag in [GNU Make](https://www.gnu.org/software/make/).


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

Windows users may need [`Rtools`](https://github.com/stan-dev/rstan/wiki/Install-Rtools-for-Windows) to take full advantage of `remakeGenerator`'s features, specifically to run [Makefiles](https://www.gnu.org/software/make/) with `system("make")`.

# Example 1 Quickstart

Write the files for [Example 1](https://github.com/wlandau/remakeGenerator/tree/master/inst/example1) using

```r
library(remakeGenerator)
example_remakeGenerator(index = 1)
```

Run [`workflow.R`](https://github.com/wlandau/remakeGenerator/blob/master/inst/example1/workflow.R) to produce the required  [`remake`](https://github.com/richfitz/remake) file `remake.yml`, along with the optional [Makefile](https://www.gnu.org/software/make/).

```r
source("workflow.R")
```

Then, run the full example directly through [`remake`](https://github.com/richfitz/remake)

```r
remake::make()
```

or indirectly through the [Makefile](https://www.gnu.org/software/make/) (which calls `remake::make()` on `remake.yml` for individual targets).

```r
system("make")
```

Alternatively, distribute the work over four parallel processes with

```r
system("make -j 4")
```

# A walk through [`workflow.R`](https://github.com/wlandau/remakeGenerator/blob/master/inst/example1/workflow.R)

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
    
4. Gather the summaries into manageable lists (or matrices using `gather(..., aggregator = "rbind")`).

    ```r
    mse = gather(summaries[1:6,], target = "mse")
    coef = gather(summaries[7:12,], target = "coef", aggregator = "rbind")
    ```
    
5. Compute output on the summaries.

    ```r
    output = commands(
      coef.csv = write.csv(coef, target_name),
      mse_vector = unlist(mse))
    ```
    
6. Generate plots.

    ```r
    plots = commands(mse.pdf = hist(mse_vector, col = I("black")))
    plots$plot = TRUE
    ```
    
7. Compile reports, [`knitr`](http://yihui.name/knitr/) or otherwise.

    ```r
    reports = data.frame(target = strings(markdown.md, latex.tex),
      depends = c("poisson32, coef, coef.csv", ""))
    reports$knitr = TRUE
    ```
    
With these stages of the workflow planned, `workflow.R` collects all the 
[`remake`](https://github.com/richfitz/remake) targets into one [YAML](http://yaml.org/)-like list

```r
targets = targets(datasets = datasets, analyses = analyses, summaries = summaries, 
  mse = mse, coef = coef, output = output, plots = plots, reports = reports)
```

and then generates the [`remake.yml`](https://github.com/richfitz/remake) file and the [Makefile](https://www.gnu.org/software/make/) (tools to run or update the workflow reporducibly).


```r
workflow(targets, sources = "code.R", packages = "MASS", 
  begin = c("# Prepend this", "# to the Makefile."))
```

All that remains is to actually run or update the workflow with `remake::make()` or `system("make")` or `system("make -j 2")`, etc.

# Running intermediate stages

You can run each intermediate stage by itself (conditional, of course, on the dependencies). For example, to just build the summaries and then stop, use 

```r
remake::make("summaries")
```

or

```r
system("make summaries")
```

To remove the intermediate files and final results, run

```r
remake::make("clean")
```

or

```r
system("make clean")
```

# The framework

At each stage (`datasets`, `analyses`, `summaries`, `mse`, etc.), the user supplies named R commands. The commands are then arranged into a data frame, such as the `datasets` data frame from Example 1.

```r
> datasets
     target                 command
1  normal16  normal_dataset(n = 16)
2 poisson32 poisson_dataset(n = 32)
3 poisson64 poisson_dataset(n = 64)
```

Above, each row stands for an individual [`remake`](https://github.com/richfitz/remake) target, and the `target` column contains the name of the target. Each command is the R function call that produces its respective target. With the exception of "`target`", each column of each  data frame represents a target-specific field in the [`remake.yml`](https://github.com/richfitz/remake) file. If additional fields are needed, just append the appropriate columns to the data frame. In [`workflow.R`](https://github.com/wlandau/remakeGenerator/blob/master/inst/example1/workflow.R), the `plot` and `knitr` fields were added this way to the `plots` and `reports` data frames, respectively. Recall from [`remake`](https://github.com/richfitz/remake) that setting `plot` to `TRUE` automatically sends the output of the command to a plot

```r
> plots
   target                            command plot
1 mse.pdf hist(mse_vector, col = I("black")) TRUE
```

and setting `knitr` to `TRUE` compiles `.md` and `.tex` target files from `.Rmd` and `.Rnw` files, respectively.

```r
> reports
       target                         depends knitr
1 markdown.md poisson32, coef, coef.csv  TRUE
2   latex.tex   
```

Above, and in the general case, each `depends` field is a character string of comma-separated [`remake`](https://github.com/richfitz/remake) dependencies. Dependencies that are arguments to commands are automatically resolved and should not be restated in `depends`. However, for [`knitr`](http://yihui.name/knitr/) reports, every dependency must be explicitly given in the `depends` field.

In generating the `analyses` and `summaries` data frames, you may have noticed the `..dataset..` and `..analysis..` symbols. Those are wildcard placeholders indicating that the respective commands will iterate over each dataset and each analysis of each dataset. The `analyses()` function turns 

```r
> commands(linear = linear_analysis(..dataset..), quadratic = quadratic_analysis(..dataset..))
     target                         command
1    linear    linear_analysis(..dataset..)
2 quadratic quadratic_analysis(..dataset..)
```

into

```r
               target                       command
1     linear_normal16     linear_analysis(normal16)
2    linear_poisson32    linear_analysis(poisson32)
3    linear_poisson64    linear_analysis(poisson64)
4  quadratic_normal16  quadratic_analysis(normal16)
5 quadratic_poisson32 quadratic_analysis(poisson32)
6 quadratic_poisson64 quadratic_analysis(poisson64)
```

and the `summaries()` function turns

```r
> commands(mse = mse_summary(..dataset.., ..analysis..), coef = coefficients_summary(..analysis..))
  target                                command
1    mse mse_summary(..dataset.., ..analysis..)
2   coef     coefficients_summary(..analysis..)
```

into

```r
                     target                                     command
1       mse_linear_normal16      mse_summary(normal16, linear_normal16)
2      mse_linear_poisson32    mse_summary(poisson32, linear_poisson32)
3      mse_linear_poisson64    mse_summary(poisson64, linear_poisson64)
4    mse_quadratic_normal16   mse_summary(normal16, quadratic_normal16)
5   mse_quadratic_poisson32 mse_summary(poisson32, quadratic_poisson32)
6   mse_quadratic_poisson64 mse_summary(poisson64, quadratic_poisson64)
7      coef_linear_normal16       coefficients_summary(linear_normal16)
8     coef_linear_poisson32      coefficients_summary(linear_poisson32)
9     coef_linear_poisson64      coefficients_summary(linear_poisson64)
10  coef_quadratic_normal16    coefficients_summary(quadratic_normal16)
11 coef_quadratic_poisson32   coefficients_summary(quadratic_poisson32)
12 coef_quadratic_poisson64   coefficients_summary(quadratic_poisson64)
```

# Where is my output?

Intermediate objects such as datasets, analyses, and summaries are maintained in [`remake`](https://github.com/richfitz/remake)'s hidden [`storr`](https://github.com/richfitz/storr) cache, located in the hidden `.remake/objects/` folder. To inspect your workflow, you can list the generated objects using `parallelRemake::recallable()` and load an object using `parallelRemake::recall()`. After running Example 1, we see the following.

```r
> library(parallelRemake)
> recallable()
 [1] "coef"                     "coef_linear_normal16"    
 [3] "coef_linear_poisson32"    "coef_linear_poisson64"   
 [5] "coef_quadratic_normal16"  "coef_quadratic_poisson32"
 [7] "coef_quadratic_poisson64" "linear_normal16"         
 [9] "linear_poisson32"         "linear_poisson64"        
[11] "mse"                      "mse_linear_normal16"     
[13] "mse_linear_poisson32"     "mse_linear_poisson64"    
[15] "mse_quadratic_normal16"   "mse_quadratic_poisson32" 
[17] "mse_quadratic_poisson64"  "mse_vector"              
[19] "normal16"                 "poisson32"               
[21] "poisson64"                "quadratic_normal16"      
[23] "quadratic_poisson32"      "quadratic_poisson64"   
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

**Do not integrate `recall()` or `recallable()` into serious production-level workflows because operations on the [`storr`](https://github.com/richfitz/storr) cache are not reproducibly tracked.**

# High-performance computing

If you want to run `make -j` to distribute tasks over multiple nodes of a [Slurm](http://slurm.schedmd.com/) cluster, refer to the Makefile in [this post](http://plindenbaum.blogspot.com/2014/09/parallelizing-gnu-make-4-in-slurm.html) and write

```{r}
workflow(..., 
  begin = c(
    "SHELL=srun",
    ".SHELLFLAGS= <ARGS> bash -c"))
```

where `<ARGS>` stands for additional arguments to `srun`. Then, once the [Makefile](https://www.gnu.org/software/make/) is generated, you can run the workflow with
`nohup make -j [N] &` in the command line, where `[N]` is the maximum number of simultaneous processes.
For other task managers such as [PBS](https://en.wikipedia.org/wiki/Portable_Batch_System), such an approach may not be possible because there may not be a shell-like equivalent to `srun`. Regardless of the system, be sure that all nodes point to the same working directory so that they share the same `.remake` [storr](https://github.com/richfitz/storr) cache.


# Use with the [downsize](https://github.com/wlandau/downsize) package

You may want to use the [downsize](https://github.com/wlandau/downsize) package within your custom R source code (i.e., [`code.R`](https://github.com/wlandau/remakeGenerator/blob/master/inst/example1/code.R)). That way, you can run a quick scaled-down version of your workflow for debugging and testing before you run the full load. In Example 1, simply include `"downsize"` in the `packages` argument to `workflow()` and replace the top few lines of [`code.R`](https://github.com/wlandau/remakeGenerator/blob/master/inst/example1/code.R) with the following.

```{r}
library(downsize)
scale_down()

normal_dataset = function(n = 16){
  ds(data.frame(x = rnorm(n, 1), y = rnorm(n, 5)), nrow = 4)
}

poisson_dataset = function(n = 16){
  ds(data.frame(x = rpois(n, 1), y = rpois(n, 5)), nrow = 4)
}
```

Above, `scale_down()` sets the `downsize` option to `TRUE`, which is a signal to the `ds()` function. The command `ds(A, ...)` says "Downsize A to a some other object when `getOption("downsize")` is `TRUE`". To switch to the full scaled-up workflow, just delete the first two lines or replace `scale_down()` with `scale_up()`. Unfortunately, [`remake`](https://github.com/richfitz/remake) does not rebuild targets in response to changes to global options, so you will have to run `make clean`, etc. whenever you scale up or down.


# Flexibility

Some workflows do not fit the rigid structure of [Example 1](https://github.com/wlandau/remakeGenerator/tree/master/inst/example1) but could still benefit from the automated generation of [`remake.yml`](https://github.com/richfitz/remake) files and [Makefiles](https://www.gnu.org/software/make/). If you supply the appropriate data frames to the `targets()` function, you can customize your own analyses. Here, the `expand()` and `evaluate()` functions are essential to flexibility. The `expand()` function replicates targets generated by the same commands, and the `evaluate()` function lets you create and evaluate your own wildcard placeholders. For a demonstration, see [Example 2](https://github.com/wlandau/remakeGenerator/tree/master/inst/example2), which almost the same as [Example 1](https://github.com/wlandau/remakeGenerator/tree/master/inst/example1) except that it uses `expand()` and `evaluate()` explicitly. 
