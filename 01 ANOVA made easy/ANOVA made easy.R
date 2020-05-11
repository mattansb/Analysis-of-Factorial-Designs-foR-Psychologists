
# For ANOVAs we need to prepare our data in two ways:
# 1. If we have many observations per subject / condition, we must aggregate
#   the data to a single value per subject / condition. This can be done with,
#   for example one of the following:
#    - `aggregate()`
#    - `dplyr`'s `summarise()`
#    - `prepdat`'s `prep()`
#    - ...
#    (Note: if you're using (G)LMMs you can, but don't have to aggregate.)
# 2. The data must be in the long format.

# Wide vs long data -------------------------------------------------------

angle_noise <- read.csv('angle-noise_wide.csv')


# WIDE DATA has:
# 1. A row for each subject,
# 2. Between-subject variables have a column
# 3. Repeated measures are stored across columns, and the within-subject are
#   stored in column names
head(angle_noise)





# LONG DATA (also known as 'tidy data'), has:
# 1. One row per each OBSERVATION,
# 2. A column for each variable (including the subject ID!)
# 3. Repeated measures are stored across rows.
library(tidyr)
long_angle_noise <- angle_noise %>%
  pivot_longer(
    cols = absent_angle0:present_angle8,
    names_to = c("noise", "angle"),
    names_sep = "_",
    values_to = 'rt',
  )

head(long_angle_noise)


# 2-Way anova -------------------------------------------------------------

# At first you might think that it's easy to run ANOVAs in R. After all,
# regressions are easy! And it sure looks like it...


## Between subjects
fit_between <- aov(rt ~ angle * noise,
                   data = long_angle_noise)
summary(fit_between)






## Within subjects
fit_within <- aov(rt ~ angle * noise + Error(id / (angle * noise)),
                  data = long_angle_noise)
summary(fit_within)

# But... As it turns out, AVOVAs are harder than you think. An both of the ANOVA
# tables from the models above aren't showing us the results we want. And that
# matters. A lot.

# So...
## --------------- ##
## DON'T DO THIS ^ ##
## --------------- ##




# Fitting and testing ANOVAs CORRECTLY ------------------------------------


# For proper ANOVA tables, we need two things:
# 1. effects coding for factors ("centering" factors)
# 2. type 3 errors.*
# However, by default, R uses treatment coding for factors, and Type 1 errors!
#
# If you have no idea what I'm even talking about, that's okay - you don't need
# to - just remember that without these, ANOVA tables will be very misleading -
# Especially when you have unbalanced data. (This is true of any anova-table, in
# GLM, LMM, GLMM, etc...)
#
# So how can we do this? Well... it's not that easy...
#
# Unless you use `afex`!




# * Read more about type 1, 2 & 3 errors:
# http://md.psych.bio.uni-goettingen.de/mv/unit/lm_cat/lm_cat_unbal_ss_explained.html)





# ANOVA made easy ---------------------------------------------------------

library(afex)

fit <- aov_ez(id = "id", dv = "rt",
              within = c("angle", "noise"),
              data = long_angle_noise)
fit

# note some defaults here...
# - correction of the degrees of freedom (set to Greenhouse-Geisser)
# - effect size (set to generalized eta squared)





# Interactions and simple effects -----------------------------------------

library(emmeans)
# This whole course will be focused on how to use `emmeans` - a pkg for
# follow-up analyses (simple effects, simple slopes, contrasts...). Although we
# focus here on linear ANOVAs, you can use `emmeans` with GLM, HLM, GLMM,
# Bayesian models, and much much more.


# We saw the interaction was sig... what now?
# Simple effects!
joint_tests(fit, by = "noise")
joint_tests(fit, by = "angle")


# We can also get the estimated means:
emmeans(fit, ~ angle) # what is this?
emmeans(fit, ~ noise)
emmeans(fit, ~ angle + noise)

# NOTE: these can be different from the raw means in the data - these are
# estimates! And that is OKAY!

# Plot the data -----------------------------------------------------------

# simple plotting function
emmip(fit, noise ~ angle)
# (Again, these plots show the estimated means!)



# add 95% confidence intervals
emmip(fit, noise ~ angle, CIs = TRUE)
emmip(fit, ~ angle, CIs = TRUE)




# With afex
afex_plot(fit,  ~ angle,  ~ noise)
?afex_plot





library(ggplot2)
ems <- emmeans(fit,  ~ noise + angle) %>%
  confint()

# basic plot
p1 <- ggplot(ems, aes(angle, emmean, fill = noise, group = noise)) +
  geom_col(position = position_dodge(.8),
           width = .8) +
  geom_point(position = position_dodge(.8)) +
  geom_errorbar(aes(ymin = lower.CL, ymax = upper.CL),
                width = .1,
                position = position_dodge(.8))
p1


# make pretty
p1 +
  ggbeeswarm::geom_beeswarm(
    data = long_angle_noise,
    aes(angle, rt, group = noise),
    dodge.width = .8,
    alpha = 0.4
  ) +
  labs(x = 'Angle', y = 'Mean RT', fill = 'Noise') +
  scale_fill_manual(values = c('grey', 'red3')) +
  scale_x_discrete(labels = c(0, 4, 8)) +
  coord_cartesian(ylim = c(300, 850)) +
  theme_bw() +
  theme(legend.position = 'bottom')




