library(dplyr)
library(afex)
library(emmeans)


# The logic behind equivalence testing is to test if an observed effect is
# significantly smaller then some small effect - an effect so small we would
# consider it "not interesting".
#
# See some of Daniel Lakens's work:
# https://doi.org/10.1177/2515245918770963



# Load data ---------------------------------------------------------------

Alcohol_data <- readRDS("Alcohol_data.rds") %>%
  filter(Frequency == '4to7Hz') # Looking only at the Frequency of interest
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
# Many ways to do this... Here I'll use a 1/10 of the dependant variables
# standard deviation:
(SESOI <- sd(Alcohol_data$ersp)/10)
# Is this a good benchmark? Maybe...






## 2. Test
# Use emmeans::test to test the contrasts we've built. the `delta` argument
# tells `test()` that we want an equivalence test compared to this value.
test(c_int, delta = SESOI)
# Looks like even though our the difference is not significantly larger than 0,
# it is also not significantly smaller than our SESOI.
#
# Note that this was a two-tailed test. See "side" argument:
?test.emmGrid



# Equivalence testing for effect sizes ------------------------------------

# (Might need the development version of effectsize for this to work.)



# We can also use standerdized effect sizes.
library(effectsize)
library(see)

### Ex 1: Partial Eta Square

## 1. Define your SESOI
# We will consider an effect smaller than 0.15 to be small.
SESOI <- 0.15
# Is this a good benchmark? Maybe...


## 2. Test
equi_test <- fit_alcohol_theta %>%
  eta_squared() %>%
  equivalence_test(range = SESOI)
equi_test
plot(equi_test)
# Looks like our effect size (of 0.08) is significantly smaller than our SESOI!







### Ex 2: Cohen's d
# Same idea...

## 1. Define your SESOI
# Here we need to define a range - a ROPE (Region of Practical Equivalence).
# We will consider an effect smaller in magnitude than 0.2 to be small.
ROPE <- c(-0.2, 0.2)
# Is this a good benchmark? Maybe...



## 2. Test
c_int # take the values from the contrast:
# Note that 1-2*alpha CI levels are usually used for equivalence tests.
equi_test_c <- t_to_d(t = -0.565, df_error = 88, ci = 0.9) %>%
  equivalence_test(range = ROPE)
plot(equi_test_c)
# Undecided - same as above, the effect is both not significantly larger than 0,
# and also not significantly smaller (in magnitude) than the SESOI.



# -------------------------------------------------------------------------




# (In this example we've conducted equivalence tests for an interaction,
# but these can be used for any analysis...)
