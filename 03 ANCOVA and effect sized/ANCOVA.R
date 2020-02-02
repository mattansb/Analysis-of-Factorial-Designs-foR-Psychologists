library(tidyverse)
library(afex)
library(emmeans)

afex_options(es_aov = 'pes',
             correction_aov = 'GG',
             emmeans_model = 'univariate')

# Load Data ---------------------------------------------------------------

# Load data (is RDS file - these are R files the contain objects, in our
# case, a tidy data-frame)
Alcohol_data <- readRDS("Alcohol_data.rds")
glimpse(Alcohol_data)

# Fit ANOVA model ---------------------------------------------------------

ersp_anova <- aov_ez('Subject','ersp',Alcohol_data,
                     within = c('Frequency','Correctness'),
                     between = c('Alcohol'))
ersp_anova

# But mothers education level is related to the outcome..
# We probably would want to control for it - reduce the MSE..

# Fit ANCOVA model --------------------------------------------------------

# Keep in mind that some have argued that the use (or misuse) of ANCOVA
# should be avoided. See: http://doi.org/10.1037//0021-843X.110.1.40

ersp_ancova <- aov_ez('Subject','ersp',Alcohol_data,
                      within = c('Frequency','Correctness'),
                      between = c('Alcohol'),
                      covariate = 'mograde', factorize = FALSE) # MUST set factorize = FALSE with covariates!
ersp_anova
ersp_ancova

# Center the covariate and re-fit the model -------------------------------

# Why center the covariate? See Centering Variables for ANOVA.docx for an
# extremely detailed explanation.

Alcohol_data <- Alcohol_data %>%
  mutate(mograde_c = mograde - mean(mograde))

# Re-Fit model
ersp_ancova2 <- aov_ez('Subject','ersp',Alcohol_data,
                       within = c('Frequency','Correctness'),
                       between = c('Alcohol'),
                       covariate = 'mograde_c', factorize = FALSE)
ersp_anova
ersp_ancova
ersp_ancova2

emmip(ersp_ancova2,Correctness~Alcohol|Frequency, CIs = TRUE)
joint_tests(ersp_ancova2, by = 'Frequency')
