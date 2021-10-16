library(dplyr)
library(afex)
library(emmeans)

# let's look at the coffee_plot.png and get a feel for our data.
#
# What marginal (main) effects and interactions does it look like we have here?
# What conditional (simple) effects does it look like we have here?

coffee_data <- read.csv('coffee.csv') %>%
  mutate(time = factor(time,levels = c('morning','noon','afternoon')))
head(coffee_data)




# Correcting for sphericity -----------------------------------------------

# As discussed in Designing Experiments and Analyzing Data (pp. 627; course
# book), sphericity is one of the assumptions of within-subject ANOVA. There are
# several solutions that do not require this assumption:
# 1. For the ANOVA model, the Greenhouse-Geisser (GG) correction
#    (pp. 630; afex's default).
# 2. For follow-up analysis, a multivariate solution (pp. 728;
#    not afex's  default).

afex_options(
  correction_aov = 'GG', # or 'none' for SPSS/statistica equvilant results
  emmeans_model  = 'multivariate', # can also be 'univariate'
  es_aov         = 'pes' # for partial-eta-square in the anova table
)




coffee_fit <- aov_ez('ID','alertness',coffee_data,
                     within = c('time','coffee'),
                     between = 'sex')

coffee_fit
# what's up with the 3-way interaction??


afex_plot(coffee_fit, ~ time, ~ coffee, ~sex)



# Simple effects / interactions -------------------------------------------

# conditional (simple) effects / interactions
joint_tests(coffee_fit, by = 'sex') # conditional by "by"


joint_tests(coffee_fit, by = c('sex','time'))
# these effects are conditional by two variables, so they simple-simple effects.



# Estimating means (+plot) ------------------------------------------------
# For each of these, tell me what (margianl / conditional) effects or
# interactions can we see.

emmeans(coffee_fit, ~ sex)
emmip(coffee_fit, ~ sex, CIs = TRUE)

emmeans(coffee_fit, ~ time)
emmip(coffee_fit, ~ time, CIs = TRUE)

emmeans(coffee_fit, ~ coffee + time)
emmip(coffee_fit, coffee ~ time, CIs = TRUE)

emmeans(coffee_fit, ~ coffee + time + sex)
emmip(coffee_fit, coffee ~ time | sex, CIs = TRUE)




# Contrasts ---------------------------------------------------------------

# For contrasts we need:
# 1. The estimated means
# 2. The contrast method.


## For main effects:
em_time <- emmeans(coffee_fit, ~ time)
em_time
contrast(em_time, method = "pairwise")
contrast(em_time, method = "poly") # is this surprising?


?`contrast-methods` # for more out-of-the-box methods
# In a few lessons we will see how to define specific contrasts of interest.

# for confidence intervals for the estimated contrast:
c_time <- contrast(em_time, method = "pairwise")
summary(c_time, infer = TRUE)


## For simple effects use the `by = c()`
em_time_coffee <- emmeans(coffee_fit, ~ coffee + time)
em_time_coffee
contrast(em_time_coffee, method = "pairwise", by = "coffee")
contrast(em_time_coffee, method = "poly", by = "coffee") # surprising?


# See contrast weights
c_time_simple <- contrast(em_time_coffee, method = "poly", by = "coffee")
coef(c_time_simple)



# Exercise ----------------------------------------------------------------


library(AMCP)
data(C8E15)

head(C8E15)
# The data:
# Mothers (Parent==1) of four girls (Child==1) and of four boys (Child==2) at
# each of three ages (7, 10, and 13 months) were observed and recorded during
# toy-play interactions with their infants. An equal number of fathers
# (Parent==2) from different families were also observed. The dependent variable
# to be considered here was the proportion of time parents encouraged pretend
# play in their children.
#
# * Note that there are better ways to model proportions! We will talk about
#   these later in the course.


# 1. Conduct a 3-way anova
# 2. Plot the 3-way interaction plot.
# 3. Conduct follow-up analysis on a significant 2-way interaction.
#    Explain your results.
