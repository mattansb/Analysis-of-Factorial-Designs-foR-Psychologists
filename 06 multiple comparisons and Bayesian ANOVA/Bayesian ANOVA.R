library(dplyr)
library(afex)
library(BayesFactor)
library(bayestestR)

# Load data ---------------------------------------------------------------

Alcohol_data <- readRDS("Alcohol_data.rds") %>%
  filter(Frequency == '4to7Hz') # Looking only at the Frequency of interest
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
BF_alcohol_theta <-
  anovaBF(ersp ~ Correctness * Alcohol + Subject, # 1) add the subject ID
          data = Alcohol_data,
          whichRandom = "Subject")                # 2) specify it as a random factor
BF_alcohol_theta

BF_alcohol_theta[3] / BF_alcohol_theta[4] # What does this mean?
bayesfactor_inclusion(BF_alcohol_theta) # What do THESE mean?
bayesfactor_inclusion(BF_alcohol_theta, match_models = TRUE) # What do THESE mean?

# ADVANCED STUFF ----------------------------------------------------------

# There is A LOT more to be learned about Bayesian testing / estimation.
# A good place to start:
#   - Look up `rstanarm`
#   - Read here https://easystats.github.io/bayestestR/ (I might be biased)
