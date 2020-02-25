residuals_qqplot <- function(object, model = c("univariate","multivariate")){
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("package ggplot2 is required.", call. = FALSE)
  }

  model <- match.arg(model)

  within <- names(attr(object,"within"))

  if (length(within) > 0L & model=="univariate") {
    ## make aov object
    data <- object$data$long
    id <- attr(object,'id')
    dv <- attr(object,'dv')
    terms <- as.formula(object$Anova)[-1]
    fixed <- paste0(terms, collapse = "+")
    error <- paste0("Error(",id,"/(",paste0(within,collapse = "*"),")",")")
    formula <- as.formula(paste0(dv,"~",fixed,"+",error))
    object_aov <- aov(formula,data)

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

  colnames(projections) <- c("Residuals","Error Term")

  # plot
  ggplot2::ggplot(projections,ggplot2::aes(sample = .data$Residuals)) +
    ggplot2::geom_qq() +
    ggplot2::geom_qq_line() +
    ggplot2::facet_wrap(~.data$"Error Term", scales = "free")
}
