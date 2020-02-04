
<img src='logo/BGUHex.png' align="right" height="139" />

# Analysis of Factorial Designs foR Psychologists

<sub>*Last updated 2020-02-04.*</sub>

This Github repo contains all lesson files used in the graduate-level
course: *Analysis of Factorial Designs foR Psychologists - Practical
Applications in R*, taught at Ben-Gurion University on the Negev (spring
2019 semester).

The goal is to impart students with the basic tools to fit and evaluate
statistical models for factorial designs (w/ plots) using
[**`afex`**](https://afex.singmann.science/), and and conduct follow-up
analyses (simple effects, planned contrasts, post-hoc test; w/ plots)
using [**`emmeans`**](https://cran.r-project.org/package=emmeans). This
course assumes basic competence in R (importing, regression modeling,
plotting, etc.), a long the lines of the prerequisite course, *Advanced
Research Methods foR Psychologists*, which can be found
[here](https://github.com/mattansb/Advanced-Research-Methods-foR-Psychologists).

**Notes:**

  - Although the focus is on ANOVAs, the matrials regarding follow-up
    analyses (\~80% of the course) is fit for linear mixed models, and
    even regression for factorial predictors.
  - This repo contains only materials relating to *Practical
    Applications in R*, and does not contain any theoretical or
    introductory materials.  
  - Please note that some code does not work *on purpose*, to force
    students to learn to debug.

## Setup

You will need:

1.  A fresh installation of [**`R`**](https://cran.r-project.org/)
    (preferably version 3.6 or above).
2.  [RStudio](https://www.rstudio.com/products/rstudio/download/)
    (optional - but I recommend using an IDE).
3.  The following packages, listed by lesson:

| Lesson                                                                                                  | Packages                                                   |
| ------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------- |
| [01 ANOVA made easy](/01%20ANOVA%20made%20easy)                                                         | `tidyr`, `afex`, `emmeans`, `ggplot2`, `car`               |
| [02 interactions and simple effects](/02%20interactions%20and%20simple%20effects)                       | `dplyr`, `afex`, `emmeans`, `AMCP`                         |
| [03 interaction contrasts](/03%20interaction%20contrasts)                                               | `dplyr`, `afex`, `emmeans`                                 |
| [04 custom contrasts and effect sizes](/04%20custom%20contrasts%20and%20effect%20sizes)                 | `afex`, `emmeans`, `effectsize`, `dplyr`                   |
| [05 assumption check and non-parametric tests](/05%20assumption%20check%20and%20non-parametric%20tests) | `afex`, `permuco`, `emmeans`, `car`, `lmerTest`, `ggplot2` |
| [06 multiple comparisons and Bayesian ANOVA](/06%20multiple%20comparisons%20and%20Bayesian%20ANOVA)     | `dplyr`, `afex`, `BayesFactor`, `bayestestR`, `emmeans`    |
| [07 ANCOVA](/07%20ANCOVA)                                                                               | `afex`                                                     |

You can install all the packages used by running:

    # in alphabetical order:

    pkgs <- c(
      "afex", "AMCP", "BayesFactor", "bayestestR", "car", "dplyr",
      "effectsize", "emmeans", "ggplot2", "lmerTest", "permuco", "tidyr"
    )

``` r
install.packages(pkgs, dependencies = TRUE)
```

The package versions used here:

    ##         afex         AMCP  BayesFactor   bayestestR          car        dplyr 
    ##     "0.26-0"      "0.0.4" "0.9.12-4.2"      "0.5.1"      "3.0-6"      "0.8.4" 
    ##   effectsize      emmeans      ggplot2     lmerTest      permuco        tidyr 
    ##      "0.1.1"      "1.4.4"      "3.2.1"      "3.1-1"      "1.1.0"      "1.0.2"
