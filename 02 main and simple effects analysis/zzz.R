library(marginaleffects)

mod <- lm(mpg ~ cyl * am, data = mtcars)

#' This works:

avg_predictions(
  mod,
  variables = c("cyl", "am"),
  hypothesis = ~ I(drop(t(cbind(c1 = c(-1, -1, 0), c2 = c(-1, -1, 2))) %*% x)) |
    am
)

#' But this doesn't - seems to be a scoping issue wrt `www`:

www <- cbind(c1 = c(-1, -1, 0), c2 = c(-1, -1, 2))

avg_predictions(
  mod,
  variables = c("cyl", "am"),
  hypothesis = ~ I(drop(t(www) %*% x)) | am
)


#' But no scoping issue with an arbitrary function?

wwwfun <- \(x) {
  drop(t(www) %*% x)
}

avg_predictions(
  mod,
  variables = c("cyl", "am"),
  hypothesis = ~ I(wwwfun(x)) | am
)
