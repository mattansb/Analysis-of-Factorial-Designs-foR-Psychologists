
library(afex)
library(emmeans)
library(effectsize)

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

# The effect sizes above use the effect's sums-of-squares (SSs). But these are
# not always readily available. In such cases we can use shortcuts, based on
# tests statistics.


## For simple effects
(jt_treatment <- joint_tests(treatment_aov, by = "treatment"))
F_to_eta2(jt_treatment$F.ratio, jt_treatment$df1, jt_treatment$df2)


# We can put it all together with `dplyr`:
joint_tests(treatment_aov, by = "treatment") |>
  mutate(F_to_eta2(F.ratio, df1, df2))


# Here too we can use
# F_to_epsilon2()
# F_to_omega2()
# etc...


# But note that these shortcuts only apply to the *partial* effect sizes.





# 3. For contrasts --------------------------------------------------------


### Eta and friends:
em_phase <- emmeans(treatment_aov, ~ phase)
c_phase <- contrast(em_phase, method = "pairwise")

c_phase
# Here we have the raw differences.
# But sometimes we want (why?) standardized differences.

# For that we need the standardizing factor - sigma (this is akin to the
# pooled-sd in Cohen's d), and it's df.
# We can get both from out anova table!

# Sigma is the sqrt(MSE) of the relevant effect:
sig <- sqrt(treatment_aov$anova_table["phase", "MSE"])
sig.df <- treatment_aov$anova_table["phase", "den Df"]

# We can then use the eff_size() function to convert our contrasts to
# standardized differences:
eff_size(c_phase, method = "identity",
         sigma = sig, edf = sig.df)



