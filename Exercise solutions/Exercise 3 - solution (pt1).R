library(AMCP)
library(afex)
library(emmeans)

afex_options(
  es_aov         = 'pes' # for partial-eta-square in the anova table
)

data(C8E15)

head(C8E15)
# The data:
# Mothers (Parent==1) of four girls (Child==1) and of four boys (Child==2) at
# each of three ages (7, 10, and 13 months) were observed and recorded during
# toy-play interactions with their infants. An equal number of fathers
# (Parent==2) from different families were also observed. The dependent variable
# to be considered here was the proportion of time parents encouraged pretend
# play in their children.
#
# * Note that there are better ways to model proportions! We will talk about
#   these later in the course.



# 1. Conduct a 3-way anova ------------------------------------------------

# Oops... even though this design is completetly between-subjects, afex always
# needs the subject ID column! So let's first make on:
C8E15$ID <- seq_len(nrow(C8E15))
head(C8E15)

fit <- aov_ez(id = "ID", dv = "ProportionTime", data = C8E15,
              between = c("Parent", "Child", "Months"))
fit
#> Anova Table (Type 3 tests)
#>
#> Response: ProportionTime
#>                Effect    df  MSE         F   pes p.value
#> 1              Parent 1, 36 0.01  10.44 **  .225    .003
#> 2               Child 1, 36 0.01      0.09  .003    .763
#> 3              Months 2, 36 0.01 20.12 ***  .528   <.001
#> 4        Parent:Child 1, 36 0.01      0.09  .003    .763
#> 5       Parent:Months 2, 36 0.01 11.37 ***  .387   <.001
#> 6        Child:Months 2, 36 0.01      0.02 <.001    .982
#> 7 Parent:Child:Months 2, 36 0.01      0.00 <.001    .995
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '+' 0.1 ' ' 1




# 2. Plot the 3-way interaction plot. -------------------------------------

# There are many ways we can plot this 3-way data - we need to think what we
# want to convey to the reader - this will determine what we put on the x-axis,
# what will be plotted, etc.
afex_plot(fit, ~ Months, ~ Parent, ~ Child)





# 3. Conduct follow-up analysis -------------------------------------------
# on a significant 2-way interaction. Explain your results.

# Let's look at the Parent:Months interaction.
afex_plot(fit, ~ Months, ~ Parent)


# We can first look at the effect of `Months` conditional on `Parent`. That is,
# the simple effect for `Months` within each level of var `Parent`:
joint_tests(fit, by = "Parent")
#> Parent = 1:
#>  model term   df1 df2 F.ratio p.value
#>  Child          1  36   0.185 0.6698
#>  Months         2  36  27.857 <.0001
#>  Child:Months   2  36   0.020 0.9800
#>
#> Parent = 2:
#>  model term   df1 df2 F.ratio p.value
#>  Child          1  36   0.000 1.0000
#>  Months         2  36   3.628 0.0367
#>  Child:Months   2  36   0.002 0.9978

# Looks like the effect of `Months` is significant for both mothers and fathers.
# But the interaction tells us they are different some home. We will use
# contrast analysis to find exactly how.

em_int <- emmeans(fit, ~ Months + Parent)
em_int
#>  Months Parent emmean     SE df  lower.CL upper.CL
#>  7      1      0.0550 0.0269 36  0.000536   0.1095
#>  10     1      0.1075 0.0269 36  0.053036   0.1620
#>  13     1      0.3225 0.0269 36  0.268036   0.3770
#>  7      2      0.0338 0.0269 36 -0.020714   0.0882
#>  10     2      0.1325 0.0269 36  0.078036   0.1870
#>  13     2      0.1062 0.0269 36  0.051786   0.1607
#>
#> Results are averaged over the levels of: Child
#> Confidence level used: 0.95

# (Note the the CI of Fathers at 7 months goes below 0. Does this make sense?)


contrast(em_int, method = "poly", by = "Parent")
#> Parent = 1:
#>  contrast  estimate     SE df t.ratio p.value
#>  linear      0.2675 0.0380 36  7.043  <.0001
#>  quadratic   0.1625 0.0658 36  2.470  0.0184
#>
#> Parent = 2:
#>  contrast  estimate     SE df t.ratio p.value
#>  linear      0.0725 0.0380 36  1.909  0.0643
#>  quadratic  -0.1250 0.0658 36 -1.900  0.0654
#>
#> Results are averaged over the levels of: Child

# Looks like for mothers, there is both a positive linear and a positive
# quadratic trend - as the months pass, the proportion increases and this change
# gets larger.






# Note that we could have also looked at this the other way around - looking at
# the conditional effect of `Parent` by `Months`:
contrast(em_int, method = "pairwise", by = "Months")
#> Months = 7:
#>  contrast estimate    SE df t.ratio p.value
#>  1 - 2      0.0213 0.038 36  0.560  0.5793
#>
#> Months = 10:
#>  contrast estimate    SE df t.ratio p.value
#>  1 - 2     -0.0250 0.038 36 -0.658  0.5146
#>
#> Months = 13:
#>  contrast estimate    SE df t.ratio p.value
#>  1 - 2      0.2162 0.038 36  5.694  <.0001
#>
#> Results are averaged over the levels of: Child


# From which me learn that the difference between parents is small at 7 and 10
# months (a difference of on 2%), but is large at 13 months!
