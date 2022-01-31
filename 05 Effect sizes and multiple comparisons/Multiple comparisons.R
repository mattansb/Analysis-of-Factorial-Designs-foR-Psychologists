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



afex_plot(fit, ~ Condition, ~ Phobia, ~ Gender)

# Update contrasts ----------------------------------------------------------

em_all.means <- emmeans(fit, ~ Condition + Phobia)
c_cond.by.pho <- contrast(em_all.means, method = "pairwise", by = "Phobia")

c_cond.by.pho
# Note that we automatically get p-value correction for 3 tests (within each
# level of Phobia). By default we get Tukey (different contrast methods have
# different default correction methods), but we can use other types:

update(c_cond.by.pho, adjust = "none")
update(c_cond.by.pho, adjust = "holm")
update(c_cond.by.pho, adjust = "fdr")

?p.adjust # more?

# We can also have the correction applied to all contrasts (not just in groups
# of 3):
update(c_cond.by.pho, adjust = "holm", by = NULL)

# Or split in some other way:
update(c_cond.by.pho, adjust = "fdr", by = "contrast")





# Combine contrasts -------------------------------------------------------

# Let's explore!

em_Gender <- emmeans(fit,  ~ Gender)
em_Phobia <- emmeans(fit,  ~ Phobia)
em_Condition <- emmeans(fit,  ~ Condition)


c_Gender <- contrast(em_Gender, "pairwise")
c_Gender

c_Phobia <- contrast(em_Phobia, "consec")
c_Phobia

c_Condition <- contrast(em_Condition, "pairwise")
c_Condition


# Combine tests and adjust p vlaues for ALL OF THEM:
rbind(c_Condition, c_Gender, c_Phobia) # default to bonferroni
rbind(c_Condition, c_Gender, c_Phobia, adjust = "none")
rbind(c_Condition, c_Gender, c_Phobia, adjust = "fdr")
# How are these affected?
# What about {Implosion - CBT}?



# Adjust p-values not from `emmeans` --------------------------------------

# Under the hood, `emmeans` uses the `p.adjust()` function, that can be used for
# adjusting any vector of p-values, using several methods:

ps <- c(0.3327, 0.0184, 0.1283, 0.0004,
        0.2869, 0.1815, 0.1593, 0.0938, 0.0111)

p.adjust(ps, method = "bonferroni")
p.adjust(ps, method = "fdr")


# HW ----------------------------------------------------------------------

# 1. Compute the following contrasts for the Phobia-by-Condition
#    interaction: Polynomial contrasts between all levels of Phobia within each
#    Condition.
# 2. Use 2 adjusment methods (none / bonferroni / tukey / fdr).
