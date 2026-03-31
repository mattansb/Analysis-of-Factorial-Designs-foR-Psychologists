library(afex)

afex_options(
  es_aov = 'pes',
  correction_aov = 'GG'
)

# Load Data ---------------------------------------------------------------

# Load data (is RDS file - these are R files the contain objects, in our
# case, a tidy data-frame)
Alcohol_data <- readRDS("data/Alcohol_data.rds")
head(Alcohol_data)


# Fit ANOVA model ---------------------------------------------------------

ersp_anova <- aov_ez(
  id = 'Subject',
  dv = 'ersp',
  within = c('Frequency', 'Correctness'),
  between = c('Alcohol'),
  data = Alcohol_data
)
ersp_anova

# We would like to control for mothers education level as it confounds the
# Alcohol->ERSP relationship.

# Fit ANCOVA model --------------------------------------------------------

# Keep in mind that some have argued that the use (or misuse) of ANCOVA
# should be avoided. See: http://doi.org/10.1037//0021-843X.110.1.40

ersp_ancova <- aov_ez(
  id = 'Subject',
  dv = 'ersp',
  within = c('Frequency', 'Correctness'),
  between = c('Alcohol'),
  data = Alcohol_data,

  # The new bits:
  covariate = 'mograde',
  factorize = FALSE # MUST set `factorize = FALSE`!
)
# Note the warning!

ersp_anova
ersp_ancova


# Center the covariable and re-fit the model -------------------------------

# Why center the covariable?
# See `Centering-and-ANOVA.html` for an
# extremely detailed explanation.

Alcohol_data$mograde_c <- datawizard::center(Alcohol_data$mograde)

# Re-Fit model
ersp_ancova2 <- aov_ez(
  id = 'Subject',
  dv = 'ersp',
  within = c('Frequency', 'Correctness'),
  between = c('Alcohol'),
  data = Alcohol_data,

  # The new bits
  covariate = 'mograde_c',
  factorize = FALSE
)
ersp_anova
ersp_ancova
ersp_ancova2 # Huge difference!

# Follow up analysis ------------------------------------------------------

# as usual ...
