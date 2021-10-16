
# What *is* ANOVA? --------------------------------------------------------

# First thing you need to know is what ANOVA is NOT:
# It is NOT a type of model.
# It is also NOT a special case of regression :O
# 
# ANOVA is a way of summarizing a model - any model - by presenting the results
# grouped by each term / effect in your model. These tables contain a test
# statistic (often F), which represents the combined significance of all the
# parameters associated with a term (sometimes called the omnibus test), often
# with an accompanying effect size.

# Lets look at some examples...

mtcars$cyl <- factor(mtcars$cyl)

m_mpg <- lm(mpg ~ hp + cyl, data = mtcars)
# This is a multiple regression model. We summarize the results with a table of
# coefficients:
summary(m_mpg)
# (Note that "cyl" has 2 parameters.)

# Or we can look at an ANOVA table:
anova(m_mpg)
# Note that "cyl" has 1 test with a df of 2 - the test represents the total
# significance of the two parameters combined! Thus, we can we see that these F
# tests are omnibus tests for all the parameters of a given term.


# Note that by default R uses calculates type 1 sums of squares (SS) - these are
# also called *sequential SS*, because each term's SS is calculated for its
# addition over the PREVIOUS terms - sequentially!
# So we can recreate the tests by building a sequence of models, and comparing
# them:
m_mpg0 <- lm(mpg ~ 1, data = mtcars)
m_mpg1 <- lm(mpg ~ hp, data = mtcars)

anova(m_mpg0, m_mpg1, m_mpg)
anova(m_mpg) # same SS values

# This also means that these two are different:
anova(lm(mpg ~ hp + cyl, data = mtcars))
anova(lm(mpg ~ cyl + hp, data = mtcars))
# Because the order of terms is different!







## Type 2 ----------------

# There are also type 2 SS - also called *simultaneous SS*, because the SS of
# each term is calculated for its addition over all other terms.
# We can use the Anova() function from the {car} package:
car::Anova(m_mpg, type = 2)

# So we can recreate the tests by building two sequence of models, and comparing
# them:
m_mpg_sans_cyl <- lm(mpg ~ hp, data = mtcars)
anova(m_mpg_sans_cyl, m_mpg) # Same SS as the type 2 test for cyl

m_mpg_sans_hp <- lm(mpg ~ cyl, data = mtcars)
anova(m_mpg_sans_hp, m_mpg) # Same SS as the type 2 test for hp

# Because the order of terms is usually of little importance, type 1 tests are
# rarely used in the analysis of factorial designs.










# When interaction are involved -------------------------------------------

# Type 2 SS treat interactions differently than main effects:

m_mpg_int <- lm(mpg ~ hp * cyl, data = mtcars)
# The SS of each main effect is calculated over all other main effects
# (simultaneously) *without* accounting for the interaction, while the SS of
# interaction terms are calculated over the underlying main effects
# (sequentially):
car::Anova(m_mpg_int, type = 2)

# Is the same as:
anova(m_mpg_sans_cyl, m_mpg) # Same SS as the type 2 test for cyl
anova(m_mpg_sans_hp, m_mpg)  # Same SS as the type 2 test for hp
anova(m_mpg, m_mpg_int)      # Same SS as the type 2 test for hp:cyl
# However, note that the tests statistics are different - this is because the
# error term used for all of the tests is the total error term of the full
# model.

# (If we have higher level interactions - say 3+-way interactions - each
# interaction level is tested *simultaneously*, with lower levels first,
# building up to the highest level *sequentially*.)




## Type 2 vs type 3 ------

# There is another type of simultaneous SS - the type 3 test, which does not
# treat interactions different then main effects - each main effect /
# interaction's SS is calculated for its addition over all other main effects
# AND interaction.
# 
# However, remember that we saw before that these methods actually produce
# omnibus tests for the combined effect of the *parameters of each term*. But in
# the `m_mpg_int` model the parameters labeled `hp`, `cyl6`, `cyl8` are no
# longer main effect parameters - they are simple effect parameters!
summary(m_mpg_int)
# - hp is the slope for the cyl=4 group
# - cyl6 is the different between cyl=4 and cyl=6 when hp=0
# - cyl8 is the different between cyl=4 and cyl=8 when hp=0

# We can see for example, that changing the reference group changes the test for hp:
mtcars$cyl <- relevel(mtcars$cyl, ref = "6")
m_mpg_int2 <- lm(mpg ~ hp*cyl, data = mtcars)

car::Anova(m_mpg_int, type = 3)
car::Anova(m_mpg_int2, type = 3)

# How can we resolve this?






## Centering -------------

# By centering our predictors - making 0 their mean, thus conditioning on 0
# means conditioning on their mean!
# For covariates this is easy enough
mtcars$hp <- mtcars$hp - mean(mtcars$hp)

# But how do we center a factor??
# The answer is - use some type of orthogonal coding, for example contr.sum()
# (effects coding). This makes the coefficients harder to interpret*, but we're
# not looking at those anyway!
contrasts(mtcars$cyl) <- contr.sum
# *You might instead you contr.helmert


# Now when looking at type 3 tests, the main effects actually are main effects!
m_mpg_int3 <- lm(mpg ~ hp*cyl, data = mtcars)
car::Anova(m_mpg_int3, type = 3)


# Remember: type 3 ANOVA tables make little sense without centering!




## Balanced data ---------

# This distinction between type 2 and type 3 SS is only relevant when there is
# some dependence between predictors (aka some collinearity).
# In our example, we can see that cyl and hp are linearity:
performance::r2(lm(hp ~ cyl, mtcars))

# In a factorial design, we might call this dependence / collinearity among our
# predictors an "unbalanced design", and when the predictors are completely
# independent we would call this a "balanced design".

# Let's look at two examples:

### Balanced data ----
A <- rep(letters[1:3], each = 4)
B <- rep(letters[1:2], times = 2 * 3)
y <- rnorm(12)

# We can see that the data is balanced:
table(A, B)
chisq.test(A, B)[1] # Chisq is exactly 0

m_balanced <- lm(y ~ A * B, 
                 contrasts = list(A = contr.sum, B = contr.sum))

car::Anova(m_balanced, type = 2)
car::Anova(m_balanced, type = 3)
# Both give identical results



### Unbalanced data ----


# When data is balanced the main effects of type 2 and 3 are identical

A[1] <- "c"
# We can see that the data is unbalanced:
table(A, B)
chisq.test(A, B)[1] # Chisq is no longer 0


m_balanced <- lm(y ~ A * B, 
                 contrasts = list(A = contr.sum, B = contr.sum))

car::Anova(m_balanced, type = 2)
car::Anova(m_balanced, type = 3)
# No longer give identical results for the main effects: close - but not
# identical, and as the deviation from the balance is larger, so will the
# difference between type 2 and 3 grow.


# Why does this happen?
# - Type 2 SS look as the SS between the means of A, across the levels of B. So
#   the mean of A1 is sum(A1)/n.
# - Type 3 SS however look as the SS between the means of A, weighted by
#   B. So the mean of A1 is (sum(A1B1)/n1 + sum(A1B2)/n2) / 2. This makes type 3
#   SS invariant to the cell frequencies.


# A lot has been said about type 2 vs type 3. I will not go into the weeds here, but
# it is important to note that 
# 1. Most statistical software (SAS, Stata, SPSS, ...) default to type 3 SS.
#   Langsrud, Ø. (2003). ANOVA for unbalanced data: Use Type II instead of Type III sums of squares. Statistics and Computing, 13(2), 163-167.
# 2. Often in factorial designs, any imbalance in the design is incidental, so
#   it is often beneficial to have a method that is invariant to such
#   imbalances. (Though this might not be true if the data is observational.)
# 3. Coefficient tables give results that are analogous to type 3 SS when all
#   terms are covariates:
m_covs <- lm(mpg ~ hp * disp, mtcars)
car::Anova(m_covs, type = 2)
car::Anova(m_covs, type = 3)
summary(m_covs) # same as type 3


# add as hidden?
#https://gist.github.com/mattansb/cad752ca5ec3f707a50cc726851416da



# Too much work -----------------------------------------------------------

# Making sure that our factors are using an orthogonal coding is a pain in the butt.
# Thankfully, we have the afex package which turns this:

data("mtcars")
mtcars$cyl <- factor(mtcars$cyl)
mtcars$am <- factor(mtcars$am)
contrasts(mtcars$cyl) <- contr.sum
contrasts(mtcars$am) <- contr.sum
m_lm <- lm(mpg ~ cyl * am, mtcars)
car::Anova(m_lm, type = 3)

# Into this:
data("mtcars")
mtcars$id <- seq_len(nrow(mtcars)) # identify rows
afex::aov_car(mpg ~ cyl * am + Error(id), data = mtcars)


# Other models ------------------------------------------------------------

# So far we've seen how ANOVAs are applied to linear OLS models. However the
# idea of omnibus tests per term can be extended to many other types of models.
# For models where SS cannot be calculated, there are deviance or likelihood
# analogous methods that are used instead (read more in the car::Anova docs):

mtcars$am <- factor(mtcars$am)
contrasts(mtcars$am) <- contr.sum

## GLM -------------------

# - ordinal
m_ordinal <- ordinal::clm(cyl ~ hp * am, data = mtcars)
car::Anova(m_ordinal, type = 2)
car::Anova(m_ordinal, type = 3)


# - logistic
m_logistic <- glm(am ~ cyl * hp, mtcars,
                  family = binomial())
car::Anova(m_logistic, type = 2)
car::Anova(m_logistic, type = 3)


# - poisson
m_poisson <- glm(gear ~ cyl * hp, mtcars,
                 family = poisson())
car::Anova(m_poisson, type = 2)
car::Anova(m_poisson, type = 3)


## (G)LMM ----------------
m_mixed <- lme4::lmer(mpg ~ cyl * hp + (cyl | gear), data = mtcars)
car::Anova(m_mixed, type = 2)
car::Anova(m_mixed, type = 3)


m_mixed2 <- lme4::glmer(am ~ cyl * hp + (1 | gear), data = mtcars,
                        family = binomial())
car::Anova(m_mixed2, type = 2)
car::Anova(m_mixed2, type = 3)


# What Even Are Words? ----------------------------------------------------

# Factorial designs are (usually experimental) designs in which all the
# predictors (independent variables) are categorical, and all possible
# combinations between the levels of the different categories are represented in
# the data (often in a balanced way).
#
# Summarizing models with an ANOVA table is so commonly paired with factorial
# designs, that the two have (wrongfully) become synonymous and ANOVAs are often
# seen as 'models' used to analyze factorial data. Although this is not true
# (one can present the results of the analysis of factorial data in a
# coefficients table, or, as we've seen, use ANOVA tables to summarize
# non-factorial data), we need to keep in mind what people expect when we talk
# about ANOVAs / factorial designs: 
# - ANOVAs are Gaussian models 
# - for analyzing between-, within-subject and mixed factorial data.
# - Using the maximal fixed effects (all main effects and all possible
#   interactions between them).


# So ANOVA is not a special case of regression. Is is a way of summarizing a
# model, as an alternative to coefficient ("regression") tables.


