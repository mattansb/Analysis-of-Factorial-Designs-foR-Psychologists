library(afex)
library(patchwork)

# In this lesson we will learn to fit LMMs, and compare them to "regular"
# ANOVAs.
#
# The steps for fitting a model:
# 1. Identify desired fixed-effects structure.
# 2. Identify random factors.
# 3. Identify (maximal) random-effects structure.
# 4. Choose method for calculating p-values and fit maximal model.

#
# These are used to specify the model-formula, which has the following
# structure:
# DV ~ fixed_effects + (nested_random_effects | random_factor)


# Regular ANOVA -----------------------------------------------------------

# Let's first first fit a regular anova to compare to:

data(obk.long, package = "afex")
obk.long$phase <- factor(obk.long$phase, levels = c("pre", "post", "fup"))

str(obk.long)

fit_aov <- aov_ez("id", "value", obk.long,
                  within = c("phase", "hour"),
                  between = c("gender", "treatment"))


# Fit LMM -----------------------------------------------------------------

## The steps:
# 1. Identify desired fixed-effects structure
#   The effects are treatment, gender, phase, hour, and their interactions.
#
# 2. Identify random factors
#   The random factor is "id".
#
# 3. Identify (maximal) random-effects structure
#   phase, hour and their interaction are nested in id, so these will also get
#   random effects.

value ~ treatment * gender * phase * hour + (phase * hour | id)


# 4. Choose method for calculating p-values and fit maximal model
#   We will use the Satterthwaite approximation






## Fit the model with all that in mind:
fit_lmm <- mixed(value ~ treatment * gender * phase * hour + (phase * hour | id),
                 data = obk.long,
                 method = "S") # p-value method

# Why do we get an error? We do not have enough data points to also estimate the
# correlation between the random effects.
#
# So we must ask `mixed()` not to estimate these, by
# 1. Adding || instead of | in the random effects term
# 2. Setting `expand_re = TRUE`

fit_lmm <- mixed(value ~ treatment * gender * phase * hour + (phase * hour || id),
                 data = obk.long,
                 method = "S", # p-value method
                 expand_re = TRUE)
# Note that LMMs take longer to fit.





# Compare ANOVA and LMM ---------------------------------------------------

fit_aov
fit_lmm

# Note that F values, and sigs are very similar!

p1 <- afex_plot(fit_aov, ~ treatment, ~ gender)
p2 <- afex_plot(fit_lmm, ~ treatment, ~ gender)

p1 + p2 + plot_layout(guides = "collect")




# Follow-up analyses ------------------------------------------------------

# Same as with afex!

library(emmeans)

emm_options(lmer.df = "satterthwaite")

# note we pull out the full model from the object
joint_tests(fit_lmm$full_model, by = "gender")

em_treat <- emmeans(fit_lmm$full_model, ~ treatment)
em_treat

contrast(em_treat, method = "pairwise")

# Etc....


