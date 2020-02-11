library(afex)
library(emmeans)

afex_options(es_aov = 'pes',
             correction_aov = 'GG',
             emmeans_model = 'multivariate')



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


# Custom contrasts --------------------------------------------------------

emmip(ersp_anova, Correctness ~ Frequency, CIs = TRUE)
# Looks (visually) like our hypothesis was correct.
# But to test it we will need custom contrasts

## Estimate means
em_freqCorr <- emmeans(ersp_anova, ~Frequency + Correctness)
em_freqCorr

# There are many ways to make custom contrasts. Here we will focus on
# data.frames:
(contr.Frequency <- data.frame(ThetaVsOthers = c(1,-3,1,1)/3)) # why do we divide by 3?

(contr.Correctness <- data.frame(CorrVsIncor = c(-2,1,1)/2, # why do we divide by 2?
                                 L1vsL5      = c(0,-1,1)))



contrast(em_freqCorr, method = contr.Correctness, by = "Frequency")


contrast(em_freqCorr, interaction = list(
  Frequency = contr.Frequency,
  Correctness = contr.Correctness
))

# Plotting contrasts ------------------------------------------------------

library(ggplot2)

em_ <- emmeans(ersp_anova, ~ Correctness + Alcohol,
               at = list(Frequency = "X4to7Hz"))
# "at" allows to zoom into just some levels. You should rarely use it
em_

c_ <- contrast(em_, method = contr.Correctness, by = "Alcohol")
c_

emmip(c_, contrast ~ Alcohol, CIs = TRUE) +
  geom_hline(yintercept = 0)
