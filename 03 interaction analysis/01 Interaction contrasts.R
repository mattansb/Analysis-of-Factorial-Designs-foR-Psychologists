library(afex) # for ANOVA

# for follow up analysis
library(emmeans)
library(marginaleffects)

afex_options(
  es_aov = 'pes',
  correction_aov = 'GG'
)


# let's look at the data/coffee_plot.png and get a feel for our data.
#
# What marginal (main) effects and interactions does it look like we have here?
# What conditional (simple) effects does it look like we have here?

coffee_data <- read.csv('data/coffee.csv')
coffee_data$time <- factor(
  coffee_data$time,
  levels = c('morning', 'noon', 'afternoon')
)
head(coffee_data)


coffee_fit <- aov_ez(
  id = 'ID',
  dv = 'alertness',
  within = c('time', 'coffee'),
  between = 'sex',
  data = coffee_data
)

coffee_fit # what's up with the 3-way interaction??


# === NOTE ===
# The model we used here is an ANOVA - but what follows is applicable to any
# type of multiple regression with categorical predictors.

# We will be looking at the Coffee-by-Time interaction.
afex_plot(coffee_fit, ~time, ~coffee)


# Probing the Coffee-by-Time interaction with {emmeans} ----------------------

## Probing the **simple effect** for `time` by `coffee` --------------------
# We are looking at a 2-way interaction in a 3-way design, so this means we are
# averaging over the levels sex.

### Test simple effects ---------------
# We can break down an interaction into simple effects:
# ("by" can be a vector for simple-simple effects, etc...)
joint_tests(coffee_fit, by = "coffee")
# Which rows are we looking at?

### Contrast Analysis ---------------

# Step 1. Get the means
em_time.coffee <- emmeans(coffee_fit, ~ time + coffee)
em_time.coffee


# Step 2. Compare them (conditionally)
# We want to look at the simple effects for time, conditionally on values of
# coffee. So we must use "by"!

# Here too we can use both types of methods:
contrast(em_time.coffee, method = "consec", by = "coffee") # note p-value correction
contrast(em_time.coffee, method = "poly", by = "coffee") # note p-value correction


w.time <- data.frame(
  "wakeup vs later" = c(-2, 1, 1) / 2, # make sure each "side" sums to (+/-)1!
  "start vs end of day" = c(-1, 0, 1),

  check.names = FALSE
)
w.time # Are these orthogonal contrasts?
cor(w.time)

contrast(em_time.coffee, method = w.time, by = "coffee")


## Interaction Contrasts ----------------------------------------

# After seeing the conditional contrasts - the contrasts for the effect of time
# within the levels of coffee, we can now ask: do these contrasts DIFFER BETWEEN
# the levels of coffee?

contrast(
  em_time.coffee,
  interaction = list(time = "consec", coffee = "pairwise")
)

# Here too we can use custom contrasts:
contrast(em_time.coffee, interaction = list(time = w.time, coffee = "pairwise"))

# How do we interpret these?

# These steps can be used for higher-order interactions as well. For example,
# for a 3-way interaction we can:
# - Look at the *simple* 2-way interactions.
#   - Look at the *simple simple* effect.
#     - Conduct a contrast analysis for the *simple simple* effect.
#   - Conduct an interaction contrast for the *simple* 2-way interactions.
# - Conduct an interaction contrast for the 3-way interactions.

# Same for 4-way interactions... etc.

# Probing the Coffee-by-Time interaction with {marginaleffects} ----------------
# Let's do it all again...

## Probing the **simple effect** for `time` by `coffee` --------------------

### Test simple effects ---------------
mfx <- avg_predictions(
  coffee_fit,
  by = c("time", "coffee"),
  hypothesis = ~ reference | coffee
)

hypotheses(mfx, joint = 1:2) # simple time effect for coffee
hypotheses(mfx, joint = 3:4) # simple time effect for control


### Contrast Analysis ---------------

# Compare consecutive time points for each level of coffee:
(mfx_consec <- avg_predictions(
  coffee_fit,
  by = c("time", "coffee"),
  hypothesis = ~ sequential | coffee
))

# Compare the polynomial trend for time for each level of coffee:
avg_predictions(
  coffee_fit,
  by = c("time", "coffee"),
  hypothesis = ~ poly | coffee
)

# Compare custom contrasts for time for each level of coffee:
(mfx_custom <- avg_predictions(
  coffee_fit,
  by = c("time", "coffee"),
  hypothesis = ~ I(drop(t(w.time) %*% x)) | coffee
))


## Interaction Contrasts ----------------------------------------

# After seeing the conditional contrasts - the contrasts for the effect of time
# within the levels of coffee, we can now ask: do these contrasts DIFFER BETWEEN
# the levels of coffee?

hypotheses(mfx_consec, hypothesis = ~ revpairwise | hypothesis)

hypotheses(mfx_custom, hypothesis = ~ revpairwise | hypothesis)

# Exercise ----------------------------------------------------------------

# Explore the sex-by-time interaction using all the steps from above.
# Answer these questions:
# A. Which sex is the most alert in the morning?
# B. What is the difference between noon and the afternoon for males?
# C. Is this difference larger than the same difference for females?
#
# Interpret your results along the way...
#
# *. Confirm (w/ contrasts, simple effects...) that there really is no 3-way
#   interaction in the coffee data.
