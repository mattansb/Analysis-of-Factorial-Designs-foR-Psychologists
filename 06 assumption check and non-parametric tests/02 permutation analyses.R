library(permuco) # for permutations
citation("permuco")


# MUST do this!
options(contrasts = c('contr.sum', 'contr.poly'))

data(obk.long, package = "afex")

# Between-Subject Models --------------------------------------------------


fit_between_p <- aovperm(value ~ treatment * gender,
                         data = obk.long)
fit_between_p



# Within-Subject Models ---------------------------------------------------

# load data



fit_within_p <- aovperm(value ~ phase * hour + Error(id / (phase * hour)),
                        data = obk.long)
fit_within_p


# Mixed -------------------------------------------------------------------


fit_mixed_p <-aovperm(value ~ treatment * gender * phase * hour +
                        Error(id / (phase * hour)),
                      data = obk.long)
fit_mixed_p


# Read more ---------------------------------------------------------------

# https://davegiles.blogspot.com/2019/04/what-is-permutation-test.html

