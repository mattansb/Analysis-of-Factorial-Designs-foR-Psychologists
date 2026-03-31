library(afex)
library(lmerTest)

library(effectsize)
library(bayestestR)

afex_options(
  es_aov = 'pes',
  correction_aov = 'GG'
)

# Load data ---------------------------------------------------------------

Alcohol_data <- readRDS("Alcohol_data.rds") |>
  # Looking only at the Frequency of interest
  subset(Frequency == '4to7Hz')

head(Alcohol_data)


# Regular ANOVA -----------------------------------------------------------

fit_alcohol_theta <- aov_ez(
  id = 'Subject',
  dv = 'ersp',
  within = 'Correctness',
  between = 'Alcohol',
  data = Alcohol_data
)
fit_alcohol_theta

afex_plot(fit_alcohol_theta, ~Alcohol, ~Correctness)
# Looks like no interaction. But we can't infer that based on a non-significant
# p-value alone!

# Method 1: equivalence testing --------------------------------------------

# We can use the effectsize package to obtain CIs for our effect sizes.
# Using these CIs we can reject and non-inferiority hypothesis; i.e., that our
# effect is significantly smaller than some small effect size.

# We will be using the TOST approach: Two One Sided Tests (or: a single two
# sided 90% CI):
eta_squared(fit_alcohol_theta, alternative = "two.sided", ci = 0.90)

# We can see that the upper bound for the interaction is 0.13, which is *not*
# small. Thus, we cannot reject the hypothesis that the effect is non-inferior =
# we cannot rule out the option that there is some non-null effect.

# Method 2: AIC/BIC comparisons -----------------------------------------------

# We can use the BIC (relative measure of fit) to see of removing the
# interaction from our model provides with an equally good but more parsimonious
# model.

# Unfortunately, we cannot use an ANOVA for this - we must switch to a
# regression (or in our case a mixed regression model).

m_full <- lmer(
  ersp ~ Correctness * Alcohol + (1 | Subject),
  REML = FALSE,
  data = Alcohol_data
)

m_no.interaction <- lmer(
  ersp ~ Correctness + Alcohol + (1 | Subject),
  REML = FALSE,
  data = Alcohol_data
)

AIC(m_full, m_no.interaction)
# AIC lower for the restricted model.

BIC(m_full, m_no.interaction)
# BIC lower for the restricted model. We can use the BIC approximation to get a
# Bayes Factor:
bayesfactor_models(m_no.interaction, denominator = m_full)

# It seems like that no-interaction model is about 50,000 times more supported
# by the data compared to the full model, giving strong support for a lack of an
# interaction!

# The down side to this method is that it can only be easily applied to the
# highest level effects (in out example, only to the 2-way interaction).

# Learn more about multi-level models here:
# https://github.com/mattansb/Hierarchical-Linear-Models-foR-Psychologists

# Method 3. GO FULL BAYES ---------------------------------------------------

# There is A LOT more to be learned about Bayesian testing / estimation.
# A good place to start:
#   - Look up `brms`
#   - Read here https://easystats.github.io/bayestestR/ (I might be biased)
