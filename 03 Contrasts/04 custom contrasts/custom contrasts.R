library(afex)
library(emmeans)

afex_options(
  es_aov = 'pes',
  correction_aov = 'GG',
  emmeans_model = 'multivariate'
)



# Load Data ---------------------------------------------------------------

# Load data (is RDS file - these are R files the contain objects, in our case, a
# tidy data-frame)
Alcohol_data <- readRDS("Alcohol_data.rds")
head(Alcohol_data)
# data from https://doi.org/10.1111/acer.14244



# Fit ANOVA model ---------------------------------------------------------

ersp_anova <- aov_ez('Subject','ersp',Alcohol_data,
                     within = c('Frequency','Correctness'),
                     between = c('Alcohol'))
ersp_anova

# We have an a-prior hypothesis: There will be an effect for correctness such
# that correct < both levels of incorrect, and that this difference will largest
# in 4-7Hz.




# Quiz --------------------------------------------------------------------

# If we hypothesize that the effect of Frequency is linear, a significant linear
# polynomial contrast would confirm our hypothesis. TRUE /  FALSE?

# https://persistentastonishment.blogspot.com/2019/02/increasing-testing-severity-in-multi.html



# Custom contrasts --------------------------------------------------------

emmip(ersp_anova, Correctness ~ Frequency, CIs = TRUE)
# Looks (visually) like our hypothesis was correct.
# But to test it we will need custom contrasts

## Estimate means
em_freqCorr <- emmeans(ersp_anova, ~ Frequency + Correctness)
em_freqCorr




# There are many ways to make custom contrasts. Here we will focus on
# data.frames:
contr.Frequency <- data.frame(
  ThetaVsOthers = c(1, -3, 1, 1) / 3, # why did we divide by 3?
  ThetaVsOthers_alt = c(1, -3, 1, 1)  # we'll see...
)
contr.Frequency


contrast(em_freqCorr, method = contr.Frequency, by = "Correctness")
contrast(em_freqCorr, method = contr.Frequency)
# It seems that the only difference between the two contrasts is in the estimate
# (and it's SE) - the second one is inflated! It is 3 times bigger!
# For the estimate to be meaningful, we need to have each "side" sum to 1.




contr.Correctness <- data.frame(
  CorrVsIncor = c(-2, 1, 1) / 2, # why did we divide by 2?
  L1vsL5 = c(0, -1, 1)
)
contr.Correctness

c_corr_by_freq <- contrast(em_freqCorr, method = contr.Correctness,
                           by = "Frequency")
c_corr_by_freq





# We can use these in a interaction contrast as well:
contrast(em_freqCorr,
         interaction = list(
           # NAME THE ELEMENTS IN THE LIST!
           Frequency = contr.Frequency,
           Correctness = contr.Correctness
         ))

# What does this mean? VIsually...
emmip(c_corr_by_freq, contrast ~ Frequency, CIs = T)





# we can mix with standard methods:
contrast(em_freqCorr,
         interaction = list(
           Frequency = "poly",
           Correctness = contr.Correctness
         ))



# Exercise ----------------------------------------------------------------

Alcohol_data_theta <- subset(Alcohol_data, Frequency == "4to7Hz")


fitTheta <- aov_ez('Subject','ersp',
                   within = c('Correctness'),
                   between = c('Alcohol'),
                   data = Alcohol_data_theta)
fitTheta

# (Complete the effect size lesson first [next])
#
# 1. Examine the simple effect for Correctness within each Alcohol group, and
#   compute the partial-eta^2 and the partial-omega^2 for the simple effects.
# 2. Examine the polynomial contrast for Alcohol Group within each level of
#   Correctness.
# 3. Compute partial-eta^2 for these contrasts.
# 4. Build the following weights scheme for Alcohol group:
#    4.1. Compare the Control group to {the 3 alcohol groups}.
#    4.2. Compare the ND to {PFAS and FAS}
#    4.3. Compare PFAS to FAS.
#    Are these contrasts orthogonal? Are they exhaustive?
# 5. Use this weights scheme any way you see fit.
# 6. Compute Cohen's d for these ^ contrasts.
