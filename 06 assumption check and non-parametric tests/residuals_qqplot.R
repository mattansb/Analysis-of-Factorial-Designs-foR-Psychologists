residuals.afex_aov <- function(object, append = FALSE, ...) {
  if (length(attr(object, "within")) > 0) {
    # residuals in long format
    e <- data.frame(residuals(object$lm))
    varying <- colnames(e)
    e[attr(object, "id")] <- object$data$wide[attr(object, "id")]
    e <- reshape(
      e,
      direction = "long",
      varying = varying,
      v.name = ".residuals.",
      times = varying,
      timevar = ".time.",
      idvar = attr(object, "id")
    )

    # add within data
    code <- data.frame(.time. = varying,
                       .index. = seq_along(varying))
    index <- object$data$idata
    index$.index. <- seq_len(nrow(index))
    index <- merge(code, index, by = ".index.")

    e <- merge(e, index, by = ".time.")
    e$.time. <- NULL
    e$.index. <- NULL

    # add between data
    between_data <- object$data$long
    e <- merge(between_data, e, by = c(attr(object, "id"), names(attr(object, "within"))))
  } else {
    e <- object$data$long
    e$.residuals. <- residuals(object$lm)
  }

  e[[attr(object, "dv")]] <- NULL

  if (append) {
    return(e)
  } else {
    e$.residuals.
  }
}


residuals_qqplot <- function(object, by_term = FALSE, model = c("univariate", "multivariate"), qqbands = TRUE, return = c("plot", "data")){
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
  return <- match.arg(return)

  within <- names(attr(object, "within"))
  id <- attr(object, 'id')

  e <- residuals(object, append = TRUE)

  if (!by_term) {
    e$term <- "residuals"
  } else if (length(within) > 0L & model == "univariate") {
    wf <- lapply(within, function(x) c(NA, x))
    wf <- do.call(expand.grid, wf)
    wl <- apply(wf, 1, function(x) c(na.omit(x)))

    fin_e <- vector("list", length = length(wl))
    for (i in seq_along(wl)) {
      temp_f <- c(id, wl[[i]])

      temp_e <- aggregate(e$.residuals., e[, temp_f, drop = F], FUN = mean)

      fin_e[[i]] <- data.frame(
        term = paste0(temp_f, collapse = ":"),
        .residuals. = temp_e[[ncol(temp_e)]]
      )
    }
    e <- do.call(rbind, fin_e)
  } else if (length(within) > 0L) {
    e$term <- apply(e[, within], 1, function(x) paste0(x, collapse = "/"))
  } else {
    e$term <- id
  }

  if (return == "data") {
    return(e[,c("term",".residuals.")])
  }

  ggplot2::ggplot(e, ggplot2::aes(sample = .data$.residuals.)) +
    qq_stuff +
    ggplot2::facet_wrap(~ .data$term, scales = "free") +
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
