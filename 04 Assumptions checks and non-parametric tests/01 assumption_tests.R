library(afex)

# Load the functions from Mattan's GitHub
source("https://gist.github.com/mattansb/e9c5a63a5cc74c4f535534cf740871bf/raw")

# Fit the ANOVA model
data(obk.long, package = "afex")
fit <- aov_ez('id', 'value', obk.long,
              between = c('treatment', 'gender'),
              within = c('phase', 'hour'))

# Test
test_levene(fit)
test_sphericity(fit)
residuals_qqplot(fit) # what are we looking for here?
