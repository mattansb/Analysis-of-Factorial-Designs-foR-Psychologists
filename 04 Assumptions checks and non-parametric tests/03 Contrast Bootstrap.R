library(tidyverse)
library(car)
library(emmeans)

# Bootstrapping is hard. Like, really really hard.
#
# Here I tried to write some code that you could adjust and re-use, if ever
# you find yourself in the need.
#
# This code computes the bootstrap estimates and confidence intervales
# using the The Percentile Bootstrap Method, the most common method (though
# not the only one). You can read and cite more in: Wilcox, R. R. (2011).
# Introduction to robust estimation and hypothesis testing (pp. 115-118).
# Academic press.


# must do this!
options(contrasts = c('contr.sum', 'contr.poly'))
# See appendix of previous lesson about centering FACTORS!

source("https://gist.github.com/mattansb/e9c5a63a5cc74c4f535534cf740871bf/raw")

# Between Subject Models --------------------------------------------------

obk_between <- readRDS("obk_between.rds")

# 1. Fit regular anova with `aov`
fit_between <- aov(value ~ treatment * gender, data = obk_between)

# 2. Make function for contrast
gender_treatment_boot <- function(.) {
  em_ <- emmeans(.,  ~ gender * treatment)
  c_ <- contrast(em_, 'pairwise', by = 'treatment')
  # print(c_)
  t_ <- summary(c_)$estimate
  # t_ <- summary(c_)$t.ratio

  return(t_)
}

gender_treatment_boot(fit_between) # test that it works

# 3. run bootstrap
gender_treatment_boot_result <-
  Boot(fit_between, gender_treatment_boot, R = 50) # R = 599 at least for alpha of 5%! (Wilcox, 2011, p. 119)

# 4. confidence intervales
summary(gender_treatment_boot_result) # original vs. bootstrapped estimate (bootMed) NOTE R < 50! Why?
confint(gender_treatment_boot_result, type = "perc") # does include zero?
boot_pvalues(gender_treatment_boot_result) # these can be passed to p.adjust (see next lesson)

# Within-Subject Models ---------------------------------------------------

# This is where things get complicated... In addition to the above, we also
# need to make out data wide; fit a multivariate ANOVA; reconstruct the
# within-subject factors with emmeans...
# You can use this code as a template.

# load data
obk_within <- readRDS("obk_within.rds")

# 1. Make data wide
obk_within_wide <- obk_within %>%
  unite("cond", phase, hour) %>%
  spread(cond, value)

# 2. Make a list of levels
head(obk_within_wide)
rm_levels <- list(hour = c("1", "2", "3", "4", "5"),
                  phase = c("fup", "post", "pre"))
# make sure they varry in the same order!!!!!


# 2. put repeated measure in a matrix column:
obk_within_matrixDV <- obk_within_wide %>%
  select(id)
obk_within_matrixDV$M <- obk_within_wide %>%
  select(-id) %>%
  as.matrix()

# 3. Fit the model
fit_within <- aov(M ~ 1, obk_within_matrixDV) # ~ 1 because no between-subject factors

# 4. Make function for contrast
phase_boot <- function(.) {
  rg <- ref_grid(., mult.levs = rm_levels)

  em_ <- emmeans(rg, ~ phase)
  c_ <- contrast(em_, "pairwise")
  t_ <- summary(c_)$estimate
  # t_ <- summary(c_)$t.ratio

  return(t_)
}

# 5. run bootstrap
phase_boot_result <-
  Boot(fit_within, phase_boot, R = 50) # R = 599 at least for alpha of 5%! (Wilcox, 2011, p. 119)

# 6. confidence intervales
summary(phase_boot_result)
confint(phase_boot_result, type = "perc")
boot_pvalues(phase_boot_result)

# Mixed -------------------------------------------------------------------

# This is almost identical to the within-subject example above.
# You can use this code as a template.


# load data
data(obk.long, package = "afex")


# 1. Make data wide
obk_mixed_wide <- obk.long %>%
  unite("cond", phase, hour) %>%
  spread(cond, value)

# 2. Make a list of levels
head(obk_mixed_wide)
rm_levels <- list(hour = c("1", "2", "3", "4", "5"),
                  phase = c("fup", "post", "pre"))
# make sure they varry in the same order!!!!!


# 2. put repeated measure in a matrix column:
obk_mixed_matrixDV <- obk_mixed_wide %>%
  select(id, age, treatment, gender)
obk_mixed_matrixDV$M <- obk_mixed_wide %>%
  select(-id, -age, -treatment, -gender) %>%
  as.matrix()


# 3. Fit the model
fit_mixed <- aov(M ~ treatment * gender, obk_mixed_matrixDV) # ~ between-subject factors

# 4. Make function for contrast
phase_gender_boot <- function(.) {
  rg <- ref_grid(., mult.levs = rm_levels)

  em_ <- emmeans(rg, ~ phase * gender)
  c_ <- contrast(em_, "pairwise", by = 'gender')
  t_ <- summary(c_)$estimate
  # t_ <- summary(c_)$t.ratio

  return(t_)
}

# 5. run bootstrap
phase_gender_boot_result <-
  Boot(fit_mixed, phase_gender_boot, R = 50)

# 6. confidence intervales
summary(phase_gender_boot_result)
confint(phase_gender_boot_result, type = "perc")
boot_pvalues(phase_gender_boot_result)
