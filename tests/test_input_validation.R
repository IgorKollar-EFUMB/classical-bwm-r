valid_input <- read.csv(
  file.path("data", "bwm_example.csv"),
  stringsAsFactors = FALSE
)

validated <- validate_bwm_input(valid_input)
stopifnot(validated$best_criterion == "C1")
stopifnot(validated$worst_criterion == "C9")
stopifnot(abs(validated$input_consistency$ratio - 2 / 9) < 1e-12)
stopifnot(abs(validated$input_consistency$threshold - 0.3662) < 1e-12)
stopifnot(isTRUE(validated$input_consistency$acceptable))
stopifnot(validated$input_consistency$scale_value == 9)
stopifnot(identical(
  validated$input_consistency$most_inconsistent_criteria,
  "C4"
))
stopifnot(nrow(validated$input_consistency$by_criterion) == nrow(valid_input))

unacceptable_input <- data.frame(
  criterion = paste0("C", 1:5),
  best_to_others = c(3, 1, 3, 2, 6),
  others_to_worst = c(2, 6, 6, 3, 1),
  stringsAsFactors = FALSE
)
unacceptable <- validate_bwm_input(unacceptable_input)$input_consistency
stopifnot(abs(unacceptable$ratio - 0.4) < 1e-12)
stopifnot(abs(unacceptable$threshold - 0.2643) < 1e-12)
stopifnot(identical(unacceptable$acceptable, FALSE))

perfect_input <- data.frame(
  criterion = c("Best", "Middle", "Worst"),
  best_to_others = c(1, 2, 4),
  others_to_worst = c(4, 2, 1),
  stringsAsFactors = FALSE
)
perfect <- validate_bwm_input(perfect_input)$input_consistency
stopifnot(perfect$ratio == 0)
stopifnot(isTRUE(perfect$acceptable))

expect_error <- function(expression) {
  error_was_raised <- FALSE
  tryCatch(
    force(expression),
    error = function(error) {
      error_was_raised <<- TRUE
    }
  )
  if (!error_was_raised) {
    stop("Expected an error, but the expression completed successfully.")
  }
}

invalid_input <- valid_input
invalid_input$criterion[2] <- invalid_input$criterion[1]
expect_error(validate_bwm_input(invalid_input))

invalid_input <- valid_input
invalid_input$others_to_worst[1] <- 8
expect_error(validate_bwm_input(invalid_input))

invalid_input <- valid_input
invalid_input$best_to_others[3] <- 10
expect_error(validate_bwm_input(invalid_input))
