
<img src='logo/Hex.png' align="right" height="139" />

# Analysis of Factorial Designs foR Psychologists

[![](https://img.shields.io/badge/Open%20Educational%20Resources-Compatable-brightgreen)](https://creativecommons.org/about/program-areas/education-oer/)
[![](https://img.shields.io/badge/CC-BY--NC%204.0-lightgray)](http://creativecommons.org/licenses/by-nc/4.0/)  
[![](https://img.shields.io/badge/Language-R-blue)](http://cran.r-project.org/)

<sub>*Last updated 2022-01-31.*</sub>

This Github repo contains all lesson files for *Analysis of Factorial
Designs foR Psychologists*. The goal is to impart students with the
basic tools to fit and evaluate **statistical models for factorial
designs (w/ plots) using [`afex`](https://afex.singmann.science/)**, and
and conduct **follow-up analyses (simple effects, planned contrasts,
post-hoc test; w/ plots) using
[`emmeans`](https://cran.r-project.org/package=emmeans)**. Although the
focus is on ANOVAs, the materials regarding follow-up analyses (\~80% of
the course) are applicable to linear mixed models, and even regression
with factorial predictors.

These topics were taught in the graduate-level course ***Analyses of
Variance*** (Psych Dep., Ben-Gurion University of the Negev, *Spring,
2019*). This course assumes basic competence in R (importing, regression
modeling, plotting, etc.), along the lines of [*Practical Applications
in R for
Psychologists*](https://github.com/mattansb/Practical-Applications-in-R-for-Psychologists).

**Notes:**

-   This repo contains only materials relating to *Practical
    Applications in R*, and does not contain any theoretical or
    introductory materials.  
-   Please note that some code does not work *on purpose*, to force
    students to learn to debug.

## Setup

You will need:

1.  A fresh installation of [**`R`**](https://cran.r-project.org/)
    (preferably version 4.1 or above).
2.  [RStudio IDE](https://www.rstudio.com/products/rstudio/download/)
    (optional, but recommended).
3.  The following packages, listed by lesson:

| Lesson                                                                                                  | Packages                                                                                                                                                                                                                                                                                                                                                                                                                          |
|---------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [01 ANOVA made easy](/01%20ANOVA%20made%20easy)                                                         | [**`afex`**](https://CRAN.R-project.org/package=afex), [**`emmeans`**](https://CRAN.R-project.org/package=emmeans), [**`effectsize`**](https://CRAN.R-project.org/package=effectsize), [**`ggeffects`**](https://CRAN.R-project.org/package=ggeffects), [**`tidyr`**](https://CRAN.R-project.org/package=tidyr)                                                                                                                   |
| [02 ANCOVA](/02%20ANCOVA)                                                                               | [`afex`](https://CRAN.R-project.org/package=afex)                                                                                                                                                                                                                                                                                                                                                                                 |
| [03 Main and simple effects analysis](/03%20Main%20and%20simple%20effects%20analysis)                   | [`afex`](https://CRAN.R-project.org/package=afex), [`emmeans`](https://CRAN.R-project.org/package=emmeans), [`ggeffects`](https://CRAN.R-project.org/package=ggeffects)                                                                                                                                                                                                                                                           |
| [04 Interaction analysis](/04%20Interaction%20analysis)                                                 | [`afex`](https://CRAN.R-project.org/package=afex), [`emmeans`](https://CRAN.R-project.org/package=emmeans), [`ggeffects`](https://CRAN.R-project.org/package=ggeffects)                                                                                                                                                                                                                                                           |
| [05 Effect sizes and multiple comparisons](/05%20Effect%20sizes%20and%20multiple%20comparisons)         | [`afex`](https://CRAN.R-project.org/package=afex), [`emmeans`](https://CRAN.R-project.org/package=emmeans), [`effectsize`](https://CRAN.R-project.org/package=effectsize)                                                                                                                                                                                                                                                         |
| [06 Assumption check and non-parametric tests](/06%20Assumption%20check%20and%20non-parametric%20tests) | [`afex`](https://CRAN.R-project.org/package=afex), [`ggeffects`](https://CRAN.R-project.org/package=ggeffects), [**`performance`**](https://CRAN.R-project.org/package=performance), [**`parameters`**](https://CRAN.R-project.org/package=parameters), [**`permuco`**](https://CRAN.R-project.org/package=permuco), [`emmeans`](https://CRAN.R-project.org/package=emmeans), [**`car`**](https://CRAN.R-project.org/package=car) |
| [07 Accepting nulls](/07%20Accepting%20nulls)                                                           | [`afex`](https://CRAN.R-project.org/package=afex), [`effectsize`](https://CRAN.R-project.org/package=effectsize), [**`lme4`**](https://CRAN.R-project.org/package=lme4), [**`bayestestR`**](https://CRAN.R-project.org/package=bayestestR), [`emmeans`](https://CRAN.R-project.org/package=emmeans), [**`dplyr`**](https://CRAN.R-project.org/package=dplyr)                                                                      |
| [08 ANOVA and (G)LMMs](/08%20ANOVA%20and%20(G)LMMs)                                                     | [`afex`](https://CRAN.R-project.org/package=afex), [**`patchwork`**](https://CRAN.R-project.org/package=patchwork), [`emmeans`](https://CRAN.R-project.org/package=emmeans)                                                                                                                                                                                                                                                       |

<sub>*(Bold denotes the first lesson in which the package was
used.)*</sub>

You can install all the packages used by running:

    # in alphabetical order:

    pkgs <- c(
      "afex", "bayestestR", "car", "dplyr", "effectsize", "emmeans",
      "ggeffects", "lme4", "parameters", "patchwork", "performance",
      "permuco", "tidyr"
    )

    install.packages(pkgs, repos = c("https://easystats.r-universe.dev", getOption("repos")))

<details>
<summary>
<i>Package Versions</i>
</summary>

Run on Windows 10 x64 (build 22000), with R version 4.1.1.

The packages used here:

-   `afex` 1.0-1 (*CRAN*)
-   `bayestestR` 0.11.5.1 (*Local version*)
-   `car` 3.0-12 (*CRAN*)
-   `dplyr` 1.0.7 (*CRAN*)
-   `effectsize` 0.4.5-4 (*Local version*)
-   `emmeans` 1.7.1-1 (*CRAN*)
-   `ggeffects` 1.1.1 (*CRAN*)
-   `lme4` 1.1-27.1 (*CRAN*)
-   `parameters` 0.16.0 (*CRAN*)
-   `patchwork` 1.1.1 (*CRAN*)
-   `performance` 0.8.0.1 (*<https://easystats.r-universe.dev>*)
-   `permuco` 1.1.1 (*CRAN*)
-   `tidyr` 1.1.4 (*CRAN*)

</details>
