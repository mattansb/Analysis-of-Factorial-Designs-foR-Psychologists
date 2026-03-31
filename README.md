

<img src='logo/Hex.png' align="right" height="139" />

# Analysis of Factorial Designs foR Psychologists

[![](https://img.shields.io/badge/Open%20Educational%20Resources-Compatable-brightgreen.png)](https://creativecommons.org/about/program-areas/education-oer/)
[![](https://img.shields.io/badge/CC-BY--NC%204.0-lightgray)](http://creativecommons.org/licenses/by-nc/4.0/)
[![](https://img.shields.io/badge/Language-R-blue.png)](http://cran.r-project.org/)

<sub>*Last updated 2026-03-31.*</sub>

This Github repo contains all lesson files for *Analysis of Factorial
Designs foR Psychologists*. The goal is to impart students with the
basic tools to fit and evaluate **statistical models for factorial
designs (w/ plots) using [`afex`](https://afex.singmann.science/)**, and
and conduct **follow-up analyses (simple effects, planned contrasts,
post-hoc test; w/ plots) using
[`emmeans`](https://cran.r-project.org/package=emmeans)**. Although the
focus is on ANOVAs, the materials regarding follow-up analyses (~80% of
the course) are applicable to [linear mixed
models](https://github.com/mattansb/Hierarchical-Linear-Models-foR-Psychologists),
and really any regression model with factorial predictors.

These topics were taught in the graduate-level course ***Analyses of
Variance*** (Psych Dep., Ben-Gurion University of the Negev, *Spring,
2019*). This course assumes basic competence in R (importing, regression
modeling, plotting, etc.), along the lines of [*Practical Applications
in R for
Psychologists*](https://github.com/mattansb/Practical-Applications-in-R-for-Psychologists).

**Notes:**

- This repo contains only materials relating to *Practical Applications
  in R*, and does not contain any theoretical or introductory materials.
- Please note that some code does not work *on purpose*, to force
  students to learn to debug.

## Setup

You will need:

1.  A fresh installation of [**`R`**](https://cran.r-project.org/)
    (preferably version 4.5 or above).
2.  [RStudio IDE](https://www.rstudio.com/products/rstudio/download/)
    (optional, but recommended).
3.  The following packages, listed by lesson:

| Lesson | Packages |
|:---|:---|
| [01 ANOVA made easy](01%20ANOVA%20made%20easy//) | `afex`, `effectsize`, `tidyr`, `datawizard` |
| [02 main and simple effects analysis](02%20main%20and%20simple%20effects%20analysis//) | `afex`, `emmeans` |
| [03 interaction analysis](03%20interaction%20analysis//) | `afex`, `emmeans`, `afex`, `emmeans` |
| [04 effect sizes](04%20effect%20sizes//) | `afex`, `emmeans`, `effectsize`, `dplyr` |
| [05 multiple comparisons](05%20multiple%20comparisons//) | `afex`, `emmeans` |
| [06 accepting the null](06%20accepting%20the%20null//) | `afex`, `lmerTest`, `effectsize`, `bayestestR`, `emmeans`, `dplyr` |
| [07 assumption check and non-parametric tests](07%20assumption%20check%20and%20non-parametric%20tests//) | `afex`, `ggeffects`, `performance`, `permuco` |
| [08 ANOVA vs (G)LMMs](08%20ANOVA%20vs%20(G)LMMs//) | `patchwork`, `afex`, `emmeans`, `lmerTest` |

<details>

<summary>

<i>Installing R Packages</i>
</summary>

You can install all the R packages used by running:

    # in alphabetical order:

    pak::pak(
      c(

        "cran::afex", # 1.5-1
        "cran::easystats", # 0.7.5
        "cran::emmeans", # 2.0.2
        "cran::ggeffects", # 2.3.2
        "cran::lmerTest", # 3.2-1
        "cran::patchwork", # 1.3.2
        "cran::permuco", # 1.1.3
        "cran::tidyverse" # 2.0.0

      )
    )

</details>
