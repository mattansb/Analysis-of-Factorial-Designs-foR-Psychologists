library(dplyr)
library(afex)
library(emmeans)

coffee_data <- read.csv('coffee.csv') %>%
  mutate(time = factor(time,levels = c('morning','noon','afternoon')))
head(coffee_data)


# 3-way ANOVA -------------------------------------------------------------


# setting some options
afex_options(correction_aov = 'GG',
             emmeans_model  = 'multivariate',
             es_aov         = 'pes')



coffee_fit <- aov_ez('ID','alertness', coffee_data,
                     within = c('time','coffee'),
                     between = 'sex')

coffee_fit


# Explore of the other 2-way interactions.
# (With plots along the way)

# I chose to look at `sex:time`, treating `time` as the focal effect and `sex`
# as the moderator (but you might want to look at it the other way round).




# Simple effects ----------------------------------------------------------

# Since I chose `sex` as the moderator, we will condition the effects on sex:
joint_tests(coffee_fit, by = "sex")
#> sex = female:
#>  model term  df1 df2 F.ratio p.value
#>  coffee        1  18  80.540 <.0001
#>  time          2  18  12.498 0.0004
#>  coffee:time   2  18   7.680 0.0039
#>
#> sex = male:
#>  model term  df1 df2 F.ratio p.value
#>  coffee        1  18  20.135 0.0003
#>  time          2  18  69.035 <.0001
#>  coffee:time   2  18   7.680 0.0039

# Looking at the simple (conditional) effect of `time` by `sex`, we find a
# significant effect for time both for men and women. However, the significant
# (main) interaction tells us that these patterns are somehow different.



emmip(coffee_fit, ~  time | sex, CIs = TRUE)

# The figure suggests an overall increase in alertness in males, but a decrease
# in alertness in females!



# Simple effect contrasts -------------------------------------------------

# 1. Get emmeans:
em_time_sex <- emmeans(coffee_fit, ~ time + sex)
em_time_sex
#>  time      sex    emmean    SE df lower.CL upper.CL
#>  morning   female  21.02 0.981 18    18.96    23.08
#>  noon      female  17.16 0.990 18    15.08    19.24
#>  afternoon female  15.23 0.801 18    13.55    16.92
#>  morning   male     7.52 0.981 18     5.46     9.58
#>  noon      male    15.23 0.990 18    13.15    17.32
#>  afternoon male    21.02 0.801 18    19.33    22.70
#>
#> Results are averaged over the levels of: coffee
#> Confidence level used: 0.95



c_time_by_sex <- contrast(em_time_sex, method = "consec", by = "sex")
c_time_by_sex
#> sex = female:
#>  contrast         estimate   SE df t.ratio p.value
#>  noon - morning      -3.86 1.54 18 -2.505  0.0375
#>  afternoon - noon    -1.93 1.34 18 -1.440  0.2591
#>
#> sex = male:
#>  contrast         estimate   SE df t.ratio p.value
#>  noon - morning       7.71 1.54 18  5.011  0.0002
#>  afternoon - noon     5.78 1.34 18  4.321  0.0008
#>
#> Results are averaged over the levels of: coffee
#> P value adjustment: mvt method for 2 tests

# For females, there is a significant decrease in alertness from morning to
# noon, but the decrease from noon to afternoon.
# In males, the increase is significant to each consecutive time of day.


emmip(c_time_by_sex, sex ~ contrast, CIs = TRUE) +
  ggplot2::geom_hline(yintercept = 0)



# Interaction contrasts ---------------------------------------------------


c_time_sex <- contrast(em_time_sex,
                       interaction = list(sex = "pairwise", time = "consec"))
c_time_sex
#>  sex_pairwise  time_consec      estimate   SE df t.ratio p.value
#>  female - male noon - morning     -11.57 2.18 18 -5.315  <.0001
#>  female - male afternoon - noon    -7.71 1.89 18 -4.074  0.0007
#>
#> Results are averaged over the levels of: coffee

# unsurprisingly, the difference between makes and females between morning and
# noon and noon and afternoon are both different.


emmip(c_time_sex, time_consec ~ sex_pairwise, CIs = TRUE) +
  ggplot2::geom_hline(yintercept = 0)
# (this is not as intuitive perhaps...)


# HM ----------------------------------------------------------------------

# Confirm w/ contrasts there is no 3-way interaction in the coffee data.

em_3way <- emmeans(coffee_fit, ~ time + sex + coffee)

c_3way_by_coffee <- contrast(em_3way, by = "coffee",
                             interaction = list(time = "consec",
                                                sex = "pairwise"))
c_3way_by_coffee
#> coffee = coffee:
#>  time_consec      sex_pairwise  estimate   SE df t.ratio p.value
#>  noon - morning   female - male   -11.57 2.58 18 -4.486  0.0003
#>  afternoon - noon female - male    -7.71 2.58 18 -2.985  0.0079
#>
#> coffee = control:
#>  time_consec      sex_pairwise  estimate   SE df t.ratio p.value
#>  noon - morning   female - male   -11.57 2.59 18 -4.463  0.0003
#>  afternoon - noon female - male    -7.71 2.48 18 -3.111  0.0060

# see can see that the differences between the time-of-day in the effect of sex
# is the same for both coffee and control (look at the `estimate` column).


emmip(c_3way_by_coffee, time_consec ~ sex_pairwise | coffee, CIs = TRUE) +
  ggplot2::geom_hline(yintercept = 0)





c_3way <- contrast(em_3way, interaction = list(time = "consec",
                                               sex = "pairwise",
                                               coffee = "pairwise"))
c_3way
#>  time_consec      sex_pairwise  coffee_pairwise   estimate   SE df t.ratio p.value
#>  noon - morning   female - male coffee - control  4.22e-14 2.79 18 0.000   1.0000
#>  afternoon - noon female - male coffee - control -3.87e-14 3.36 18 0.000   1.0000


# or...... liternally a contrast of contrasts!
contrast(c_3way_by_coffee, method = "pairwise",
         by = c("time_consec", "sex_pairwise"))
#> time_consec = noon - morning, sex_pairwise = female - male:
#>  contrast          estimate   SE df t.ratio p.value
#>  coffee - control  4.22e-14 2.79 18 0.000   1.0000
#>
#> time_consec = afternoon - noon, sex_pairwise = female - male:
#>  contrast          estimate   SE df t.ratio p.value
#>  coffee - control -3.87e-14 3.36 18 0.000   1.0000

# The estimates are very small - basically 0.



