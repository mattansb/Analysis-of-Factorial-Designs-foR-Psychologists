library(emmeans)
library(car) # for Boot

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


# Between Subject Models --------------------------------------------------

obk_between <- readRDS("obk_between.rds")

## 1. Fit regular anova with `aov`
fit_between <- aov(value ~ treatment * gender, data = obk_between)



## 2. Make function for contrast
gender_treatment_boot <- function(.) {
  em_ <- emmeans(.,  ~ gender * treatment)
  c_ <- contrast(em_, 'pairwise', by = 'treatment')

  t_ <- summary(c_)$estimate
  # t_ <- summary(c_)$t.ratio

  return(t_)
}

gender_treatment_boot(fit_between) # test that it works



## 3. run bootstrap
gender_treatment_boot_result <-
  Boot(fit_between, gender_treatment_boot, R = 50) # R = 599 at least for alpha of 5%! (Wilcox, 2011, p. 119)



## 4. confidence intervales
summary(gender_treatment_boot_result) # original vs. bootstrapped estimate (bootMed) NOTE R < 50! Why?
confint(gender_treatment_boot_result, type = "bca") # does include zero?



# Within-Subject/Mixed Models ---------------------------------------------

# Although it is possible to do this with ANOVA, is it MUCH easier to do
# this with LMM. See:
# https://shouldbewriting.netlify.com/posts/2019-08-14-bootstrapping-rm-contrasts2/


data(obk.long, package = "afex")

## 1. Fit regular anova with `lmer`
library(lmerTest)
fit_lmm <- lmer(value ~ treatment * gender + (1|id),
                    data = obk.long)
anova(fit_lmm)



## 2. Make function for contrast
gender_treatment_boot <- function(.) {
  em_ <- emmeans(.,  ~ gender * treatment)
  c_ <- contrast(em_, 'pairwise', by = 'treatment')

  t_ <- summary(c_)$estimate
  # t_ <- summary(c_)$t.ratio

  return(t_)
}

gender_treatment_boot(fit_lmm) # test that it works



## 3. run bootstrap
gender_treatment_boot_result <-
  bootMer(fit_lmm, gender_treatment_boot, nsim = 50) # nsim = 599 at least for alpha of 5%! (Wilcox, 2011, p. 119)



## 4. confidence intervales
summary(gender_treatment_boot_result) # original vs. bootstrapped estimate (bootMed) NOTE R < 50! Why?
confint(gender_treatment_boot_result, type = "perc") # does include zero?



