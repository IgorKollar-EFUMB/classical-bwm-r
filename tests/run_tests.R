# Run from the repository root.
source(file.path("R", "validate_bwm_input.R"))
source(file.path("R", "solve_bwm.R"))
source(file.path("tests", "test_input_validation.R"))
source(file.path("tests", "test_bwm.R"))
cat("All tests passed.\n")
