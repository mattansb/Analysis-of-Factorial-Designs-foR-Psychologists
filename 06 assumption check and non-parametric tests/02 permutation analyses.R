library(afex)
library(permuco) # for permutations
citation("permuco")


# must do this!
options(contrasts = c('contr.sum', 'contr.poly'))


# Between-Subject Models --------------------------------------------------

# load data
obk_between <- readRDS("obk_between.rds")

# regualr anova
fit_between <- aov_ez('id', 'value', obk_between,
                      between = c('treatment', 'gender'))
fit_between

# permutation anova
fit_between_p <- aovperm(value ~ treatment * gender,
                         data = obk_between)
fit_between_p



# Within-Subject Models ---------------------------------------------------

# load data
obk_within <- readRDS("obk_within.rds")

# regualr anova
fit_within <- aov_ez('id', 'value', obk_within,
                     within = c('phase', 'hour'))
fit_within

# permutation anova
fit_within_p <- aovperm(value ~ phase * hour + Error(id / (phase * hour)),
                        data = obk_within)
fit_within_p


# Mixed -------------------------------------------------------------------

# load data
data(obk.long, package = "afex")


# regualr anova
fit_mixed <- aov_ez('id', 'value', obk.long,
                    between = c('treatment', 'gender'),
                    within = c('phase', 'hour'))
fit_mixed

# permutation anova
fit_mixed_p <-aovperm(value ~ treatment * gender * phase * hour +
                        Error(id / (phase * hour)),
                      data = obk.long)
fit_mixed_p


# Read more ---------------------------------------------------------------

# https://davegiles.blogspot.com/2019/04/what-is-permutation-test.html

