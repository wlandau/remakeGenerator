# Code for each component of the example analysis

# Generate datasets
normal_dataset = function(n = 16){
  data.frame(x = rnorm(n, 1), y = rnorm(n, 5))
}

poisson_dataset = function(n = 16){
  data.frame(x = rpois(n, 1), y = rpois(n, 5))
}

# Analyze each dataset
linear_analysis = function(dataset){
  lm(y ~ x, data = dataset)
}

quadratic_analysis = function(dataset){
  lm(y ~ x + I(x^2), data = dataset)
}

# Compute summaries
mse_summary = function(dataset, analysis){
  predictions = predict(analysis)
  mean((predictions - dataset$y)^2)
}

coefficients_summary = function(analysis){
  out = c(coefficients(analysis), "I(x^2)" = 0)[1:3]
}
