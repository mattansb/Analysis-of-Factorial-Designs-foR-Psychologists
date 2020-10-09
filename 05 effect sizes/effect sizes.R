
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





# 1. Effect size for ANOVA table ------------------------------------------

# We can use the various functions from `effectsize`, which also return
# confidence intervals, such as the various Eta-squares:
eta_squared(treatment_aov)
eta_squared(treatment_aov, partial = FALSE)
eta_squared(treatment_aov, generalized = TRUE)

# But also the Omega and Epsilon Squared:
omega_squared(treatment_aov)
epsilon_squared(treatment_aov)
# Note that these CAN BE negative; even though this doesn't make any practical
# sense, it is recommended to report the negative value and not a 0.



# Read more about these here:
# https://easystats.github.io/effectsize/articles/anovaES.html




# 2. Effect size for simple effects ---------------------------------------

# The effect sizes above use the effect's sums-of-squares (SSs). But these are not always 
# readily available. In such cases we can use shortcuts, based on tests statistics.


## For simple effects
(jt_treatment <- joint_tests(treatment_aov, by = "treatment"))
F_to_eta2(jt_treatment$F.ratio, jt_treatment$df1, jt_treatment$df2)


# We can put it all together with `dplyr`:
joint_tests(treatment_aov, by = "treatment") %>%
  mutate(F_to_eta2(F.ratio, df1, df2))


# Here too we can use
# F_to_epsilon2()
# F_to_omega2()
# etc...





# 3. For contrasts --------------------------------------------------------


### Eta and friends:
em_phase <- emmeans(treatment_aov, ~ phase)
c_phase <- contrast(em_phase, method = "pairwise")
c_phase <- summary(c_phase)
t_to_eta2(c_phase$t.ratio, c_phase$df)

# We can put it all together with `dplyr`:
emmeans(treatment_aov, ~ phase) %>%
  contrast(method = "pairwise") %>%
  summary() %>%
  mutate(t_to_eta2(t.ratio, df))






### Cohen's d - Between subjects effects:
emmeans(treatment_aov, ~ treatment) %>%
  contrast(method = "pairwise") %>%
  summary() %>%
  mutate(t_to_d(t.ratio, df))
# note the CI are not adjusted for multiple comps, so might give different
# results compared to adjusted p-values.



### Cohen's d - Within subjects effects:
emmeans(treatment_aov, ~ phase) %>%
  contrast(method = "pairwise") %>%
  summary() %>%
  mutate(t_to_d(t.ratio, df, paired = TRUE))


### r2 alerting
# try at home...?


