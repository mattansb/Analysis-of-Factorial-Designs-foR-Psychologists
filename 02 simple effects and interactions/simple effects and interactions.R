library(tidyverse)
library(afex)
library(emmeans)

# lets look at the coffee_plot.png and get a feel for the data.
# What effects (and interactions) does it look like we have here?

coffee_data <- read.csv('coffee.csv')
coffee_data <- coffee_data %>%
  mutate(time = factor(time,levels = c('morning','noon','afternoon')))

# 3 way interaction -------------------------------------------------------

afex_options(es_aov = 'pes')
# this way we dont need to set it each time in out call to aov_ez
coffee_fit <- aov_ez('ID','alertness',coffee_data,
                     within = c('time','coffee'), between = 'sex')
coffee_fit

# Correcting for sphericity -----------------------------------------------

# As discussed in Designing Experiments and Analyzing Data (pp. 627; course
# book), one of the assumptions of within-subject ANOVA. There are several
# solutions that do not require this assumption:
# 1. For the ANOVA model, the Greenhouse-Geisser (GG) correction
#    (pp. 630; given by defult by afex).
# 2. For follow-up analysis, a multivariate solution (pp. 728;
#    not given by defult by afex).

afex_options(correction_aov = 'GG', # or 'none' for SPSS-equvilant results
             emmeans_model  = 'multivariate') # or 'univariate'

coffee_fit <- aov_ez('ID','alertness',coffee_data,
                     within = c('time','coffee'), between = 'sex')
coffee_fit

# Simple effects / interactions -------------------------------------------

joint_tests(coffee_fit, by = 'sex') # simple effects / interactions

joint_tests(coffee_fit, by = c('sex','time')) # simple-simple effects

# Contrasts ---------------------------------------------------------------

emmip(coffee_fit,coffee~time, CIs = TRUE)

em_coffee_time <- emmeans(coffee_fit,~coffee+time)
em_coffee_time

# simple effects
contrast(em_coffee_time,'pairwise', by = 'time')

# interactions-contrasts
contrast(em_coffee_time,interaction = c('pairwise','pairwise'))

# Making custom contrasts

my_time.emmc <- function(x){
  morning <- c(1,0,0)
  noon <- c(0,1,0)
  afternoon <- c(0,0,1)

  morning <- x=='morning'
  noon <- x=='noon'
  afternoon <- x=='afternoon'

  data.frame(morning    = (noon + afternoon)/2 - morning,
             after_noon = noon - afternoon)

  data.frame(morning    = c(-2,1,1)/2, # why divide by 2?
             after_noon = c(0,-1,1))

  data.frame(morning    = c(-1,.5,.5)/2, # why divide by 2?
             after_noon = c(0,-1,1))
}

contrast(em_coffee_time,interaction = c('pairwise','my_time'))
# What question did we answer here?

# DO IT YOURSELF ----------------------------------------------------------

library(AMCP)
data(C8E15)

head(C8E15)
# The data:
# Mothers (Parent==1) of four girls (Child==1) and of four boys (Child==2)
# at each of three ages (7, 10, and 13 months) were observed and recorded
# during toy-play interactions with their infants. An equal number of
# fathers (Parent==2) from different families were also observed. The
# dependent variable to be considered here was the proportion of time
# parents encouraged pretend play in their children.

# 1. conduct a 3-way anova
# 2. Plot the 3-way interaction plot.
# 3. Conduct follow-up analysis on a significant 2-way interaction.
#    Make some (any) custom contrast function. Explain your results.


# HM ----------------------------------------------------------------------

# Confirm w/ contrasts there is no 3-way interaction in the coffee data.
