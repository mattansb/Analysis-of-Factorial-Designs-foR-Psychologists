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

# For within/mixed subject models, we need to:
BF_alcohol_theta <- anovaBF(
  # 1) add the subject ID as a predictor
  ersp ~ Correctness * Alcohol + Subject,
  # 2) specify it as a random factor
  whichRandom = "Subject",
  data = Alcohol_data
)
BF_alcohol_theta




BF_alcohol_theta[3] / BF_alcohol_theta[4] # What does this mean?
bayesfactor_inclusion(BF_alcohol_theta) # What do THESE mean?
bayesfactor_inclusion(BF_alcohol_theta, match_models = TRUE) # and THESE?


# # If you have any priors (default: equal prior odds for all models)
# bayesfactor_inclusion(BF_alcohol_theta, prior_odds = )

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
