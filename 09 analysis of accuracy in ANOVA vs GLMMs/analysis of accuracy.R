
library(afex)
library(emmeans)

# In this lesson, we will be examining different ways of analysing measures that
# are categorical by nature.
# In psychology, one such measure is accuracy - when measured on a single trial,
# it can only have two values: success or failure. These are usually coded as a
# 1 or a 0 (but they could just as easily be coded as -0.9 and +34), and then
# aggragated for each subject and condition by averaging all the 0's and 1's.
# The result is a number ranging between 0-1, representing the mean accuracy for
# that subject/condition.
# As this is a number, it seems only natural to analyze this dependant variable
# using ANOVAs. So let's see what that looks like.


# This lesson is based on the following documentation:
# http://singmann.github.io/afex/doc/afex_analysing_accuracy_data.html
# It goes into further details and is worth a read.








# Here we have data from a 2*2 within-subject design:
stroop_e1 <- readRDS("stroop_e1.rds")

head(stroop_e1)
#  condition - (ego) deplete vs. control
# congruency - of the stroop task
#        acc - mean accuracy per participant (id) and condition(s)
#          n - number of trials per participant (id) and condition(s)
#              (we will use these later)
# (This is real data from: https://doi.org/10.1177/0956797620904990)


# The question: does ego depletion moderate the classic stroop effect on
# accuracy? In other words: is there a condition X congruency interaction?








# Analyzing with repeated measures anova ----------------------------------
# (reminder: a linear model)


afex_options(correction_aov = 'GG',
             emmeans_model  = 'multivariate',
             es_aov         = 'pes')


fit_anova <- aov_ez("id", "acc", stroop_e1,
                    within = c("congruency", "condition"))
fit_anova
#> Anova Table (Type 3 tests)
#> 
#> Response: acc
#>                 Effect     df  MSE          F   pes p.value
#> 1           congruency 1, 252 0.01 242.95 ***  .491   <.001
#> 2            condition 1, 252 0.00     5.43 *  .021    .021
#> 3 congruency:condition 1, 252 0.00       0.10 <.001    .757
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '+' 0.1 ' ' 1


# Hmmm... looks like there is no interaction.
# We can also see this visually:
emmip(fit_anova, condition ~ congruency, CIs = TRUE)
afex_plot(fit_anova, ~ congruency, ~ condition)






# However... ANOVA is a type of liner model. But are accuracies linear?
# It can be argued they are not!
# For example: is a change from 50% to 51% the same as a change from 98% to 99%?
#
# We might even remeber that we learned at some point that binary variables have
# a binomial sampling distribution. We can see this in the plots - as the mean
# accuracy is higher, the variance around it is smaller!
#
# Perhaps then, what we need is some type of logistic regression? A "repeated
# measures" logistic regression?
# We can do just that with generelized linear mixed models (GLMMs)!


# Suggested reading
# http://doi.org/10.1016/j.jml.2007.11.007
# https://doi.org/10.1890/10-0340.1






# Anlayzing within GLMM ---------------------------------------------------


# The syntax of a linear mixed model looks like this:
#  Y ~ Fixed_effects + (Random_effects | random_variable)
# - The fixed effects are all of the effect of interest.
# - You can think of the random effects as the "within subject" ones.
# - You can think of the random variable as the unit in which the random effects
#   are nested - in our case, they are nested in the subjects.
# (This is an oversimplification, better read up on this some more:
# http://doi.org/10.4324/9780429318405-2)


# In our case, the formula looks like this:
acc ~ congruency * condition + (congruency * condition | id)


# There are many functions for modeling (G)LMMs - fortunately, `afex` has us
# covered with a convenient function: `mixed()`.
#
# One thing to note: we must tell `mixed()` (or any other function) the number
# of trials on which the MEAN ACCURACY is based. We do that by passing this
# information to "weights = " (Again, read more here:
# http://singmann.github.io/afex/doc/afex_analysing_accuracy_data.html)





# This can take sevral minutes...
fit_glmm <- mixed(
  acc ~ congruency * condition + (congruency * condition | id), 
  data = stroop_e1, 
  weights = stroop_e1$n, # how many trials are the mean accuracies based on?
  family = "binomial", # the type of distribution
  method = "LRT" # this will give us the proper type 3 errors
)

fit_glmm
#> Mixed Model Anova Table (Type 3 tests, LRT-method)
#> 
#> Model: acc ~ congruency * condition + (congruency * condition | id)
#> Data: stroop_e1
#> Df full model: 14
#>                 Effect df      Chisq p.value
#> 1           congruency  1 321.05 ***   <.001
#> 2            condition  1  11.10 ***   <.001
#> 3 congruency:condition  1     4.23 *    .040
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '+' 0.1 ' ' 1

# The interaction is now significant!!
# (Note: We don't have F tests, but Chi-squared tests.)
#
# How can that be?? It is because the scale on which the model is tested is the
# logistic scale - where things look somewhat different!


emmip(fit_glmm, condition ~ congruency, CIs = TRUE)
# Note that the y-axis is NOT accuracy, but the logit(accuracy). We can ask for
# the plot on the response scale with:
emmip(fit_glmm, condition ~ congruency, CIs = TRUE, type = "response")
# where the interaction is "gone".


# # afex_plot alwyas gives results on the response scale:
# afex_plot(fit_glmm, ~ congruency, ~ condition) 




# Follow-up analyses ------------------------------------------------------

# Just as with an ANOVA, we can do all the same follow-ups with `emmeans`:

## 1. Simple effects:
joint_tests(fit_glmm)
# Note that df2 = Inf. In this case, we can compute Chisq = F.ratio * df1





## 2. Contrasts
emmeans(fit_glmm, ~ condition + congruency)
#>  condition congruency  emmean     SE  df asymp.LCL asymp.UCL
#>  control   congruent     4.16 0.0731 Inf      4.02      4.31
#>  deplete   congruent     3.87 0.0710 Inf      3.74      4.01
#>  control   incongruent   2.35 0.0618 Inf      2.23      2.47
#>  deplete   incongruent   2.27 0.0623 Inf      2.14      2.39
#> 
#> Results are given on the logit (not the response) scale. 
#> Confidence level used: 0.95


# If we want them on the response scale:
em_int <- emmeans(fit_glmm, ~ condition + congruency, type = "resp")
em_int
#>  condition congruency    prob       SE  df asymp.LCL asymp.UCL
#>  control   congruent   0.9847 0.001103 Inf    0.9824    0.9867
#>  deplete   congruent   0.9797 0.001415 Inf    0.9767    0.9823
#>  control   incongruent 0.9128 0.004920 Inf    0.9026    0.9219
#>  deplete   incongruent 0.9060 0.005304 Inf    0.8951    0.9159
#> 
#> Confidence level used: 0.95 
#> Intervals are back-transformed from the logit scale


# We can do any contrast we want:
contrast(em_int, "pairwise", by = "condition")
#>  congruency = congruent:
#>   contrast          odds.ratio    SE  df z.ratio p.value
#>   control / deplete       1.33 0.106 Inf 3.647   0.0003 
#> 
#>  congruency = incongruent:
#>   contrast          odds.ratio    SE  df z.ratio p.value
#>   control / deplete       1.09 0.070 Inf 1.275   0.2023 
#> 
#> Tests are performed on the log odds ratio scale

# Note that we get the odds ratio as the estimate, and that we have z values
# instead of t values.





# But we can also test contrasts on the response scale...
# Read more (with examples):
# https://shouldbewriting.netlify.app/posts/2020-04-13-estimating-and-testing-glms-with-emmeans/

