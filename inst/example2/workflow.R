library(dplyr)
library(remakeGenerator)

# Generate 6 datasets: 2 replicates for each of following commands.
datasets = commands(
  normal16 = normal_dataset(n = 16),
  poisson32 = poisson_dataset(n = 32),
  poisson64 = poisson_dataset(n = 64)
) %>%
expand(values = c("rep1", "rep2"))

# Same as the analyses() function.
analyses = commands(
  linear = linear_analysis(..dataset..),
  quadratic = quadratic_analysis(..dataset..)
) %>% 
evaluate(wildcard = "..dataset..", values = datasets$target)

# Same as the summaries() function.
summaries = commands(
  mse = mse_summary(..dataset.., ..analysis..),
  coef = coefficients_summary(..analysis..)
) %>% 
evaluate(wildcard = "..analysis..", values = analyses$target) %>% 
evaluate(wildcard = "..dataset..", values = datasets$target, expand_x = FALSE)

# 24 datasets to summarize rather than 12.
mse = gather(summaries[1:12,], target = "mse")
coef = gather(summaries[13:24,], target = "coef")

output = commands(
  coef_table = do.call(I("rbind"), coef),
  coef.csv = write.csv(coef_table, target_name),
  mse_vector = unlist(mse)
)

plots = commands(mse.pdf = hist(mse_vector, col = I("black")))
plots$plot = TRUE

reports = data.frame(target = strings(markdown.md, latex.tex),
  depends = c("poisson32_rep1, coef_table, coef.csv", ""))
reports$knitr = TRUE

targets = targets(datasets = datasets, analyses = analyses, summaries = summaries, 
  mse = mse, coef = coef, output = output, plots = plots, reports = reports)
workflow(targets, sources = "code.R", packages = "MASS", 
  begin = c("# Prepend this", "# to the Makefile."))

###############################################
### Now, run remake::make() or the Makefile ###
###############################################
