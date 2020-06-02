library(dplyr)
library(afex)
library(emmeans)

# Back to our coffee data

coffee_data <- read.csv('coffee.csv') %>%
  mutate(time = factor(time,levels = c('morning','noon','afternoon')))
head(coffee_data)


# 3-way ANOVA -------------------------------------------------------------


# setting some options
afex_options(correction_aov = 'GG',
             emmeans_model  = 'multivariate',
             es_aov         = 'pes')



coffee_fit <- aov_ez('ID','alertness', coffee_data,
                     within = c('time','coffee'),
                     between = 'sex')


afex_plot(coffee_fit, ~ time, ~ coffee, ~sex)
# emmip(coffee_fit,  ~ coffee | time + sex, CIs = TRUE)
# emmip(coffee_fit,  ~ coffee + time | sex, CIs = TRUE)

coffee_fit
# Today we will try to see why there is no 3-way interaction...





# 2-way interaction -------------------------------------------------------

# we will be looking at the time-by-coffee interaction:
emmip(coffee_fit, coffee ~ time, CIs = TRUE)

## simple effects
# looking at the simple effect for time, conditional by the levels of coffee.
joint_tests(coffee_fit, by = "coffee")


## estimate means
em_time_coffee <- emmeans(coffee_fit, ~ time + coffee)
em_time_coffee





## Looking at simple effects
contrast(em_time_coffee, method = "consec", by = "coffee")



## interaction contrasts with `interaction = `
# (ALWAYS NAME THE LIST ELEMENTS!!)
c_coffee_time <- contrast(em_time_coffee,
                          interaction = list(coffee = "pairwise",
                                             time = "consec"))
c_coffee_time
# what can we infer here?



# We can again look at the weights:
coef(c_coffee_time)



# 3-way interaction -------------------------------------------------------


## simple interactions
joint_tests(coffee_fit, by = "time")

## simple-simple effects
joint_tests(coffee_fit, by = c("sex", "time"))


## estimate means
em_3way <- emmeans(coffee_fit, ~ time + coffee + sex)
em_3way

emmip(em_3way, coffee ~ time | sex, CIs = TRUE)
emmip(em_3way, coffee ~ sex | time, CIs = TRUE)


## Looking at the simple-simple effect effect for "coffee"
contrast(em_3way, method = "pairwise",
         by = c("sex", "time"))




## Looking at simple-interaction contrasts
contrast(em_3way,
         by = "time",
         interaction = list(coffee = "pairwise", sex = "pairwise"))
# what does this mean?
# how might this explain the no-3-way interaction?





# Plotting contrasts ------------------------------------------------------

# Sometime we don't care about the means per-se, and we want to visualize how
# some contrast is different as a function of some other factor. e.g., in stroop
# tasks we might want to show how the interference effect (on Y) differs by
# group.


# 1. Means (on Y) by time and coffee
emmip(coffee_fit, coffee ~ time, CIs = TRUE)



# 2. The effect of coffee (on Y) by time (on X)
emmeans(coffee_fit, ~ coffee + time) %>%
  contrast(method = "pairwise", by = "time") %>%
  emmip( ~ time, CIs = TRUE) +
  ggplot2::geom_hline(yintercept = 0)


# Removable interactions --------------------------------------------------

# Some interactions are removable - these are sometimes called ordinal
# interactions.
#
# See "pt3 - removable interactions.R" for how to deal with these.


# Exercise ----------------------------------------------------------------

# Explore of the other 2-way interactions.
# - Simple effects
# - Simple effect contrasts
# - Interaction contrasts
# - Plots
# Interpret your results along the way...


# HM ----------------------------------------------------------------------

# Confirm w/ contrasts there is no 3-way interaction in the coffee data.
