#' Solve the linear Best-Worst Method model
#'
#' This function implements the linear BWM formulation described by Rezaei.
#' It minimizes the maximum absolute deviation from the Best-to-Others and
#' Others-to-Worst preference relations.
#'
#' @param input A data frame with columns `criterion`, `best_to_others`, and
#'   `others_to_worst`.
#'
#' @return An object of class `bwm_result` containing criteria weights, the
#'   input-based consistency assessment, optimal deviation, solver status, and
#'   model metadata. Both `weights` and `ranking` contain exactly the columns
#'   `criterion`, `weight`, and `rank`. The optimal linear-model deviation
#'   `deviation` is not a Consistency Ratio and must not be compared with the
#'   published input-based consistency threshold.
solve_bwm <- function(input) {
  if (!exists("validate_bwm_input", mode = "function")) {
    stop(
      "Function 'validate_bwm_input()' is not available. ",
      "Source 'R/validate_bwm_input.R' first.",
      call. = FALSE
    )
  }
  if (!requireNamespace("lpSolve", quietly = TRUE)) {
    stop(
      "Package 'lpSolve' is required. Install it with ",
      "install.packages('lpSolve').",
      call. = FALSE
    )
  }

  validated <- validate_bwm_input(input)
  n <- validated$n_criteria
  best_index <- validated$best_index
  worst_index <- validated$worst_index
  best_to_others <- validated$best_to_others
  others_to_worst <- validated$others_to_worst

  deviation_index <- n + 1L
  objective <- c(rep(0, n), 1)
  constraints <- list()
  directions <- character(0)
  rhs <- numeric(0)

  add_constraint <- function(coefficients, direction = "<=", value = 0) {
    constraints[[length(constraints) + 1L]] <<- coefficients
    directions <<- c(directions, direction)
    rhs <<- c(rhs, value)
  }

  for (j in seq_len(n)) {
    # |w_B - a_Bj * w_j| <= xi
    coefficients <- numeric(n + 1L)
    coefficients[best_index] <- coefficients[best_index] + 1
    coefficients[j] <- coefficients[j] - best_to_others[j]
    coefficients[deviation_index] <- -1
    add_constraint(coefficients)

    coefficients <- numeric(n + 1L)
    coefficients[best_index] <- coefficients[best_index] - 1
    coefficients[j] <- coefficients[j] + best_to_others[j]
    coefficients[deviation_index] <- -1
    add_constraint(coefficients)

    # |w_j - a_jW * w_W| <= xi
    coefficients <- numeric(n + 1L)
    coefficients[j] <- coefficients[j] + 1
    coefficients[worst_index] <-
      coefficients[worst_index] - others_to_worst[j]
    coefficients[deviation_index] <- -1
    add_constraint(coefficients)

    coefficients <- numeric(n + 1L)
    coefficients[j] <- coefficients[j] - 1
    coefficients[worst_index] <-
      coefficients[worst_index] + others_to_worst[j]
    coefficients[deviation_index] <- -1
    add_constraint(coefficients)
  }

  normalization <- c(rep(1, n), 0)
  add_constraint(normalization, "=", 1)

  model <- lpSolve::lp(
    direction = "min",
    objective.in = objective,
    const.mat = do.call(rbind, constraints),
    const.dir = directions,
    const.rhs = rhs
  )

  if (model$status != 0L) {
    stop(
      "The linear BWM model was not solved optimally. lpSolve status: ",
      model$status,
      ".",
      call. = FALSE
    )
  }

  weight_values <- model$solution[seq_len(n)]
  weights <- data.frame(
    criterion = validated$criteria,
    weight = weight_values,
    rank = rank(-weight_values, ties.method = "min"),
    stringsAsFactors = FALSE,
    check.names = FALSE
  )

  ranking <- weights[order(weights$rank, weights$criterion), , drop = FALSE]
  row.names(ranking) <- NULL

  result <- list(
    method = "Linear Best-Worst Method",
    weights = weights,
    ranking = ranking,
    deviation = model$solution[deviation_index],
    objective_value = model$objval,
    input_consistency = validated$input_consistency,
    best_criterion = validated$best_criterion,
    worst_criterion = validated$worst_criterion,
    solver = "lpSolve",
    solver_status = model$status,
    input = validated$data
  )
  class(result) <- c("bwm_result", "list")
  result
}
