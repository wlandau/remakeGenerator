library(remakeGenerator)

datasets = commands(
  normal16 = normal_dataset(n = 16),
  poisson32 = poisson_dataset(n = 32),
  poisson64 = poisson_dataset(n = 64)
)

analyses = analyses(
  commands = commands(
    linear = linear_analysis(..dataset..),
    quadratic = quadratic_analysis(..dataset..)), 
  datasets = datasets)

summaries = summaries(
  commands = commands(
    mse = mse_summary(..dataset.., ..analysis..),
    coef = coefficients_summary(..analysis..)), 
  analyses = analyses, datasets = datasets)

mse = gather(summaries[1:6,], target = "mse")
coef = gather(summaries[7:12,], target = "coef")

output = commands(
  coef_table = do.call(I("rbind"), coef),
  coef.csv = write.csv(coef_table, target_name),
  mse_vector = unlist(mse)
)

plots = commands(
  mse.pdf = hist(mse_vector, col = I("black"))
)
plots$plot = TRUE

reports = data.frame(target = strings(markdown.md, latex.tex),
  depends = c("poisson32, coef_table, coef.csv", ""))
reports$knitr = TRUE

begin = c("# This is my Makefile", "# Variables...")
targets = targets(datasets = datasets, analyses = analyses, summaries = summaries, mse = mse, coef = coef, output = output, plots = plots, reports = reports)
workflow(targets, sources = "code.R", packages = "MASS", begin = begin)

###############################################
### Now, run remake::make() or the Makefile ###
###############################################
