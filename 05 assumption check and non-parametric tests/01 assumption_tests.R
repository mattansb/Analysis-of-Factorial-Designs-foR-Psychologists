library(afex)

# Load the functions from Mattan's GitHub
source("residuals_qqplot.R")

# Fit the ANOVA model
data(obk.long, package = "afex")
fit <- aov_ez('id', 'value', obk.long,
              between = c('treatment', 'gender'),
              within = c('phase', 'hour'))

# Test
test_levene(fit)
test_sphericity(fit)
residuals_qqplot(fit) # what are we looking for here?
