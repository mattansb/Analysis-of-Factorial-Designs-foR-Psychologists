library(afex)
# library(qqplotr) # also needed

# Fit the ANOVA model
data(obk.long, package = "afex")
head(obk.long)

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
source("qqnorm.afex_aov.R")
qqnorm(fit)
qqnorm(fit, detrend = TRUE)
qqnorm(fit, type = "univariate") # what are we looking for here?
qqnorm(fit, type = "multivariate") # and what are we looking for HERE?


ggResidpanel::resid_auxpanel(residuals = residuals(fit),
                             predicted = fitted(fit),
                             qqbands = TRUE)


