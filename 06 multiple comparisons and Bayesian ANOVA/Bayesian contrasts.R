library(dplyr)
library(BayesFactor)
library(bayestestR)

# Load data ---------------------------------------------------------------

Alcohol_data <- readRDS("Alcohol_data.rds") %>%
  filter(Frequency == '4to7Hz') # Looking only at the Frequency of interest
head(Alcohol_data)




# Bayesian ANOVA ----------------------------------------------------------

# For within/mixed subject models, we need to:
BF_alcohol_theta <- anovaBF(
  # 1) add the subject ID as a predictor
  ersp ~ Correctness * Alcohol + Subject,
  # 2) specify it as a random factor
  whichRandom = "Subject",
  data = Alcohol_data
)

BF_alcohol_theta


# Contrasts ---------------------------------------------------------------

# We can't really compute bayes factors (we can, but with other packages), but
# we can get CI (credible intervals).
# To do this we need to
# 1. extract posterior samples (easy!)
# 2. compute the contrasts (hard!)
# 3. compute the CI (easy!)

# Let's compare the difference between {L1} vs {L5} between {Control + ND} vs
# {PFAS vs FAS}.



# Method 1 - choose your model --------------------------------------------

## 1. extract posterior samples
#If we want the full model (index = 4), we can:
full_mod_posterior <- posterior(BF_alcohol_theta, index = 4,
                                iterations = 4000)
full_mod_posterior <- data.frame(full_mod_posterior)
head(full_mod_posterior)
# a mess - we have the random effect here too, and a bunch of other stuff (such
# as mu, sig2, g...).



## 2. compute the contrasts
# This is hard, because we basically have to do this manually.
contrasts_posteriors <- full_mod_posterior %>%
  mutate(
    # Conditional means
    Control_L1 = Alcohol.Control + Correctness.L1 + Alcohol.Correctness.Control...L1,
    Control_L5 = Alcohol.Control + Correctness.L5 + Alcohol.Correctness.Control...L5,
    ND_L1 = Alcohol.Non.Dysmorphic..ND. + Correctness.L1 + Alcohol.Correctness.Non.Dysmorphic..ND....L1,
    ND_L5 = Alcohol.Non.Dysmorphic..ND. + Correctness.L5 + Alcohol.Correctness.Non.Dysmorphic..ND....L5,
    PFAS_L1 = Alcohol.PFAS + Correctness.L1 + Alcohol.Correctness.PFAS...L1,
    PFAS_L5 = Alcohol.PFAS + Correctness.L5 + Alcohol.Correctness.PFAS...L5,
    FAS_L1 = Alcohol.FAS + Correctness.L1 + Alcohol.Correctness.FAS...L1,
    FAS_L5 = Alcohol.FAS + Correctness.L5 + Alcohol.Correctness.FAS...L5,
    # L5 - L1 effect by group
    Control_L5_L1 = Control_L5 - Control_L1,
    ND_L5_L1 = ND_L5 - ND_L1,
    PFAS_L5_L1 = PFAS_L5 - PFAS_L1,
    FAS_L5_L1 = FAS_L5 - FAS_L1,
    # Group diffs:
    Contrast = (Control_L5_L1 + ND_L5_L1) / 2 - (PFAS_L5_L1 + FAS_L5_L1) / 2
  )



# 3. compute the CI
describe_posterior(contrasts_posteriors$Contrast, test = NULL)
# The estimate is d = -2.3 95%CI [-15, 10].
# We can think of this as meaning that when assuming the null is wrong (that
# there IS an interaction), the most plassible size of the effect is -2.3, but
# because the HDI (a type of CI) includes 0, then an effect of 0 is also
# plausible...
(HDI_full <- plot(hdi(contrasts_posteriors$Contrast)))






# Method 2 - model averageing (across models) -----------------------------

# But why are we assuming that the full model is the correct one? There ARE
# other models - some are more supported by the data than the full model!!
# The solution - look at ALL THE MODELS!
# (This is similar to how the Inclusion Bayes factor looks at all models)
#
# Read more:
# https://psyarxiv.com/h6pr8/download?format=pdf
# https://easystats.github.io/bayestestR/articles/bayes_factors.html#bayesian-model-averaging-1




# The only difference is in step 1 - in stead of sampling from one model, we
# sample from all models according to their posterior probability. For that, we
# will use `weighted_posteriors`.
?weighted_posteriors


## 1. extract posterior samples
model_ave_posterior <- weighted_posteriors(BF_alcohol_theta,
                                           iterations = 4000)

# # If you have any priors (default: equal prior odds for all models)
# model_ave_posterior <- weighted_posteriors(BF_alcohol_theta,
#                                            prior_odds = ,
#                                            iterations = 4000)

head(model_ave_posterior)
# Still a mess - we have the random effect here too, and a bunch of other stuff
# (such as mu, sig2, g...).



## 2. compute the contrasts
# Literally the same as before...
contrasts_posteriors2 <- model_ave_posterior %>%
  mutate(
    # Conditional means
    Control_L1 = Alcohol.Control + Correctness.L1 + Alcohol.Correctness.Control...L1,
    Control_L5 = Alcohol.Control + Correctness.L5 + Alcohol.Correctness.Control...L5,
    ND_L1 = Alcohol.Non.Dysmorphic..ND. + Correctness.L1 + Alcohol.Correctness.Non.Dysmorphic..ND....L1,
    ND_L5 = Alcohol.Non.Dysmorphic..ND. + Correctness.L5 + Alcohol.Correctness.Non.Dysmorphic..ND....L5,
    PFAS_L1 = Alcohol.PFAS + Correctness.L1 + Alcohol.Correctness.PFAS...L1,
    PFAS_L5 = Alcohol.PFAS + Correctness.L5 + Alcohol.Correctness.PFAS...L5,
    FAS_L1 = Alcohol.FAS + Correctness.L1 + Alcohol.Correctness.FAS...L1,
    FAS_L5 = Alcohol.FAS + Correctness.L5 + Alcohol.Correctness.FAS...L5,
    # L5 - L1 effect by group
    Control_L5_L1 = Control_L5 - Control_L1,
    ND_L5_L1 = ND_L5 - ND_L1,
    PFAS_L5_L1 = PFAS_L5 - PFAS_L1,
    FAS_L5_L1 = FAS_L5 - FAS_L1,
    # Group diffs:
    Contrast = (Control_L5_L1 + ND_L5_L1) / 2 - (PFAS_L5_L1 + FAS_L5_L1) / 2
  )



# 3. compute the CI (easy!)
describe_posterior(contrasts_posteriors2$Contrast, test = NULL)
# The estimate is d = 0 95%CI [-8, 0.9].
# We can think of this as meaning that when concidering all the models, the most
# plassible size of the effect is exactly 0, but small differences
# included in the HDI are also plausible...
(HDI_ave <- plot(hdi(contrasts_posteriors2$Contrast)))


# Compare
library(patchwork)
HDI_full + HDI_ave +
  plot_layout(guides = "collect") &
  ggplot2::coord_cartesian(xlim = c(-30,30))



# Concluding words --------------------------------------------------------

# This is all quite difficult and complicated stuff - feel free to contact me
# with any questions you may have with your own analysis.
#
# Also note that it is possible to compute Bayes factors for contrasts - but not
# quite with the BayesFactor package. See:
# https://easystats.github.io/bayestestR/articles/bayes_factors.html#testing-models-parameters-with-bayes-factors

