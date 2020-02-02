library(tidyverse)


# Long vs. wide data ------------------------------------------------------

angle_noise <- read.csv('angle-noise_wide.csv')


# WIDE DATA has a row for each subject,
# between-subject variables have a column,
# but within-subject variables are spread across columns.
head(angle_noise)










# LONG DATA (also known as 'tidy data'), has one row per
# each OBSERVATION, and a colmn for each variable
# (including the subject ID!)

long_angle_noise <- angle_noise %>%
  gather('angle','rt',angle_0,angle_4,angle_8)

head(long_angle_noise)






# 2-way ANOVA -------------------------------------------------------------

library(afex)
options(afex.emmeans_model = 'multivariate')
(fit <- aov_ez('id','rt',long_angle_noise,
               between = 'noise', within = c('angle')))
?aov_ez









fit <- aov_ez('id','rt',long_angle_noise,
              between = 'noise', within = 'angle',
              anova_table = list(es = 'pes'))
fit






# Simple effects ----------------------------------------------------------

library(emmeans)

joint_tests(fit)


joint_tests(fit, by = 'noise')


joint_tests(fit, by = 'angle')

emmeans(fit,~angle)

# Plot the data -----------------------------------------------------------

# simple plotting function
emmip(fit,noise~angle)







# add 95% confidence intervals
emmip(fit,noise~angle, CIs = TRUE)
emmip(fit,~angle, CIs = TRUE)
emmip(fit,~noise, CIs = TRUE)









afex_plot(fit,~angle,~noise)
?afex_plot









emmeans(fit,~noise+angle) %>%
  confint() %>%
  # basic plot
  ggplot(aes(angle,emmean,fill = noise, group = noise)) +
  geom_col(width = .7, position = position_dodge(.8), color = 'black') +
  geom_point(position = position_dodge(.8)) +
  geom_errorbar(aes(ymin = lower.CL, ymax = upper.CL), width = .1,position = position_dodge(.8)) +
  # make pretty
  labs(x = 'Angle',y = 'Mean RT', fill = 'Noise') +
  scale_fill_manual(values = c('gray','red3')) +
  scale_x_discrete(labels = c(0,4,8)) +
  coord_cartesian(ylim = c(420,820)) +
  theme_bw() +
  theme(legend.position = 'bottom')


# Contrasts? --------------------------------------------------------------

# if there's time...
em_angle <- emmeans(fit,~angle)
em_angle

contrast(em_angle,"poly")
c_angle <- contrast(em_angle,"pairwise")
c_angle
?`contrast-methods`

contrast(c_angle,"pairwise")

emmip(c_angle,~contrast, CIs = TRUE)
