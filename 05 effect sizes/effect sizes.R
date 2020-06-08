library(afex)
library(emmeans)
library(effectsize) # for the effect size functions
library(dplyr) # for `mutate()` (need version > 1.0.0)

afex_options(es_aov = 'pes',
             correction_aov = 'GG',
             emmeans_model = 'multivariate')



# Load Data ---------------------------------------------------------------


data(obk.long)

?obk.long

head(obk.long)



# Fit ANOVA model ---------------------------------------------------------

# for this example we will test the effects for treatment * phase (time):
treatment_aov <- aov_ez("id", "value", obk.long, 
                        between = "treatment", 
                        within = "phase")
treatment_aov

afex_plot(treatment_aov, ~ phase, ~ treatment)




# (Partial) Percent Variance Explained ------------------------------------

# These are S/N effect sizes.
# Let's look at the main effect for treatment:
F_to_eta2(f = 2.91, df = 2, df_error = 13)
# compare to:
treatment_aov
# Seems identical! (+ we get CIs!)


# we can also get Partial Omega and Epsilon
# (Epsilon is akin to adjusted R^2):
F_to_omega2(2.91, 2, 13)
F_to_epsilon2(2.91, 2, 13)
# Note that these CAN BE negative; even though this doesn't make any practical
# sense, it is recommended to report the negative value and not a 0.


# Also Cohen's f - which is ~Cohen's d for more than 2 means:
F_to_f(2.91, 2, 13)

# # We can also directly use the model object:
# eta_squared(treatment_aov)
# omega_squared(treatment_aov)
# epsilon_squared(treatment_aov)
# cohens_f(treatment_aov)





## For simple effects
jt_treatment <- joint_tests(treatment_aov, by = "treatment")
F_to_eta2(jt_treatment$F.ratio, jt_treatment$df1, jt_treatment$df2)


# We can put it all together with `dplyr`:
joint_tests(treatment_aov, by = "treatment") %>%
  mutate(F_to_eta2(F.ratio, df1, df2))










## For contrasts
em_phase <- emmeans(treatment_aov, ~ phase)
c_phase <- contrast(em_phase, method = "pairwise")
c_phase <- summary(c_phase)
t_to_eta2(c_phase$t.ratio, c_phase$df)

# We can put it all together with `dplyr`:
emmeans(treatment_aov, ~ phase) %>%
  contrast(method = "pairwise") %>%
  summary() %>%
  mutate(t_to_eta2(t.ratio, df))





# Cohen's d ---------------------------------------------------------------

## Between subjects effects:
emmeans(treatment_aov, ~ treatment) %>%
  contrast(method = "pairwise") %>%
  summary() %>%
  mutate(t_to_d(t.ratio, df))
# note the CI are not adjusted for multiple comps, so might give different
# results compared to adjusted p-values.





## Within subjects effects:
emmeans(treatment_aov, ~ phase) %>%
  contrast(method = "pairwise") %>%
  summary() %>%
  mutate(t_to_d(t.ratio, df, paired = TRUE))




# r2 alerting -------------------------------------------------------------

## try at home...?


