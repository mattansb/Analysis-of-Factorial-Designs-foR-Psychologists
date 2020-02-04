
#' For ANOVAs we need to prepare our data in two ways:
#' 1. If we have many observations fer subject / condition, we must aggregate
#'    the data to a single value per subject / condition. This can be done
#'    with, for example one of the following:
#'    - `aggregate()`
#'    - `dplyr`'s `summarise()`
#'    - `prepdat`'s `prep()`
#'    - ...
#' 2. The data must be in the long format.

# Wide vs long data -------------------------------------------------------

angle_noise <- read.csv('angle-noise_wide.csv')


# WIDE DATA has a row for each subject,
# between-subject variables have a column,
# but within-subject variables are spread across columns.
head(angle_noise)





# LONG DATA (also known as 'tidy data'), has one row per
# each OBSERVATION, and a colmn for each variable
# (including the subject ID!)
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

fit_between <- aov(rt ~ angle * noise,
                   data = long_angle_noise)
summary(fit_between)






fit_within <- aov(rt ~ angle * noise + Error(id / (angle * noise)),
                  data = long_angle_noise)
summary(fit_within)


# Fitting and testing ANOVAs correctly ------------------------------------

# >>>>>>>>>
# IMPORTANT
# <<<<<<<<<
# when fitting an anova we need to make sure to use:
#   1. effects factor coding ("centering" factors)
#   2. type 3 errors
# If we don't we can get very misleading results!
# (This is true of any anova-table style result, in LMM, GLM, GLMM, etc...)

# set effects factor coding by default for all
options(contrasts = c('contr.sum', 'contr.poly'))

fit_between2 <- aov(rt ~ angle * noise,
                    data = long_angle_noise)



# what type 3 errors do
car::Anova(fit_between, type = 3)
car::Anova(fit_between2, type = 3) # THIS IS THE CORRECT ONE

# or... we can use `afex`


# ANOVA made easy ---------------------------------------------------------

library(afex)

fit <- aov_ez(id = "id", dv = "rt",
              within = c("angle", "noise"),
              data = long_angle_noise)
fit

# note some defaults here...


# Interactions and simple effects -----------------------------------------

library(emmeans)
# This whole course will be focused on how to use emmeans - a pkg for follow-up
# analyses (simple effects, simple slopes, contrasts..).
# Although we focus here on linear ANOVAs, you can use emmeans with GLM,
# HLM, GLMM, Bayesian models, and much much more.

# We saw the interaction was sig... what now?
# Simple effects!

joint_tests(fit, by = "noise")
joint_tests(fit, by = "angle")



emmeans(fit,  ~ angle) # what is this?
emmeans(fit,  ~ noise)
emmeans(fit,  ~ angle + noise)


# Plot the data -----------------------------------------------------------

# simple plotting function
emmip(fit, noise ~ angle)




# add 95% confidence intervals
emmip(fit, noise ~ angle, CIs = TRUE)
emmip(fit,  ~ angle, CIs = TRUE)




# With afex
afex_plot(fit,  ~ angle,  ~ noise)
? afex_plot





library(ggplot2)
p1 <- emmeans(fit,  ~ noise + angle) %>%
  confint() %>%
  # basic plot
  ggplot(aes(angle, emmean, fill = noise, group = noise)) +
  geom_col(width = .8,
           position = position_dodge(.8),
           color = 'black') +
  geom_point(position = position_dodge(.8)) +
  geom_errorbar(aes(ymin = lower.CL, ymax = upper.CL),
                width = .1,
                position = position_dodge(.8))
p1

p1 +
  # make pretty
  labs(x = 'Angle', y = 'Mean RT', fill = 'Noise') +
  scale_fill_manual(values = c('gray', 'red3')) +
  scale_x_discrete(labels = c(0, 4, 8)) +
  coord_cartesian(ylim = c(400, 850)) +
  theme_bw() +
  theme(legend.position = 'bottom')
