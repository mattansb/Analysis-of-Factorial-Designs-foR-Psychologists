library(patchwork)

library(afex)

library(emmeans) # TODO: add {marginaleffects} examples

emm_options(lmer.df = "satterthwaite")


# This lesson is a short demonstration of how to fit a linear mixed model (LMM),
# while showing that under certain circumstances, the results are very similar
# to a regular ANOVA. In fact, just as an ANOVA can be thought of as a special
# case of a linear model, an rmANOVA can be thought of as a special case of a
# linear mixed model.
#
# For a more in-depth introduction to LMMs, see this full course:
# https://github.com/mattansb/Hierarchical-Linear-Models-foR-Psychologists

# Regular ANOVA -----------------------------------------------------------

# Let's first first fit a regular ANOVA to compare to:

data(obk.long, package = "afex")
obk.long$phase <- factor(obk.long$phase, levels = c("pre", "post", "fup"))

str(obk.long)

fit_aov <- aov_ez(
  id = "id",
  dv = "value",
  within = c("phase", "hour"),
  between = c("gender", "treatment"),
  data = obk.long
)


# Fit an LMM -----------------------------------------------------------------

# Now let's fit a linear mixed model to the same data.
# The steps basic steps for fitting a linear mixed model are as follows:
#
# The steps for fitting a model:
# I.   Identify desired fixed-effects structure.
# II.  Identify random factors and the level each variable varies at.
# III. Identify (maximal) random-effects structure.

# Here, our random factor is "id" - se we have two levels:
# 2. id - with treatment and gender varying between ids,
# 1. measurement - phase and hour varying within id.
#
# Thus, we have the following formula to specify the fixed effects and the
# (maximal) random effects structure:
value ~ treatment * gender * phase * hour + (phase * hour | id)

## Fit the model with all that in mind:
?afex::mixed
# This function is a wrapper around lmerTest::lmer, which can also be used
# directly. For now, we will use `mixed()`, as it has some nice features for
# calculating p-values and presenting ANOVA tables.

fit_lmm <- mixed(
  value ~ treatment * gender * phase * hour + (phase * hour | id),
  data = obk.long,
  method = "S" # p-value method
)

# Why do we get an error? We do not have enough data points to also estimate the
# correlation between the random effects.
#
# So we must ask `mixed()` not to estimate these, by
# 1. Adding || instead of | in the random effects term
# 2. Setting `expand_re = TRUE`

fit_lmm <- mixed(
  value ~ treatment * gender * phase * hour + (phase * hour || id),
  data = obk.long,
  method = "S", # p-value method
  expand_re = TRUE
)

# Compare ANOVA and LMM ---------------------------------------------------

fit_aov
fit_lmm
# Note that F values, and sigs are very similar!

p1 <- afex_plot(fit_aov, ~treatment, ~gender)
p2 <- afex_plot(fit_lmm, ~treatment, ~gender)

p1 + p2 + plot_layout(guides = "collect")
# Virtually identical estimates and confidence intervals!

# Follow-up analyses ------------------------------------------------------

# Same as with afex!

# note we pull out the full model from the object
joint_tests(fit_lmm$full_model, by = "gender")

em_treat <- emmeans(fit_lmm$full_model, ~treatment)
em_treat

contrast(em_treat, method = "pairwise")

# Etc....

# GLMMS -----------------------------------------------------------------

# http://singmann.github.io/afex/doc/afex_analysing_accuracy_data.html
# It goes into further details and is worth a read.

#
#

# In psychology, some of the most common outcomes are categorical by nature. One
# such measure is accuracy - when measured on a single trial, it can only have
# two values: success or failure. These are usually coded as a 1 or a 0 (but
# they could just as easily be coded as -0.9 and +34).
#
# Classically, these 1's and 0's are averaged across trials for each subject and
# condition, to get a mean accuracy, which would then be analyzed with an ANOVA.
# However... ANOVA is a type of liner model. But are accuracies really linear?
# It can be argued they are not!
# For example: is a change from 50% to 51% the same as a change from 98% to 99%?
#
# Indeed, it has been argued that rmANOVA is not adequate for analyzing accuracy
# data:
# http://doi.org/10.1016/j.jml.2007.11.007
# https://doi.org/10.1890/10-0340.1

# We might remember that we learned at some point that binary variables have a
# binomial distribution. Perhaps then, what we need is some type of logistic
# regression? A "repeated measures" logistic regression? We can do just that
# with generalized linear mixed models (GLMMs)!

# mixed() can also fit GLMMs - you can read more about it here:
vignette("afex_analysing_accuracy_data")
