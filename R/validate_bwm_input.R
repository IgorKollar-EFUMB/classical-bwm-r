#' Validate input data shared by the BWM implementations
#'
#' @param input A data frame with columns `criterion`, `best_to_others`, and
#'   `others_to_worst`.
#' @param comparison_scale Numeric vector containing the permitted modal
#'   comparison values. The default is the classical BWM scale 1--9.
#' @param require_integer Logical; if `TRUE`, comparison values must be integers.
#'
#' @return A validated list used internally by the solvers. Its
#'   `input_consistency` component contains the local and global input-based
#'   Consistency Ratios of Liang, Brunelli, and Rezaei (2020), the applicable
#'   published threshold, the acceptability assessment, and the criterion or
#'   tied criteria with the largest local discrepancy. For alpha-cut FBWM the
#'   input columns are the modal values of the fuzzy comparisons, so this same
#'   assessment is deliberately performed before fuzzification.
validate_bwm_input <- function(
    input,
    comparison_scale = 1:9,
    require_integer = TRUE
) {
  required_columns <- c(
    "criterion",
    "best_to_others",
    "others_to_worst"
  )

  if (!is.data.frame(input)) {
    stop("'input' must be a data frame.", call. = FALSE)
  }

  missing_columns <- setdiff(required_columns, names(input))
  if (length(missing_columns) > 0L) {
    stop(
      "Missing required input column(s): ",
      paste(missing_columns, collapse = ", "),
      ".",
      call. = FALSE
    )
  }

  input <- input[, required_columns, drop = FALSE]

  if (nrow(input) < 2L) {
    stop("At least two criteria are required.", call. = FALSE)
  }

  criteria <- as.character(input$criterion)
  if (anyNA(criteria) || any(trimws(criteria) == "")) {
    stop("Criterion names must not be missing or empty.", call. = FALSE)
  }
  if (anyDuplicated(criteria)) {
    stop("Criterion names must be unique.", call. = FALSE)
  }

  best_to_others <- input$best_to_others
  others_to_worst <- input$others_to_worst

  if (!is.numeric(best_to_others) || !is.numeric(others_to_worst)) {
    stop(
      "The comparison columns must contain numeric values.",
      call. = FALSE
    )
  }

  comparisons <- c(best_to_others, others_to_worst)
  if (anyNA(comparisons) || any(!is.finite(comparisons))) {
    stop("Comparison values must be finite and non-missing.", call. = FALSE)
  }

  if (require_integer && any(comparisons != round(comparisons))) {
    stop("Comparison values must be integers.", call. = FALSE)
  }

  if (any(!comparisons %in% comparison_scale)) {
    stop(
      "Comparison values must belong to the permitted scale: ",
      paste(comparison_scale, collapse = ", "),
      ".",
      call. = FALSE
    )
  }

  if (sum(best_to_others == 1) != 1L) {
    stop(
      "'best_to_others' must contain exactly one value equal to 1.",
      call. = FALSE
    )
  }
  if (sum(others_to_worst == 1) != 1L) {
    stop(
      "'others_to_worst' must contain exactly one value equal to 1.",
      call. = FALSE
    )
  }

  best_index <- which(best_to_others == 1)
  worst_index <- which(others_to_worst == 1)

  if (best_index == worst_index) {
    stop(
      "The best and worst criteria must be different.",
      call. = FALSE
    )
  }

  if (best_to_others[worst_index] != others_to_worst[best_index]) {
    stop(
      "The two direct best-to-worst comparisons must be equal: ",
      "best_to_others[worst] must equal others_to_worst[best].",
      call. = FALSE
    )
  }

  input_consistency <- .compute_bwm_input_consistency(
    criteria = criteria,
    best_to_others = as.numeric(best_to_others),
    others_to_worst = as.numeric(others_to_worst),
    worst_index = worst_index
  )

  input$criterion <- criteria

  list(
    data = input,
    criteria = criteria,
    best_to_others = as.numeric(best_to_others),
    others_to_worst = as.numeric(others_to_worst),
    best_index = best_index,
    worst_index = worst_index,
    best_criterion = criteria[best_index],
    worst_criterion = criteria[worst_index],
    n_criteria = length(criteria),
    input_consistency = input_consistency
  )
}

# Input-based BWM consistency thresholds from Liang, Brunelli, and Rezaei
# (2020), Table 3. Rows are the direct best-to-worst scale values a_BW and
# columns are the numbers of criteria. The paper states that the threshold for
# scale 2 is zero; thresholds for other combinations outside the table were
# not reported.
.bwm_input_consistency_thresholds <- function() {
  thresholds <- rbind(
    `2` = rep(0, 7),
    `3` = rep(0.1667, 7),
    `4` = c(0.1121, 0.1529, 0.1898, 0.2206, 0.2527, 0.2577, 0.2683),
    `5` = c(0.1354, 0.1994, 0.2306, 0.2546, 0.2716, 0.2844, 0.2960),
    `6` = c(0.1330, 0.1990, 0.2643, 0.3044, 0.3144, 0.3221, 0.3262),
    `7` = c(0.1294, 0.2457, 0.2819, 0.3029, 0.3144, 0.3251, 0.3403),
    `8` = c(0.1309, 0.2521, 0.2958, 0.3154, 0.3408, 0.3620, 0.3657),
    `9` = c(0.1359, 0.2681, 0.3062, 0.3337, 0.3517, 0.3620, 0.3662)
  )
  colnames(thresholds) <- as.character(3:9)
  thresholds
}

.compute_bwm_input_consistency <- function(
    criteria,
    best_to_others,
    others_to_worst,
    worst_index
) {
  n_criteria <- length(criteria)
  scale_value <- best_to_others[worst_index]

  denominator <- scale_value^2 - scale_value
  if (scale_value == 1) {
    local_ratio <- rep(0, n_criteria)
  } else {
    local_ratio <- abs(
      best_to_others * others_to_worst - scale_value
    ) / denominator
  }

  local <- data.frame(
    criterion = criteria,
    best_to_others = best_to_others,
    others_to_worst = others_to_worst,
    indirect_best_to_worst = best_to_others * others_to_worst,
    input_consistency_ratio = local_ratio,
    stringsAsFactors = FALSE,
    check.names = FALSE
  )

  global_ratio <- max(local_ratio)
  most_inconsistent <- if (global_ratio == 0) {
    character(0)
  } else {
    criteria[
      abs(local_ratio - global_ratio) <= sqrt(.Machine$double.eps)
    ]
  }

  thresholds <- .bwm_input_consistency_thresholds()
  threshold_available <-
    as.character(scale_value) %in% rownames(thresholds) &&
    as.character(n_criteria) %in% colnames(thresholds)

  threshold <- if (threshold_available) {
    unname(thresholds[
      as.character(scale_value),
      as.character(n_criteria)
    ])
  } else {
    NA_real_
  }

  # Perfect cardinal consistency can be identified without an empirical
  # threshold. Otherwise, acceptance is evaluated only where Table 3 applies.
  if (global_ratio == 0) {
    acceptable <- TRUE
    assessment <- "acceptable (perfectly consistent)"
  } else if (threshold_available) {
    acceptable <- global_ratio <= threshold
    assessment <- if (acceptable) {
      "acceptable"
    } else {
      "unacceptable; revise the input judgments"
    }
  } else {
    acceptable <- NA
    assessment <- paste0(
      "not assessed; Liang et al. (2020) report no threshold for ",
      n_criteria,
      " criteria and scale ",
      format(scale_value, trim = TRUE),
      "."
    )
  }

  list(
    method = "Input-based Consistency Ratio (Liang et al., 2020)",
    ratio = global_ratio,
    threshold = threshold,
    threshold_available = threshold_available,
    acceptable = acceptable,
    assessment = assessment,
    n_criteria = n_criteria,
    scale_value = scale_value,
    best_to_worst = scale_value,
    most_inconsistent_criteria = most_inconsistent,
    by_criterion = local
  )
}
