library(afex)
library(BayesFactor)
library(bayestestR)

# Load data ---------------------------------------------------------------


Alcohol_data <- subset(readRDS("Alcohol_data.rds"),
                       # Looking only at the Frequency of interest
                       Frequency == '4to7Hz')

head(Alcohol_data)




# Regular ANOVA -----------------------------------------------------------

afex_options(es_aov         = 'pes',
             correction_aov = 'GG',
             emmeans_model  = 'univariate')

fit_alcohol_theta <- aov_ez('Subject','ersp',Alcohol_data,
                            within = c('Correctness'),
                            between = c('Alcohol'))
fit_alcohol_theta

afex_plot(fit_alcohol_theta,  ~ Alcohol,  ~ Correctness)
# Looks like no interaction. But we can't infer that based on frequentist
# methods...





# Bayesian Model Comparison -----------------------------------------------


# Our goal is to calculate a BF for each term. However, BF are computed per
# MODEL, not per term. For examples:


# (For within/mixed subject models, we need to:)
BF_alcohol_theta <- anovaBF(
  # 1) add the subject ID as a predictor
  ersp ~ Correctness * Alcohol + Subject,
  # 2) specify it as a random factor
  whichRandom = "Subject",
  # method = "laplace", # for large sample sizes
  data = Alcohol_data
)
BF_alcohol_theta
# see ?anovaBF for how to set different priors

# We need to find a way to compare models in a way that provides information
# about specific terms.
# There are 2 ways to do this:

## 1. Compare any 2 models of choice:
BF_alcohol_theta[3] / BF_alcohol_theta[4] # What does this mean?
BF_alcohol_theta[4] / BF_alcohol_theta[3]


## 2. Use Bayes model averaging to get an "average" Bayes factor:
bayesfactor_inclusion(BF_alcohol_theta) # What do THESE mean?
bayesfactor_inclusion(BF_alcohol_theta, match_models = TRUE) # and THESE?
?bayesfactor_inclusion
# # If you have any priors (default: equal prior odds for all models)
# bayesfactor_inclusion(BF_alcohol_theta, prior_odds = )




# Type 3 Bayes factors ----------------------------------------------------

# The BFs above do not have a 1:1 correspondence with the classic statistical
# tests (with type-3 SS). This is for 2 reasons:
#   1. Classic (type-3 SS) tests essentially test each term by comparing the
#     full model to a model without that term.
#   2. For repeated-measures designs `anovaBF()` does not account for individual
#     differences in effects (the so called subject-by-effect interaction).
# Not everyone agrees this is a bad thing...
#
# But if YOU decide that you want BFs that truly correspond to the classic
# tests, you need to:
#   1. Use the Leave-out-one-term method.
#   2. Include all random effects in our model (and in `whichRandom`).
# (Note that these results cannot be reproduced with JASP!)
#
# You can learn more about this top of "which models should be compare to test
# effects" in Jeff Rouder's talk, here:
# https://www.youtube.com/watch?v=PzHcwS3xbZ8


# The formula must have the general form of:
dv ~ within1 * within2 * (between1 * between2 + Subject)
# And instead of `anovaBF()` we must use `generalTestBF()`.


# In our example:
BF_type3 <- generalTestBF(
  ersp ~ Correctness * (Alcohol + Subject),
  whichRandom = c("Subject","Correctness:Subject"),
  whichModels = "top",
  # method = "laplace", # for large sample sizes
  data = Alcohol_data
)
BF_type3
1/BF_type3[5]






# Contrasts and Estimates -------------------------------------------------


# If you want any contrasts, you can't use `emmeans`, but it is possible.
# See "Bayesian contrasts.R".






# ADVANCED STUFF ----------------------------------------------------------


# There is A LOT more to be learned about Bayesian testing / estimation.
# A good place to start:
#   - Look up `rstanarm`
#   - Read here https://easystats.github.io/bayestestR/ (I might be biased)
#
# Note also that there are frequentist ways of accepting the null, called
# "Equivalence Testing". See "equivalence testing.R" for how to do this in
# emmeans (duh).
