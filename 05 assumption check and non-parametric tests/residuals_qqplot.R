residuals_qqplot <- function(object, model = c("univariate","multivariate"), qqbands = TRUE){
  stopifnot(requireNamespace("patchwork"),
            requireNamespace("ggplot2"),
            requireNamespace("qqplotr"))

  model <- match.arg(model)

  data <- object$data$long
  within <- names(attr(object,"within"))
  id <- attr(object,'id')


  if (length(within) > 0L & model=="univariate") {
    object_aov <- object$aov

    if (is.null(object_aov)) {
      ## make aov object
      print("AA")
      dv <- attr(object,'dv')
      terms <- as.formula(object$Anova)[-1]
      fixed <- paste0(terms, collapse = "+")
      error <- paste0("Error(",id,"/(",paste0(within,collapse = "*"),")",")")
      formula <- as.formula(paste0(dv,"~",fixed,"+",error))
      object_aov <- aov(formula,data)
    }

    projections <- proj(object_aov)[-1]
    projections <- lapply(projections, function(.x) {
      temp_data <- data.frame(
        id = data[[id]],
        resid = as.data.frame(.x)$Residuals
      )
      unique(temp_data)[[2]]
    })
    projections <- stack(projections, )
  } else if (length(within) > 0L) {
    resid <- data.frame(residuals(object$lm))
    projections <- stack(resid)
  } else {
    projections <- data.frame(residuals(object$lm),id)
  }

  colnames(projections) <- c("Residuals","Term")

  resids <- split(projections, projections$Term)
  gg_resids <- lapply(resids, function(.e) {
    ggplot2::ggplot(mapping = ggplot2::aes(sample = .e$Residuals)) +
      qqplotr::stat_qq_band() +
      qqplotr::stat_qq_line() +
      qqplotr::stat_qq_point() +
      ggplot2::theme_minimal() +
      ggplot2::theme(
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks.y = element_blank()
      ) +
      ggplot2::labs(title = .e$Term[1],
                    x = "",
                    y = "")
  })

  gg_resids[[1]] <- gg_resids[[1]] +
    ggplot2::labs(x = "Theoretical",
                  y = "Sample")

  patchwork::wrap_plots(gg_resids)
}
