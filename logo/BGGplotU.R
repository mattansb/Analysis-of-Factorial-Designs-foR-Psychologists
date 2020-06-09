library(hexSticker)
library(tidyverse)
library(afex)

# Hex ---------------------------------------------------------------------

data(md_12.1)
fit <- aov_ez("id", "rt", md_12.1, within = c("angle", "noise"), 
              anova_table=list(correction = "none", es = "none"))
p_dat <- afex_plot(fit, ~angle, ~noise, return = "data", error = "within")

p_r <- ggplot(p_dat$means, aes(angle, y, color = noise, shape = noise)) + 
  ggbeeswarm::geom_beeswarm(data = p_dat$data, aes(x = angle, group = noise),
                            dodge.width = 0.3, color = "black", alpha = 0.7,
                            shape = 16, size = 0.5) +
  geom_violin(data = p_dat$data, trim = F, color = NA, fill = "black", position = position_dodge(0.3), alpha = 0.4) + 
  # geom_errorbar(aes(ymin = lower.CL, ymax = upper.CL), width = 0.2, position = position_dodge(0.3), color = "black") +
  geom_point(position = position_dodge(0.3), size = 2) + 
  geom_line(aes(group = noise), position = position_dodge(0.3), size = 1) + 
  
  theme_void() +
  theme_transparent() +
  theme(legend.position = "none") +
  scale_color_brewer(type = "qual", palette = 6) + 
  NULL


sticker(p_r, package="ANOVA - Practical Applications in R",
        filename = "BGUHex.png",
        s_x = 1, s_y = 0.9, s_width = 2, s_height = 1.2,
        p_color = "white", p_size = 8,
        h_color = "grey", h_fill = "orange",
        spotlight = TRUE, l_y = 1.2)

# Panel -------------------------------------------------------------------

df <- rbind(data.frame(x = c(0, 0, 1,   0.5,  0, -0.5, -1, -0.5),
                       y = c(-0.4, 1, 1.5, 2.5,  3, 2, 1.5, 1),
                       group = "main"),
            data.frame(x = c(-.7, -0.5,-0.5) - 0.2,
                       y = c(-0.4, 0.5,0.75),
                       group = "left"),
            data.frame(x = -c(-.7, -0.5,-0.6) + 0.2,
                       y = c(-0.4, 0.5,0.75),
                       group = "right"))

ggplot(df, aes(x,y, group = group)) +
  geom_path(color = "white", size = 10) +
  theme(panel.background = element_rect(fill = "orange")) +
  coord_cartesian(xlim = c(-5,5), ylim = c(-0.5, 3.5))


# Hex ---------------------------------------------------------------------
# 
# hex_p <- ggplot(df, aes(x,y, group = group)) +
#   geom_path(color = "white", size = 2) +
#   theme_transparent() +
#   coord_cartesian(xlim = c(-4,4), ylim = c(-0.5, 3.1))
# 
# sticker(hex_p, package="ARMP - Practical Applications in R",
#         filename = "BGUHex.png",
#         s_x = 0.9, s_y = 0.8, s_width = 1.6, s_height = 1.2,
#         p_color = "white", p_size = 8,
#         h_color = "grey", h_fill = "orange",
#         spotlight = TRUE, l_y = 1.2)
