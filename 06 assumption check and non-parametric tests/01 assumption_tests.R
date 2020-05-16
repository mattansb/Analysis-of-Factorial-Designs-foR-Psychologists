library(afex)


# Fit the ANOVA model
data(obk.long, package = "afex")
fit <- aov_ez('id', 'value', obk.long,
              between = c('treatment', 'gender'),
              within = c('phase', 'hour'))


## Test homoscedasticity
# (for between sub vars)
test_levene(fit)


## Test sphericity
# (for within sub vars)
test_sphericity(fit)


## Test normality of residuals
source("residuals_qqplot.R")
# Load the function needed for plotting residuals:
#   - residuals.afex_aov - for getting the residuals from the model.
#   - residuals_qqplot - for plotting the qq plots right.

residuals_qqplot(fit)
residuals_qqplot(fit, by_term = TRUE) # what are we looking for here?
residuals_qqplot(fit, by_term = TRUE, model = "multi") # what are we looking for HERE?


