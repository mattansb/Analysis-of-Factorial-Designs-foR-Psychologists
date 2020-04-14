residuals_qqplot <- function(object, model = c("univariate", "multivariate"), qqbands = TRUE){
  stopifnot(requireNamespace("ggplot2"))

  if (qqbands && requireNamespace("qqplotr")) {
    qq_stuff <- list(qqplotr::stat_qq_band(),
                     qqplotr::stat_qq_line(),
                     qqplotr::stat_qq_point())

  } else {
    qq_stuff <- list(ggplot2::stat_qq(),
                     ggplot2::stat_qq_line())
  }

  model <- match.arg(model)

  data <- object$data$long
  within <- names(attr(object, "within"))
  id <- attr(object, 'id')


  if (length(within) > 0L & model == "univariate") {
    object_aov <- object$aov

    if (is.null(object_aov)) {
      ## make aov object
      print("AA")
      dv <- attr(object, 'dv')
      terms <- as.formula(object$Anova)[-1]
      fixed <- paste0(terms, collapse = "+")
      error <-
        paste0("Error(", id, "/(", paste0(within, collapse = "*"), ")", ")")
      formula <- as.formula(paste0(dv, "~", fixed, "+", error))
      object_aov <- aov(formula, data)
    }

    projections <- proj(object_aov)[-1]
    projections <- lapply(projections, function(.x) {
      temp_data <- data.frame(id = data[[id]],
                              resid = as.data.frame(.x)$Residuals)
      unique(temp_data)[[2]]
    })
    projections <- stack(projections, )
  } else if (length(within) > 0L) {
    resid <- data.frame(residuals(object$lm))
    projections <- stack(resid)
  } else {
    projections <- data.frame(residuals(object$lm), id)
  }

  colnames(projections) <- c("Residuals", "Term")

  ggplot2::ggplot(projections, ggplot2::aes(sample = .data$Residuals)) +
    qq_stuff +
    ggplot2::facet_wrap( ~ .data$Term, scales = "free", ) +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      axis.text.x = ggplot2::element_blank(),
      axis.ticks.x = ggplot2::element_blank(),
      axis.text.y = ggplot2::element_blank(),
      axis.ticks.y = ggplot2::element_blank()
    ) +
    ggplot2::labs(x = "Theoretical",
                  y = "Sample")
}
