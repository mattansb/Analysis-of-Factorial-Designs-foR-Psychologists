library(dplyr)
library(afex)
library(emmeans)


# The logic behind equivalence testing is to test if an observed effect is
# significantly smaller then some small effect - an effect so small we
# would consider it "not interesting".
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





# Equivalence testing -----------------------------------------------------

# Q: If the effect for {L1} vs {L5} differ between {Control + ND} vs
# {PFAS vs FAS}?

# Let's define those contrasts:
contr.corr <- data.frame(L_effect = c(0,-1,1))
contr.alc <- data.frame("P/FAS effect" = c(1,1,-1,-1)/2)




# Get conditional means:
em_int <- emmeans(fit_alcohol_theta, ~ Correctness + Alcohol)


# Conduct interaction-contrast analysis
c_int <- contrast(em_int, interaction = list(Alcohol = contr.alc,
                                             Correctness = contr.corr))
c_int
# From there results we can see that in our sample, {PFAS vs FAS} show a
# larger {L1} vs {L5} effect compared to {Control + ND}. But these results
# are not significantly different then 0. But are they significantly
# different from some SESOI?





## 1. Define your SESOI (smallest effect size of interest)
# Many ways to do this... Here I'll use the dependant variables standard
# deviation:
SESOI <- sd(Alcohol_data$ersp)
# Is this a good benchmark? No :/






## 2. Test
# Use emmeans::test to test the contrasts we've built.
# the `delta` argument tells `test()` that we want an equivalence test
# compared to this value.
test(c_int, delta = SESOI)
# Looks like we can say with some confidence (95% level) that the
# difference of differences is at least SMALLER in magnitude than 34.021.
#
# Note that this was a two-tailed test. See "side" argument:
?test






# (In this example we've conducted equivalence tests for an interaction,
# but these can be used for any analysis...)
