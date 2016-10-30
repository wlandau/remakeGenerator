library(remakeGenerator)

datasets = commands(
  normal16 = normal_dataset(n = 16),
  poisson32 = poisson_dataset(n = 32),
  poisson64 = poisson_dataset(n = 64))

analyses = analyses(
  commands = commands(
    linear = linear_analysis(..dataset..),
    quadratic = quadratic_analysis(..dataset..)), 
  datasets = datasets)

summaries = summaries(
  commands = commands(
    mse = mse_summary(..dataset.., ..analysis..),
    coef = coefficients_summary(..analysis..)), 
  analyses = analyses, datasets = datasets, gather = strings(c, rbind))

output = commands(coef.csv = write.csv(coef, target_name))

plots = commands(mse.pdf = hist(mse, col = I("black")))
plots$plot = TRUE

reports = data.frame(target = strings(markdown.md, latex.tex),
  depends = c("poisson32, coef, coef.csv", ""))
reports$knitr = TRUE

targets = targets(datasets = datasets, analyses = analyses, summaries = summaries, 
  output = output, plots = plots, reports = reports)

workflow(targets, sources = "code.R", packages = "MASS", 
  begin = c("# Prepend this", "# to the Makefile."))

###############################################
### Now, run remake::make() or the Makefile ###
###############################################
