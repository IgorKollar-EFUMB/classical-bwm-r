# Standard workflow for user-defined Classical BWM data.
# Keep this template; copy it to examples/run_my_analysis.R.
# Run the copy from the repository root, not from examples/.
# Edit the two paths below. For semicolon CSV, also use read.csv2() below.

# Path to the input CSV file, relative to the repository root.
# By default, the script reads "my_input_template.csv" from "data".
# This teaching template intentionally has unacceptable consistency.
input_path <- file.path("data", "my_input_template.csv")

# Directory for exported results, relative to the repository root.
# By default, results are saved in "output/my_analysis".
# The directory is created automatically if it does not exist.
# Use a separate directory for each analysis to preserve earlier results.
output_dir <- file.path("output", "my_analysis")

# 1. Check the environment and load the functions.
required_files <- file.path("R", c("validate_bwm_input.R", "solve_bwm.R"))
if (!all(file.exists(required_files))) {
  stop("Set the working directory to the repository root.", call. = FALSE)
}
if (!requireNamespace("lpSolve", quietly = TRUE)) {
  stop("Install lpSolve first: install.packages('lpSolve')", call. = FALSE)
}
source(required_files[1])
source(required_files[2])
if (!file.exists(input_path)) {
  stop("Input CSV not found: ", input_path, call. = FALSE)
}

# 2. Import and inspect.
#These reports do not replace solver validation.
# For semicolon-separated CSV, replace read.csv above with read.csv2.
my_input <- read.csv(input_path, stringsAsFactors = FALSE)

cat("\nINPUT IMPORT\n")
cat("Working directory: ", getwd(), "\n", sep = "")
cat("Input file: ", normalizePath(input_path, winslash = "/"), "\n", sep = "")
cat("Rows: ", nrow(my_input), "; columns: ", ncol(my_input), "\n", sep = "")
print(names(my_input))
str(my_input)
print(my_input, row.names = FALSE)
cat("\nMissing values by column:\n")
print(colSums(is.na(my_input)))

# 3. Validate the input internally and solve the model.
# Invalid input stops execution.
# Unacceptable input consistency is reported as a diagnostic.
# See README.md for details on consistency measures and their interpretation.
my_result <- solve_bwm(my_input)
consistency <- my_result$input_consistency

# 4. Report global and local input consistency.
# The supplied data/my_input_template.csv intentionally contains judgments
# for which CR_I exceeds the applicable acceptance threshold.
# An "unacceptable" assessment is therefore expected for that unchanged
# teaching dataset; it does not indicate a software error.
# For your own data, review any unacceptable assessment before using the weights.
cat("\nINPUT-CONSISTENCY ASSESSMENT\n")
print(consistency[c(
  "method", "n_criteria", "scale_value", "ratio", "threshold",
  "threshold_available", "acceptable", "assessment"
)])
cat("\nCriterion/criteria with the largest local discrepancy:\n")
if (length(consistency$most_inconsistent_criteria) == 0L) {
  cat("None: all local ratios are zero.\n")
} else {
  print(consistency$most_inconsistent_criteria)
}
cat("\nLocal ratios (largest discrepancy first):\n")
local_order <- order(-consistency$by_criterion$input_consistency_ratio)
print(consistency$by_criterion[local_order, ], row.names = FALSE, digits = 8)

if (isFALSE(consistency$acceptable)) {
  warning(
    "The input judgments do not satisfy the published ",
    "consistency threshold. Review the identified judgments.",
    call. = FALSE
  )
} else if (is.na(consistency$acceptable)) {
  message(
    "No published consistency threshold is available for this combination. ",
    "The nonzero ratio is not classified as acceptable or unacceptable."
  )
} else {
  message("The input judgments satisfy the implemented consistency rule.")
}
cat("A critical criterion identifies a discrepancy, not a proven error.\n")
cat("Revise judgments only when justified by the decision maker.\n")

# 5. Display weights and optimization diagnostics.
cat("\nCLASSICAL BWM RESULTS\n")
cat("Method: ", my_result$method, "\n", sep = "")
cat("Best criterion: ", my_result$best_criterion, "\n", sep = "")
cat("Worst criterion: ", my_result$worst_criterion, "\n", sep = "")
cat("Solver: ", my_result$solver, "; status: ",
    my_result$solver_status, " (0 = optimal)\n", sep = "")
cat("\nRanking (largest weight first):\n")
print(my_result$ranking, row.names = FALSE, digits = 8)
cat("Sum of weights: ", format(sum(my_result$weights$weight), digits = 12),
    "\n", sep = "")
cat("Minimum weight: ", format(min(my_result$weights$weight), digits = 12),
    "\n", sep = "")
cat("Optimal maximum absolute deviation (xi): ",
    format(my_result$deviation, digits = 12), "\n", sep = "")
cat(
  "xi measures the maximum absolute deviation in the linear BWM ",
  "preference relations.\n",
  sep = ""
)
cat(
  "A smaller xi indicates a closer fit to the entered judgments; ",
  "it does not establish the accuracy of the weights.\n",
  sep = ""
)
cat(
  "xi is not CR_I and must not be compared with the ",
  "input-consistency threshold.\n",
  sep = ""
)
cat(
  "Optimal solver status does not establish acceptable input consistency.\n"
)
cat("See README.md for guidance on interpreting these diagnostics.\n")

# 6. Export full-precision results, including diagnostics for flagged inputs.
# Existing files with the names below are overwritten on rerun.
export_names <- c(
  "weights.csv", "input.csv", "local_consistency.csv", "result.rds",
  "sessionInfo.txt", "consistency_summary.csv"
)
existing <- file.exists(file.path(output_dir, export_names))
if (any(existing)) {
  message("Overwriting existing output file(s): ",
          paste(export_names[existing], collapse = ", "),
          ". Use a different output_dir to retain earlier results.")
}
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
if (!dir.exists(output_dir)) {
  stop("Could not create output directory: ", output_dir, call. = FALSE)
}
write.csv(my_result$ranking, file.path(output_dir, "weights.csv"), row.names = FALSE)
write.csv(my_result$input, file.path(output_dir, "input.csv"), row.names = FALSE)
write.csv(consistency$by_criterion,
          file.path(output_dir, "local_consistency.csv"), row.names = FALSE)
saveRDS(my_result, file.path(output_dir, "result.rds"))
writeLines(capture.output(sessionInfo()), file.path(output_dir, "sessionInfo.txt"))
consistency_summary <- data.frame(
  n_criteria = consistency$n_criteria,
  best_to_worst = consistency$scale_value,
  ratio = consistency$ratio,
  threshold = consistency$threshold,
  threshold_available = consistency$threshold_available,
  acceptable = consistency$acceptable,
  assessment = consistency$assessment,
  most_inconsistent_criteria = paste(
    consistency$most_inconsistent_criteria, collapse = "; "
  ),
  deviation = my_result$deviation,
  solver_status = my_result$solver_status
)
write.csv(consistency_summary,
          file.path(output_dir, "consistency_summary.csv"), row.names = FALSE)
cat("\nResults saved to: ",
    normalizePath(output_dir, winslash = "/"), "\n", sep = "")
print(export_names)
# Later: saved_result <- readRDS(file.path(output_dir, "result.rds"))

