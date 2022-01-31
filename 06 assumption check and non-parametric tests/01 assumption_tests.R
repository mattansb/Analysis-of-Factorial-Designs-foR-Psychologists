
library(afex)
library(ggeffects)    # for partial residual plots
library(performance)  # for check_*

# Fit the ANOVA model
data(obk.long, package = "afex")

fit <- aov_ez('id', 'value', obk.long,
              between = c('treatment', 'gender'),
              within = c('phase', 'hour'),
              covariate = "age", factorize = FALSE) # Fitting an ANCOVA

# As ANOVAs are a special case of linear regression (*), it has the same
# assumptions as linear regression. These assumptions can generally be split
# into two:
# - Assumptions of the Model
# - Assumptions of the Significant tests



# Assumptions of the Model ------------------------------------------------

# These assumptions are related to the *fit* of your model. But before these,
# there is one assumption that cannot be checked - that you are fitting the
# right KIND of model!
# Are you fitting a linear model to binary data? Are you fitting an ordinal
# regression to a scale outcome? This will necessarily be a bad fit... If the
# answer to any of these is yes, you should concider moving on to GLMMs.


## 1. "Linearity" -------------------------------

# Linear regression has this assumption, but for ANOVA this usually isn't
# needed. Why? Because all variables are categorical - they are "points" not
# part of some "line".
# However, if we have a continuous covariate (in an ANCOVA), we should check the
# linearity of the covariate.


ggemmeans(fit, c("age", "phase", "hour")) |>
  plot(residuals = TRUE, residuals.line = TRUE)





## 2. No Collinearity ---------------------------

# You may have heard that while regression can tolerate low collinearity, ANOVA cannot
# tolerate ANY collinearity. Strictly speaking, this is not true - the ANOVA model will fit just fine, it will produce
# correct estimates, etc.
# What will be a problem is OUR interpretation of the effects. Instead of being
# the "effect of A on Y", we will need to interpret our effects as we would in
# a regression model: "the UNIQUE effect of A on Y". Bummer.

check_collinearity(fit)

# Not looking good...
# Seems like the "age" covariable is causing some trouble. Do we really need it?




# Assumptions of the Significance tests -----------------------------------


# Generally speaking, these assumptions are what allows us to convert Z and t
# values into probabilities (p-values). So any violation of these assumptions
# reduces the validity of our sig-tests.
#
# One assumption that all models have in common it that the prediction errors /
# residuals are independent of one another. When this assumption is violated it
# is sometimes called "autocorrelation". This assumption is hard to test, and it
# is usually easier to use knowledge about the data - for example, if we have a
# repeated measures design, or a nested design, then there is some dependency
# between the observations and we would therefor want to account for this by
# using a within/mixed ANOVA.








## 1. Homogeneity of Variance -------------------
# AKA Homoscedasticity


# (Note that this assumption is only relevant if we have between-subject groups
# in our design.)
check_homogeneity(fit)

# A more general version of this assumption is that of heteroskedasticity:
check_heteroskedasticity(fit)

# >>> What to do if violated? <<<
# Switch to non-parametric tests!






## 1b. Sphericity -------------------------------

# For within-subject conditions, we have an additional assumption, that of
# sphericity.
check_sphericity(fit)



# >>> What to do if violated? <<<
# - Use the Greenhouse-Geisser correction in the ANOVA table.
# - For contrasts, use the multivariate option.
# It's that easy!





## 1. Normality (of residuals) ------------------

# The least important assumption. Mild violations can be tolerated (but not if
# they suggest that the wrong kind of model was fitted!)


# Shapiro-Wilk test for the normality (of THE RESIDUALS!!!)
normtest <- check_normality(fit)

# But you should really LOOK at the residuals:
plot(normtest, type = "qq", detrend = FALSE)

parameters::describe_distribution(residuals(fit)) # Skewness & Kurtosis





# >>> What to do if violated? <<<
# This means that we shouldn't have used a Gaussian likelihood function (the
# normal distribution) in our model - so we can:
# 1. Try using a better one (using GLMMs)... A skewed or heavy tailed likelihood
#   function, or a completely different model family. Or...
# 2. Switch to non-parametric tests!





