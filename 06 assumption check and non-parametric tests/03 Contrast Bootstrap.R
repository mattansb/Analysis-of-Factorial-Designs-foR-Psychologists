library(emmeans)
library(car) # for Boot

# Bootstrapping is hard. Like, really really hard.
#
# Here I tried to write some code that you could adjust and re-use, if ever you
# find yourself in the need.
#
# This code computes the bootstrap estimates and confidence intervals using the
# The Percentile Bootstrap Method, the most common method (though not the only
# one). You can read and cite more in: Wilcox, R. R. (2011). Introduction to
# robust estimation and hypothesis testing (pp. 115-118). Academic press.


data(obk.long, package = "afex")

# Between Subject Models --------------------------------------------------

## 1. Fit regular anova with `aov`
fit_between <- aov(value ~ treatment * gender,
                   data = obk.long,
                   # MUST do this!
                   contrasts = list(treatment = "contr.sum",
                                    gender = "contr.sum"))



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
  Boot(fit_between, gender_treatment_boot,
       # For real analyses, use `R = 599` at least for alpha of 5%!!
       # (See Wilcox, 2011, p. 119)
       R = 10)




## 4. confidence intervals
# original vs. bootstrapped estimate (bootMed) NOTE R < 50! Why?
summary(gender_treatment_boot_result)
confint(gender_treatment_boot_result, type = "bca") # does include zero?




# Within-Subject/Mixed Models ---------------------------------------------

# Although it is possible to do this with ANOVA, is it MUCH easier to do
# this with LMM. See:
# https://shouldbewriting.netlify.com/posts/2019-08-14-bootstrapping-rm-contrasts2/


## 1. Fit regular anova with `mixed`
library(afex)
fit_lmm <- mixed(value ~ phase * hour + (phase * hour||id),
                 expand_re = TRUE,
                 data = obk.long)
anova(fit_lmm)



## 2. Make function for contrast
phase_hour_boot <- function(.) {
  em_ <- emmeans(.,  ~ phase * hour)
  c_ <- contrast(em_, 'poly', by = 'phase', max.degree = 2)

  t_ <- summary(c_)$estimate
  # t_ <- summary(c_)$t.ratio

  return(t_)
}

phase_hour_boot(fit_lmm) # test that it works



## 3. run bootstrap
phase_hour_boot_result <-
  bootMer(fit_lmm$full_model, phase_hour_boot,
          # For real analyses, use `nsim = 599` at least for alpha of 5%!!
          # (See Wilcox, 2011, p. 119)
          nsim = 10,
          .progress = "txt")




## 4. confidence intervals
# original vs. bootstrapped estimate (bootMed) NOTE R < 50! Why?
summary(phase_hour_boot_result)
confint(phase_hour_boot_result, type = "perc") # does include zero?



