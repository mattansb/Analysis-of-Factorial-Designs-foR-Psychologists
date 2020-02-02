library(tidyverse)
library(afex)
library(emmeans)

afex_options(es_aov         = 'pes',
             correction_aov = 'GG',
             emmeans_model  = 'univariate')

Phobia_data <- readRDS("Phobia.rds")

fit <- aov_ez("ID", "BehavioralAvoidance", Phobia_data,
              between = c("Gender", "Phobia", "Condition"))


# Q1 ----------------------------------------------------------------------

# 1. Compute the following contrasts for the Phobia-by-Condition
#    interaction:
em_phobia_condition <- emmeans(fit,~Phobia*Condition)
em_phobia_condition

#    A - Pairwise contrasts between all levels of Condition within each
#        Phobia level
c_int1 <- contrast(em_phobia_condition, "pairwise", by = "Phobia")
c_int1

#    B - Polynomial contrasts between all levels of Phobia within each
#        Condition.
c_int2 <- contrast(em_phobia_condition, "pairwise", by = "Condition")
c_int2

# 2. For each of the sets of contrasts, use 2 adjusment methods (none /
#    bonferroni / tukey / fdr).
update(c_int1, adjust = "fdr")
update(c_int2, adjust = "bonferroni")

# 3. Bind both sets of contrasts, and use the same adjustment methods from
#    Q2. How do the results differ from Q2?
c_int_all <- rbind(c_int1,c_int2)
update(c_int_all, adjust = "fdr")
update(c_int_all, adjust = "bonferroni") # more conservative than when only using c_int2...

