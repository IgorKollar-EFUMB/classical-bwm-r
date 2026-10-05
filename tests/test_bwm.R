input <- read.csv(
  file.path("data", "bwm_example.csv"),
  stringsAsFactors = FALSE
)
result <- solve_bwm(input)

expected_weights <- c(
  0.31463748,
  0.19151847,
  0.06383949,
  0.07660739,
  0.05471956,
  0.09575923,
  0.04787962,
  0.12767898,
  0.02735978
)

expected_weight_columns <- c("criterion", "weight", "rank")
stopifnot(identical(names(result$weights), expected_weight_columns))
stopifnot(identical(names(result$ranking), expected_weight_columns))
stopifnot(abs(sum(result$weights$weight) - 1) < 1e-8)
stopifnot(all(result$weights$weight >= 0))
stopifnot(max(abs(result$weights$weight - expected_weights)) < 1e-6)
stopifnot(result$best_criterion == "C1")
stopifnot(result$worst_criterion == "C9")
stopifnot(result$weights$rank[result$weights$criterion == "C1"] == 1)
stopifnot(isTRUE(result$input_consistency$acceptable))
stopifnot(abs(result$input_consistency$ratio - 2 / 9) < 1e-12)
stopifnot(abs(result$input_consistency$threshold - 0.3662) < 1e-12)
