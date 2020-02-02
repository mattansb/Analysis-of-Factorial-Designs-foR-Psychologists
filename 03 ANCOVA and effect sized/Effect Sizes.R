library(tidyverse)
library(afex)
library(emmeans)

afex_options(es_aov = 'pes',
             correction_aov = 'GG',
             emmeans_model = 'univariate')


# Effect Size (approx.) Functions -----------------------------------------

r2_alerting_from_t <- function(ts,F.ratio,df1){
  r2a <- (ts^2)/(F.ratio*df1)
  r2a
}

eta2p_from_F <- function(F.ratio,df1,df2){
  (F.ratio*df1)/(F.ratio*df1 + df2)
}

eta2p_from_t <- function(t.ratio,df){
  eta2p_from_F(t.ratio^2,1,df)
}

# Load and Tidy Data ------------------------------------------------------

Alcohol_data <- readRDS("Alcohol_data.rds") %>%
  mutate(mograde_c = mograde - mean(mograde)) %>%
  filter(Frequency == '4to7Hz') # Looking only at the Frequency of interest


# Fit The Model -----------------------------------------------------------

fit_alcohol_theta <- aov_ez('Subject','ersp',Alcohol_data,
                            within = c('Correctness'),
                            between = c('Alcohol'),
                            covariate = 'mograde_c', factorize = FALSE)
fit_alcohol_theta

emmip(fit_alcohol_theta,~Correctness|Alcohol, CIs = TRUE)
emmip(fit_alcohol_theta,Correctness~Alcohol, CIs = TRUE)


# Main effect for Correctness ---------------------------------------------

emmip(fit_alcohol_theta,~Correctness, CIs = TRUE)

em_corr <- emmeans(fit_alcohol_theta,~Correctness)
em_corr

jt_corr <- joint_tests(em_corr) # compare with the main effect for correctness in `fit_alcohol_theta`
jt_corr

c_corr <- contrast(em_corr,'poly')
c_corr


r2a_corr <- r2_alerting_from_t(ts = c(3.657,-0.110),F.ratio = 6.691,df1 = 2)
r2a_corr
sum(r2a_corr)

eta2p_from_F(6.691,2,86) # compare to `fit_alcohol_theta`

eta2p_from_t(c(3.657,-0.110),86)


# DO IT YOURSELF ----------------------------------------------------------

# 1. Examine the simple effect for Correctness within each Alcohol group,
#    and compute the partial-eta^2 for the simple effects.
# 2. Examin the polynomial contrast for Correctness within each Alcohol
#    Group.
# 3. Compute r^2-alerting and partial-eta^2 for these contrasts.
#    Remember, the sum of r^2-alerting should be ~1.
# 4. Make a weights function (see last exercise) for Alcohol factor with
#    the following contrasts:
#    4.1. Compare the Control group to the 3 alcohol groups.
#    4.2. Compare the ND to PFAS and FAS
#    4.3. Compare PFAS to FAS
# 5. Use this weights function any way you see fit.

