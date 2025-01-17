skip_if_not_installed("marginaleffects", minimum_version = "0.9.0")
skip_if_not_installed("rstanarm")

test_that("marginaleffects()", {
  # Frequentist
  x <- lm(Sepal.Width ~ Species * Petal.Length, data = iris)
  model <- marginaleffects::slopes(x, newdata = insight::get_datagrid(x, at = "Species"), variables = "Petal.Length")
  expect_equal(nrow(parameters(model)), 1)

  # Bayesian
  x <- suppressWarnings(
    rstanarm::stan_glm(
      Sepal.Width ~ Species * Petal.Length,
      data = iris,
      refresh = 0,
      iter = 100,
      chains = 1
    )
  )
  model <- marginaleffects::slopes(x, newdata = insight::get_datagrid(x, at = "Species"), variables = "Petal.Length")
  expect_equal(nrow(parameters(model)), 1)
})


test_that("predictions()", {
  x <- lm(Sepal.Width ~ Species * Petal.Length, data = iris)
  p <- marginaleffects::avg_predictions(x, by = "Species")
  expect_equal(nrow(parameters(p)), 3)
})


test_that("comparisons()", {
  # Frequentist
  x <- lm(Sepal.Width ~ Species * Petal.Length, data = iris)
  m <- marginaleffects::comparisons(x, newdata = insight::get_datagrid(x, at = "Species"), variables = "Petal.Length")
  expect_equal(nrow(parameters(m)), 1)

  # Bayesian
  x <- suppressWarnings(
    rstanarm::stan_glm(
      Sepal.Width ~ Species * Petal.Length,
      data = iris,
      refresh = 0,
      iter = 100,
      chains = 1
    )
  )
  m <- marginaleffects::marginaleffects(
    x,
    newdata = insight::get_datagrid(x, at = "Species"),
    variables = "Petal.Length"
  )
  expect_equal(nrow(parameters(m)), 1)
})


test_that("marginalmeans()", {
  dat <- mtcars
  dat$cyl <- factor(dat$cyl)
  dat$gear <- factor(dat$gear)
  x <- lm(mpg ~ cyl + gear, data = dat)
  m <- marginaleffects::marginalmeans(x)
  expect_equal(nrow(parameters(m)), 6)
})


test_that("hypotheses()", {
  x <- lm(mpg ~ hp + wt, data = mtcars)
  m <- marginaleffects::hypotheses(x, "hp = wt")
  expect_equal(nrow(parameters(m)), 1)
})


test_that("multiple contrasts: Issue #779", {
  skip_if(getRversion() < "4.0.0")
  mod <- lm(mpg ~ as.factor(gear) * as.factor(cyl), data = mtcars)
  cmp <- suppressWarnings(marginaleffects::comparisons(
    mod,
    variables = c("gear", "cyl"),
    newdata = insight::get_datagrid(mod, at = c("gear", "cyl")),
    cross = TRUE
  ))
  cmp <- suppressWarnings(parameters(cmp))
  expect_true("Comparison: gear" %in% colnames(cmp))
  expect_true("Comparison: cyl" %in% colnames(cmp))
})
