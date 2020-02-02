library(tidyverse)
library(afex)
library(emmeans)

afex_options(es_aov = 'pes',
             correction_aov = 'GG',
             emmeans_model = 'univariate')

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

emmip(fit_alcohol_theta,~Correctness|Alcohol, CIs = TRUE)

# Exercise ----------------------------------------------------------------

# 1. Examine the simple effect for Correctness within each Alcohol group.
corr_by_theta <- joint_tests(fit_alcohol_theta,by = 'Alcohol')
corr_by_theta

eta2p_from_F(F.ratio = corr_by_theta$F.ratio,
             df1 = corr_by_theta$df1,
             df2 = corr_by_theta$df2)


# 2. Examin the polynomial contrast for Correctness within each Alcohol
#    Group.
em_int <- emmeans(fit_alcohol_theta,~Correctness*Alcohol)
c_int <- contrast(em_int,'poly',by = 'Alcohol')
c_int


# 3. Compute r^2-alerting and partial-eta^2 for these contrasts.
Fs <- corr_by_theta$F.ratio
F_df1s <- corr_by_theta$df1
ts <- summary(c_int)$t.ratio
t_dfs <- summary(c_int)$df

r2_alerting_from_t(ts[1:2],Fs[1],F_df1s[1])
r2_alerting_from_t(ts[3:4],Fs[2],F_df1s[2])
r2_alerting_from_t(ts[5:6],Fs[3],F_df1s[3])
r2_alerting_from_t(ts[7:8],Fs[4],F_df1s[4]) # Note that this effect size is large but not sig!

eta2p_from_t(ts,t_dfs)

# 4. Make a weights function (see last exercise) for Alcohol factor with the following contrasts:
#    4.1. Compare the Control group to the 3 alcohol groups.
#    4.2. Compare the ND to PFAS and FAS
#    4.3. Compare PFAS to FAS

Alc.emmc <- function(...){
  # Here is slightly diff way to do this than I've shown this far.
  Control <- c(1,0,0,0)
  ND      <- c(0,1,0,0)
  PFAS    <- c(0,0,1,0)
  FAS     <- c(0,0,0,1)

  data.frame(
    "Control v Exposed" = Control - (ND + PFAS + FAS)/3,
    "ND v P/FAS"        = ND - (PFAS + FAS)/2,
    "PFAS v FAS"        = PFAS - FAS
  )
}

# 5. Use this weights function any way you see fit.
c_int2 <- contrast(em_int,'Alc',by = 'Correctness')
c_int2

Fs <- joint_tests(fit_alcohol_theta,by = 'Correctness')$F.ratio
F_df1s <- joint_tests(fit_alcohol_theta,by = 'Correctness')$df1
ts <- summary(c_int2)$t.ratio
t_dfs <- summary(c_int2)$df

r2_alerting_from_t(ts[1:3],Fs[1],F_df1s[1])
r2_alerting_from_t(ts[4:6],Fs[2],F_df1s[2])
r2_alerting_from_t(ts[7:9],Fs[3],F_df1s[3])

eta2p_from_t(ts,t_dfs)


contrast(em_int,interaction = c('poly','Alc')) #?
