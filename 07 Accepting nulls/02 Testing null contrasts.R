
library(afex)
library(emmeans)

# For null contrasts we will use equivalence testing - test if an observed
# effect is significantly smaller then some small effect - an effect so small we
# would consider it "not interesting".
#
# See some of Daniel Lakens's work:
# https://doi.org/10.1177/2515245918770963



# Load data ---------------------------------------------------------------

Alcohol_data <- readRDS("Alcohol_data.rds") |>
  # Looking only at the Frequency of interest
  dplyr::filter(Frequency == '4to7Hz')
head(Alcohol_data)




# Fit ANOVA ---------------------------------------------------------------

afex_options(es_aov         = 'pes',
             correction_aov = 'GG',
             emmeans_model  = 'univariate')

fit_alcohol_theta <- aov_ez('Subject','ersp',Alcohol_data,
                            within = c('Correctness'),
                            between = c('Alcohol'))
fit_alcohol_theta

afex_plot(fit_alcohol_theta,  ~ Alcohol,  ~ Correctness)
# Looks like no interaction. But we can't infer that based on
# a lack of significance.




# Equivalence testing for contrasts ---------------------------------------


# Q: Is the effect for {L1} vs {L5} differ between {Control + ND} vs {PFAS vs
# FAS}?

# Let's define those contrasts:
contr.corr <- data.frame(L_effect = c(0,-1,1))
contr.alc <- data.frame("P/FAS effect" = c(1,1,-1,-1)/2)




# Get conditional means:
em_int <- emmeans(fit_alcohol_theta, ~ Correctness + Alcohol)


# Conduct interaction-contrast analysis
c_int <- contrast(em_int, interaction = list(Alcohol = contr.alc,
                                             Correctness = contr.corr))
c_int
# From there results we can see that in our sample, {PFAS vs FAS} show a larger
# {L1} vs {L5} effect compared to {Control + ND}. But these results are not
# significantly different then 0. But are they significantly different from some
# SESOI?





## 1. Define your SESOI (smallest effect size of interest)
# Many ways to do this... Here I'll use a 1/10 of the dependent variables
# standard deviation:
(SESOI <- sd(Alcohol_data$ersp)/10)
# Is this a good benchmark? Maybe...
# I encorage you to this what a tiny difference would be, and not use sd/10.






## 2. Test
# Use emmeans::test to test the contrasts we've built. the `delta` argument
# tells `test()` that we want an equivalence test compared to this value.
test(c_int, delta = SESOI)
# Looks like even though our the difference is not significantly larger than 0,
# it is also not significantly smaller than our SESOI.
#
# Note that this was a two-tailed test. See "side" argument:
?test.emmGrid




# Using standardized differences ------------------------------------------

# TODO: explain these choices:
sigma <- sqrt(fit_alcohol_theta$anova_table[3, "MSE"])
edf <- fit_alcohol_theta$anova_table[3, "den Df"]

c_intz <- eff_size(c_int, method = "identity",
                   sigma = sigma,
                   edf = edf)
test(c_intz, delta = 0.1)
