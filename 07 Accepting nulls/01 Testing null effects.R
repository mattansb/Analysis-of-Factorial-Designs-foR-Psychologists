
library(afex)
library(effectsize)
library(lme4)
library(bayestestR)

# Load data ---------------------------------------------------------------


Alcohol_data <- readRDS("Alcohol_data.rds") |>
  # Looking only at the Frequency of interest
  subset(Frequency == '4to7Hz')

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










# Method 2: BIC comparisons -----------------------------------------------

# We can use the BIC (relative measure of fit) to see of removing the
# interaction from our model provides with an equally good but more parsimonious
# model.

# Unfortunately, we cannot use an ANOVA for this - we must switch to a
# regression (or in our case a mixed regression model).

m_full <- lmer(ersp ~ Correctness * Alcohol + (1 | Subject),
               REML = FALSE,
               data = Alcohol_data)

m_no.interaction <- lmer(ersp ~ Correctness + Alcohol + (1 | Subject),
                         REML = FALSE,
                         data = Alcohol_data)


bayesfactor_models(m_no.interaction, denominator = m_full)

# It seems like that no-interaction model is over 3000 times more supported by
# the data compared to the full model, giving strong support for a lack of an
# interaction!



# The down side to this method is that it can only be easily applied to the
# highest level effects (in out example, only to the 2-way interaction).



# Method 3. GO FULL BAYES ---------------------------------------------------


# There is A LOT more to be learned about Bayesian testing / estimation.
# A good place to start:
#   - Look up `brms`
#   - Read here https://easystats.github.io/bayestestR/ (I might be biased)
