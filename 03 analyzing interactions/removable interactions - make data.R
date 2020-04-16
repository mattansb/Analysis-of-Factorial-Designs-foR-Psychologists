library(dplyr)

set.seed(2)

group <- c("dyslexia", "control")
cond <- c("congruent", "incongruent")
Ss <- 20
mu <- c(620,800,250,300)
e <- scale(rnorm(Ss))*100

df <- expand.grid(condition = cond, Group = group) %>%
  mutate(mu) %>%
  group_by(Group, condition) %>%
  summarise(mRT = (mu + sample(e)) / 1000) %>%
  group_by(condition) %>%
  mutate(id = seq_len(Ss * 2)) %>%
  ungroup()

saveRDS(df, "dyslexia_stroop.rds")



