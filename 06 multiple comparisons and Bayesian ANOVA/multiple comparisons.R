library(afex)
library(emmeans)

afex_options(es_aov         = 'pes',
             correction_aov = 'GG',
             emmeans_model  = 'univariate')

# Load data ---------------------------------------------------------------

Phobia_data <- readRDS("Phobia.rds")

head(Phobia_data)

# Fit model ---------------------------------------------------------------


fit <- aov_ez("ID", "BehavioralAvoidance", Phobia_data,
              between = c("Gender", "Phobia", "Condition"))
fit


# Plot --------------------------------------------------------------------

afex_plot(fit,  ~ Phobia,  ~ Condition,  ~ Gender)
emmip(fit, Condition ~ Phobia | Gender, CIs = TRUE)


# Contrasts ---------------------------------------------------------------

# We don't have any a priori hypotheses... let's explore!

em_Gender <- emmeans(fit,  ~ Gender)
em_Phobia <- emmeans(fit,  ~ Phobia)
em_Condition <- emmeans(fit,  ~ Condition)

# different contrasts have different default correction methods
c_Gender <- contrast(em_Gender, "pairwise")
c_Gender

c_Phobia <- contrast(em_Phobia, "consec")
c_Phobia

c_Condition <- contrast(em_Condition, "pairwise")
c_Condition


# Adjust p-value ----------------------------------------------------------

# How do these ajustment methods change the conclusion?
update(c_Condition, adjust = "none")        # No adjusments
update(c_Condition, adjust = "tukey")       # ONLY good for 2-tailed pairwise comparisons.
update(c_Condition, adjust = "bonferroni")  # Popular
update(c_Condition, adjust = "fdr")         # Use when many many contrasts
?p.adjust # more?

update(c_Phobia, adjust = "tukey")          # Will not give tukey!

# Combine tests and adjust p vlaues for ALL OF THEM:
rbind(c_Condition, c_Gender, c_Phobia) # default to bonferroni
rbind(c_Condition, c_Gender, c_Phobia, adjust = "none")
rbind(c_Condition, c_Gender, c_Phobia, adjust = "fdr")
# How are these affected?
# What about {Implosion - CBT}?


# HW ----------------------------------------------------------------------

# 1. Compute the following contrasts for the Phobia-by-Condition
#    interaction:
#    A - Pairwise contrasts between all levels of Condition within each
#        Phobia level
#    B - Polynomial contrasts between all levels of Phobia within each
#        Condition.
# 2. For each of the sets of contrasts, use 2 adjusment methods (none /
#    bonferroni / tukey / fdr).
# 3. Bind both sets of contrasts, and use the same adjustment methods from
#    Q2. How do the results differ from Q2?
