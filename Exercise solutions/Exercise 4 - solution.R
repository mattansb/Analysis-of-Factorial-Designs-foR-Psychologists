library(afex)
library(emmeans)
library(dplyr)
library(effectsize)

afex_options(
  es_aov = 'pes',
  correction_aov = 'GG',
  emmeans_model = 'multivariate'
)



# Load Data ---------------------------------------------------------------

# Load data (is RDS file - these are R files the contain objects, in our case, a
# tidy data-frame)
Alcohol_data <- readRDS("Alcohol_data.rds")
# data from https://doi.org/10.1111/acer.14244

Alcohol_data_theta <- Alcohol_data %>%
  filter(Frequency == "4to7Hz") %>%
  select(-Frequency)
head(Alcohol_data_theta)


fitTheta <- aov_ez('Subject','ersp',
                   within = c('Correctness'),
                   between = c('Alcohol'),
                   data = Alcohol_data_theta)
fitTheta




# 1. Examine the simple effect for Correctness ----------------------------
# within each Alcohol, and compute the partial-eta^2 and the partial-omega^2 for
# the simple effects.

joint_tests(fitTheta, by = "Alcohol") %>%
  mutate(F_to_eta2(F.ratio, df1, df2))

joint_tests(fitTheta, by = "Alcohol") %>%
  mutate(F_to_omega2(F.ratio, df1, df2))



# 2. Examine the polynomial contrast for Alcohol Group --------------------
# within each level of Correctness.

em_alcohol_corr <- emmeans(fitTheta, ~ Alcohol + Correctness)

c_alc_by_corr <- contrast(em_alcohol_corr, method = "poly", by = "Correctness")
c_alc_by_corr




# 3. Compute partial-eta^2 for these contrasts. ---------------------------

c_alc_by_corr %>%
  summary() %>%
  mutate(t_to_eta2(t.ratio, df))

# we can see that even where the effects are significant, they are small...



# 4. Build the following weights scheme for Alcohol group -----------------
#    4.1. Compare the Control group to {the 3 alcohol groups}.
#    4.2. Compare the ND to {PFAS and FAS}
#    4.3. Compare PFAS to FAS.

contr.Alc <- data.frame(
  ctrl_vs_others = c(-3, 1, 1, 1) / 3,
  ND_vs_PFASFAS = c(0, -2, 1, 1)/2,
  PFAS_vs_FAS = c(0, 0, -1, 1)
)


# Are these contrasts orthogonal? Are they exhaustive?

# We can test orthogonality by computing the correlations between the contrasts:
cor(contr.Alc)
# No correlation between them - they are all orthogonal!


# Are they exhaustive?
# Yes - 3 contrasts for an effect with 3 degrees of freedom!



# 5. Use this weights scheme any way you see fit. -------------------------

# Simple effect contrasts:
c_alc_by_corr2 <- contrast(em_alcohol_corr, method = contr.Alc,
                           by = "Correctness")
c_alc_by_corr2

# interaction contrasts:
c_alc_corr <- contrast(em_alcohol_corr,
                       interaction = list(
                         Alcohol = contr.Alc,
                         Correctness = "pairwise"
                       ))
c_alc_corr



# 6. Compute Cohen's d for these ^ contrasts. -----------------------------

c_alc_by_corr2 %>%
  summary() %>%
  mutate(t_to_d(t.ratio, df))


c_alc_corr %>%
  summary() %>%
  mutate(t_to_d(t.ratio, df))

