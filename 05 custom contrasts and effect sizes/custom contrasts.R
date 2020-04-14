library(afex)
library(emmeans)

afex_options(
  es_aov = 'pes',
  correction_aov = 'GG',
  emmeans_model = 'multivariate'
)



# Load Data ---------------------------------------------------------------

# Load data (is RDS file - these are R files the contain objects, in our
# case, a tidy data-frame)
Alcohol_data <- readRDS("Alcohol_data.rds")
head(Alcohol_data)




# Fit ANOVA model ---------------------------------------------------------

ersp_anova <- aov_ez('Subject','ersp',Alcohol_data,
                     within = c('Frequency','Correctness'),
                     between = c('Alcohol'))
ersp_anova

# We have an a-prior hypothesis: There will be an effect for correctness
# such that correct < both levels of incorrect, and that this difference
# will largest in 4-7Hz.




# Quiz --------------------------------------------------------------------

# If we hypothesize that the effect of Frequency is linear, a significant
# linear polynomial contrast would confirm our hypothesis.
# TRUE /  FALSE?

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
(contr.Frequency <- data.frame(
  ThetaVsOthers = c(1,-3,1,1)/3, # why did we divide by 3?
  ThetaVsOthers_alt = c(1,-3,1,1) # we'll see...
))


contrast(em_freqCorr, method = contr.Frequency, by = "Correctness")
# It seems that the only difference between the two contrasts is in the
# estimate (and it's SE) - the scond one is inflated! It is 3 times bigger!
# For the estimate to be meaningfull, we need to have each "side" sum to 1.


(contr.Correctness <- data.frame(
  CorrVsIncor = c(-2,1,1)/2, # why did we divide by 3?
  L1vsL5      = c(0,-1,1)
))

contrast(em_freqCorr, method = contr.Correctness, by = "Frequency")




# We can use these in a interaction contrast as well:
contrast(em_freqCorr, interaction = list(
  Frequency = contr.Frequency,
  Correctness = contr.Correctness
))

# we can mix with standard methods:
contrast(em_freqCorr, interaction = list(
  Frequency = "poly",
  Correctness = contr.Correctness
))

