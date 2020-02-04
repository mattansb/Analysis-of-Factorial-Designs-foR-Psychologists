library(afex)
library(emmeans)
library(effectsize) # for the effect size functions

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




# (Partial) Percent Variance Explained ------------------------------------

# These are S/N effect sizes.
# Let's look at the main effect for Alcohol:
F_to_eta2(2.89, 3, 44)
# compare to:
ersp_anova

# we can also get Partial Omega and Epsilon, which are more generalizable:
F_to_omega2(2.89, 3, 44)
F_to_epsilon2(2.89, 3, 44)


## For contrasts
em_alcohol <- emmeans(ersp_anova, ~ Alcohol)
c_alcohol <- contrast(em_alcohol, method = "pairwise")
c_alcohol <- summary(c_alcohol)
c_alcohol$pes <- t_to_eta2(c_alcohol$t.ratio, c_alcohol$df)
c_alcohol



## For simple effects
jt_alcohol <- joint_tests(ersp_anova, by = "Alcohol")
jt_alcohol$pes <- F_to_eta2(jt_alcohol$F.ratio, jt_alcohol$df1, jt_alcohol$df2)
jt_alcohol



# Cohen's d ---------------------------------------------------------------

## Between subjects effects:
em_alcohol <- emmeans(ersp_anova, ~ Alcohol)
c_alcohol <- contrast(em_alcohol, method = "pairwise")
c_alcohol <- summary(c_alcohol)
c_alcohol$d <- t_to_d(c_alcohol$t.ratio, c_alcohol$df)
c_alcohol


## Within subjects effects:
em_Correctness <- emmeans(ersp_anova, ~ Correctness)
c_Correctness <- contrast(em_Correctness, method = "pairwise")
c_Correctness <- summary(c_Correctness)
c_Correctness$d <- t_to_d(c_Correctness$t.ratio, c_Correctness$df, pooled = TRUE)
c_Correctness




# r2 alerting -------------------------------------------------------------

## try at home.


# Exercise ----------------------------------------------------------------

fitTheta <- aov_ez('Subject','ersp',
                   within = c('Correctness'),
                   between = c('Alcohol'),
                   data = dplyr::filter(Alcohol_data, Frequency=="4to7Hz"))
fitTheta

# 1. Examine the simple effect for Correctness within each Alcohol group,
#    and compute the partial-eta^2 for the simple effects.
# 2. Examin the polynomial contrast for Alcohol Group within each level
#    of Correctness.
# 3. Compute partial-eta^2 for these contrasts.
# 4. Estimate the following custom contrasts for Alcohol group:
#    4.1. Compare the Control group to the 3 alcohol groups.
#    4.2. Compare the ND to PFAS and FAS
#    4.3. Compare PFAS to FAS
# 5. Use this weights function any way you see fit.

