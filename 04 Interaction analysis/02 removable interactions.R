library(afex)
library(emmeans)

stroop_data <- readRDS("dyslexia_stroop.rds")
head(stroop_data)
# This is (fake) data from an experiment where participants with dyslexia and
# control participants performed a stroop task.


fit <- aov_ez("id", "mRT", stroop_data,
              within = "condition",
              between = "Group")
fit
# We have an interaction! Let's take a look...

afex_plot(fit, ~ condition, ~ Group)
# Looks like the Ss with dyslexia show larger stoop effects (compared to
# controls). But there is an alternative explanation, as this is a "removable
# interaction" - also known as an ordinal interaction.
#
# Read more: https://doi.org/10.3758/s13421-011-0158-0





# Difference of differences -----------------------------------------------


emmip(fit, Group ~ condition, CIs = TRUE)
# Looks like an interaction to me...


## 1. Get conditional means
em_ <- emmeans(fit, ~ condition + Group)


## 2. Contrasts
# 2a. Pairwise differences between the conditions, by group:
c_cond_by_group <- contrast(em_, "pairwise", by = "Group")
c_cond_by_group

# 2b. Pairwise differences between the groups by pairwise contrasts:
c_diff_of_diff <- contrast(c_cond_by_group, "pairwise", by = "contrast")
c_diff_of_diff



# # Note that we could have just done:
# contrast(em_, interaction = list(Group = "pairwise",
#                                  condition = "pairwise"))
# # Which gives the same results.




# Difference of ratios ----------------------------------------------------

# But we can also compare RATIOS!
# The is, instead of asking if {RT1 - RT2} is different than 0,
# We ask if {RT1 / RT2} is different than 1.
#
# We do this by looking at the differences between the the log(emmeans), since:
# exp(log(x) - log(y)) == x / y


# Will this matter?
emmip(fit, Group ~ condition, CIs = TRUE, trans = "log")
# Where did the interaction go??


## 1. Get conditional means
# (Same as above.)


## 2. Contrasts
# 2a1. Transform to log scale:
em_log <- regrid(em_, trans = "log", predict.type = "response")
# 2a2. Pairwise differences between the log of conditions, by group:
c_cond_by_group_log <- contrast(em_log, "pairwise", by = "Group")
c_cond_by_group_log

# 2b1. Transform back to response scale:
c_cond_by_group_ratio <- regrid(c_cond_by_group_log,
                                trans = "response")
# 2b2. Pairwise differences between the groups by pairwise ratio:
c_diff_of_ratio <- contrast(c_cond_by_group_ratio, "pairwise",
                            by = "contrast")
c_diff_of_ratio


# The difference of ratios is not significant!!
# This result might suggest that the increased effect in the dyslexia group
# is due to the slower overall RTs...




# Ratio of ratios ---------------------------------------------------------

# We can also compare the pairwise ratios by THEIR ratio.


## 1. Get conditional means
# (Same as above)

## 2. Contrasts
# 2a. Pairwise differences between the log of conditions, by group:
# (Same as above)

# 2b1. Pairwise ratio between the groups by pairwise ratio:
c_diff_of_diff_log <- contrast(c_cond_by_group_log, "pairwise",
                               by = "contrast")
c_diff_of_diff_log





# Summary -----------------------------------------------------------------

# 1. In this example, difference of ratios and ratio of ratios give similar
#   results, but this is never guaranteed!
# 2. Even if the results were still significant on the log scale, it is still
#   possible that the interaction is removable! All this does is alleviate the
#   concern... somewhat...
# 3. Note that the opposite can also happen - where a non-significant
#   interaction can be significant on the log scale. For example, when analyzing
#   mean accuracy (which you should be doing with glm / glmms).
#   See examples:
#   https://shouldbewriting.netlify.app/posts/2020-04-13-estimating-and-testing-glms-with-emmeans/

