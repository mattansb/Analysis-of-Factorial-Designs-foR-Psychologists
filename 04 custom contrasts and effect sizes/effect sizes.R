library(afex)
library(emmeans)
library(effectsize) # for the effect size functions
library(dplyr) # for `mutate()` (need version 1.0.0+)

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
# Seems identical! (+ we get CIs!)


# we can also get Partial Omega and Epsilon
# (Epsilon is akin to adjusted R^2):
F_to_omega2(2.89, 3, 44)
F_to_epsilon2(2.89, 3, 44)
# Note that these can be negative; even though this doesn't make any
# practical sense, it is recommended to report the negative number
# and not a 0.

# Also Cohen's f - which is ~Cohen's d for more than 2 means:
F_to_f(2.89, 3, 44)

# # We can also directly use the model object:
# eta_squared(ersp_anova)
# omega_squared(ersp_anova)
# epsilon_squared(ersp_anova)
# cohens_f(ersp_anova)





## For simple effects
jt_alcohol <- joint_tests(ersp_anova, by = "Alcohol")
F_to_eta2(jt_alcohol$F.ratio, jt_alcohol$df1, jt_alcohol$df2)


# We can put it all together with `dplyr`:
joint_tests(ersp_anova, by = "Alcohol") %>%
  mutate(F_to_eta2(F.ratio, df1, df2))










## For contrasts
em_alcohol <- emmeans(ersp_anova, ~ Alcohol)
c_alcohol <- contrast(em_alcohol, method = "pairwise")
c_alcohol <- summary(c_alcohol)
t_to_eta2(c_alcohol$t.ratio, c_alcohol$df)

# We can put it all together with `dplyr`:
emmeans(ersp_anova, ~ Alcohol) %>%
  contrast(method = "pairwise") %>%
  summary() %>%
  mutate(t_to_eta2(t.ratio, df))





# Cohen's d ---------------------------------------------------------------

## Between subjects effects:
emmeans(ersp_anova, ~ Alcohol) %>%
  contrast(method = "pairwise") %>%
  summary() %>%
  mutate(t_to_d(t.ratio, df))
# note the CI are not adjusted for multiple comps, so might give different
# results compared to adjusted p-values.





## Within subjects effects:
emmeans(ersp_anova, ~ Correctness) %>%
  contrast(method = "pairwise") %>%
  summary() %>%
  mutate(t_to_d(t.ratio, df, paired = TRUE))




# r2 alerting -------------------------------------------------------------

## try at home...?




# Exercise ----------------------------------------------------------------

Alcohol_data_theta <- Alcohol_data %>%
  filter(Frequency=="4to7Hz")

fitTheta <- aov_ez('Subject','ersp',
                   within = c('Correctness'),
                   between = c('Alcohol'),
                   data = Alcohol_data_theta)
fitTheta

# 1. Examine the simple effect for Correctness within each Alcohol group,
#    and compute the partial-eta^2 and the partial omega^2 for the simple
#    effects.
# 2. Examin the polynomial contrast for Alcohol Group within each level
#    of Correctness.
# 3. Compute partial-eta^2 for these contrasts.
# 4. Build the following weights scheme for Alcohol group:
#    4.1. Compare the Control group to {the 3 alcohol groups}.
#    4.2. Compare the ND to {PFAS and FAS}
#    4.3. Compare PFAS to FAS.
#    Are these contrasts orthogonal? Are they exhaustive?
# 5. Use this weights scheme any way you see fit.
# 6. Compute Cohen's d for these ^ contrasts.
