# Run from the project root. Edit the CSV path below.
source(file.path("R", "validate_bwm_input.R"))
source(file.path("R", "solve_bwm.R"))
input_path <- file.path("data", "my_input_template.csv")
output_dir <- file.path("output", "my_analysis")
my_input <- read.csv(input_path, stringsAsFactors = FALSE)
# For semicolon-separated CSV use read.csv2 instead.
my_result <- solve_bwm(my_input)
print(my_result$ranking)
print(my_result$input_consistency[c("ratio", "threshold", "assessment", "most_inconsistent_criteria")])
print(my_result$deviation)
if (!isTRUE(my_result$input_consistency$acceptable)) {
  warning("Review input consistency before using these weights; see README.")
}
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
write.csv(my_result$ranking, file.path(output_dir, "weights.csv"), row.names = FALSE)
write.csv(my_result$input, file.path(output_dir, "input.csv"), row.names = FALSE)
write.csv(my_result$input_consistency$by_criterion, file.path(output_dir, "local_consistency.csv"), row.names = FALSE)
saveRDS(my_result, file.path(output_dir, "result.rds"))
writeLines(capture.output(sessionInfo()), file.path(output_dir, "sessionInfo.txt"))
