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
# Looks like no interaction. But we can't infer that based on
# frequentist methods...




# Bayesian ----------------------------------------------------------------

# Our goal is to calculate a BF for each term. However, BF are computed per
# MODEL, not per term. For examples:


# (For within/mixed subject models, we need to:)
BF_alcohol_theta <- anovaBF(
  # 1) add the subject ID as a predictor
  ersp ~ Correctness * Alcohol + Subject,
  # 2) specify it as a random factor
  whichRandom = "Subject",
  data = Alcohol_data
)
BF_alcohol_theta

# We need to find a way to compare models in a way that provied information
# about specific terms.
# There are 2 ways to do this:

## 1. Compare any 2 models of choice:
BF_alcohol_theta[3] / BF_alcohol_theta[4] # What does this mean?



## 2. Use Bayes model averaging to get an "average" Bayes factor:
bayesfactor_inclusion(BF_alcohol_theta) # What do THESE mean?
bayesfactor_inclusion(BF_alcohol_theta, match_models = TRUE) # and THESE?

# # If you have any priors (default: equal prior odds for all models)
# bayesfactor_inclusion(BF_alcohol_theta, prior_odds = )



## 3. Leave-out-one-term
BF_alcohol_theta_LOOT <- anovaBF(
  # 1) add the subject ID as a predictor
  ersp ~ Correctness * Alcohol + Subject,
  # 2) specify it as a random factor
  whichRandom = "Subject",
  whichModels = "top",
  data = Alcohol_data
)
BF_alcohol_theta_LOOT
1/BF_alcohol_theta_LOOT[2]






# Unfortunetly, the defaults in `BayesFactor` for repeated-measures can often
# produce results that are no in-line of close to those obained with classic
# ANOVA analysis.
# The bottom line: where classic ANOVAs account for indevidual differences in
# effects (the so called subject-by-effect interaction), `anovaBF()` does not.
# To get BFs that truly corresponde to the classic tests, we need to:
#   1. Include the random effects in our model.
#   2. Use the Leave-out-one-term method.
# You can learn more about this in Jeff Rouder's talk, here:
# https://www.youtube.com/watch?v=PzHcwS3xbZ8
#
# The formula will have the general form of:
dv ~ within1 * within2 * (between1 * between2 + Subject)
# And instead of `anovaBF()` we must use `generalTestBF()`.


# In our example:
BF_type3 <- generalTestBF(
  ersp ~ Correctness * (Alcohol + Subject),
  whichRandom = "Subject",
  whichModels = "top",
  data = Alcohol_data
)
BF_type3
1/BF_type3[5]









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
