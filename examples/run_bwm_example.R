# Run this script from the repository root.

source(file.path("R", "validate_bwm_input.R"))
source(file.path("R", "solve_bwm.R"))

input <- read.csv(
  file.path("data", "bwm_example.csv"),
  stringsAsFactors = FALSE
)

result <- solve_bwm(input)

cat("Method: ", result$method, "\n", sep = "")
cat("Best criterion: ", result$best_criterion, "\n", sep = "")
cat("Worst criterion: ", result$worst_criterion, "\n", sep = "")

critical_criteria <- result$input_consistency$most_inconsistent_criteria
critical_label <- if (length(critical_criteria) == 0L) {
  "none (all local ratios are zero)"
} else {
  paste(critical_criteria, collapse = ", ")
}

cat("\nInput-based consistency assessment\n")
cat(
  "CRI: ",
  format(result$input_consistency$ratio, digits = 6),
  "\nThreshold: ",
  format(result$input_consistency$threshold, digits = 6),
  "\nAssessment: ",
  result$input_consistency$assessment,
  "\nCritical criterion(s): ",
  critical_label,
  "\n",
  sep = ""
)

cat("\nLinear BWM diagnostics\n")
cat(
  "Optimal maximum absolute deviation (xi): ",
  format(result$deviation, digits = 10),
  "\n\n",
  sep = ""
)

cat("Criterion weights\n")
print(result$ranking, digits = 8, row.names = FALSE)
cat("\nSum of weights: ", sum(result$weights$weight), "\n", sep = "")

cat("\nLocal input-based consistency ratios\n")
print(
  result$input_consistency$by_criterion,
  digits = 8,
  row.names = FALSE
)

# Optional export:
# write.csv(result$weights, "bwm_results.csv", row.names = FALSE)
