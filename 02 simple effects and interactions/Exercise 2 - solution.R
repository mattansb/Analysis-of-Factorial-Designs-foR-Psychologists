library(tidyverse)
library(afex)
library(emmeans)
library(AMCP)

afex_options(es_aov         = 'pes',
             correction_aov = 'GG',
             emmeans_model  = 'multivariate')
# DO IT YOURSELF ----------------------------------------------------------

data(C8E15)

head(C8E15)
# We always need an ID column. As this is a fully between-subjects dataset,
# we'll add a running column (I'll also label the 3 factors):
C8E15 <- C8E15 %>%
  mutate(ID = factor(seq_len(n())),
         Parent = factor(Parent,labels = c('Mothers','Fathers')),
         Child = factor(Child, labels = c('Girls','Boys')),
         Months = factor(Months))
head(C8E15)
# 1. conduct a 3-way anova
time_aov <- aov_ez('ID','ProportionTime',C8E15,
                   between = c('Parent','Child','Months'))
time_aov

# 2. Plot the 3-way interaction plot.
emmip(time_aov,Child~Parent|Months, CIs = TRUE) # OR
emmip(time_aov,Child~Months|Parent, CIs = TRUE)

# 3. Conduct follow-up analysis on a significant 2-way interaction.
#    Make some (any) custom contrast function. Explain your results
emmip(time_aov,Parent~Months, CIs = TRUE)

em_parent_month <- emmeans(time_aov,~Parent+Months)
em_parent_month

my_month.emmc <- function(...){
  data.frame(
    "7 vs 10"      = c(-1,1,0),
    "(7,10) vs 13" = c(-1,-1,2)/2
  )
}

joint_tests(em_parent_month,by = 'Parent')
contrast(em_parent_month,'my_month', by = 'Parent')

joint_tests(em_parent_month,by = 'Months')
contrast(em_parent_month,'pairwise', by = 'Months')

contrast(em_parent_month,interaction = c('pairwise','my_month'))

# conclusion:
# Father's time spending increases from 7 to 10 months, and levels off.
# Mothers time increases from 10 to 13. (Is it linearly increasing?)
# The increase in time spent from 10 to 13 months in mothers is larger compared to fathers.

# HM ----------------------------------------------------------------------

# Confirm w/ contrasts there is no 3-way interaction in the coffee data.

coffee_data <- read.csv('coffee.csv')
coffee_data <- coffee_data %>%
  mutate(time = factor(time,levels = c('morning','noon','afternoon')))

coffee_fit <- aov_ez('ID','alertness',coffee_data,
                     within = c('time','coffee'), between = 'sex')
coffee_fit

emmip(coffee_fit,coffee~time|sex,CIs = TRUE)

em_3_way <- emmeans(coffee_fit,~coffee+time+sex)
em_3_way

contrast(em_3_way,'pairwise', by = c('time','sex')) # what does this test?

contrast(em_3_way,interaction = c('pairwise','pairwise'), by = 'sex') # what can we see here?

contrast(em_3_way,interaction = c('pairwise','pairwise','pairwise')) # what can we see here?
