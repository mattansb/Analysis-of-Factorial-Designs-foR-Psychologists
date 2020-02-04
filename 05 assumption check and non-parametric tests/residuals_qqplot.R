residuals_qqplot <- function(object){
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("package ggplot2 is required.", call. = FALSE)
  }

  data <- object$data$long
  id <- attr(object,'id')
  dv <- attr(object,'dv')
  within <- names(attr(object,"within"))

  if (length(within)>0) {
    formula <- as.formula(object$Anova)[-1]
    formula <- paste0(formula, collapse = "+")
    formula_error <- paste0("Error(",id,"/(",paste0(within,collapse = "*"),")",")")
    formula <- paste0(c(formula,formula_error), collapse = "+")
    formula <- as.formula(paste0(dv,"~",formula))
    object_aov <- aov(formula,data)

    projections <- proj(object_aov)[-1]
    projections <- lapply(projections, function(.x) {
      temp_data <- data
      temp_data$Residuals <- as.data.frame(.x)$Residuals
      temp_data <- unique(temp_data[,c(id,"Residuals")])
      temp_data$Residuals
    })
    projections <- stack(projections, )
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
