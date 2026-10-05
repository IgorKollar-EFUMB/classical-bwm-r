# Validation

This document records the validation performed for the standalone Classical BWM implementation before publication.

## Validation status

The automated tests and both example workflows were executed on 5 October 2026 using the following commands from the repository root:

```r
source(file.path("tests", "run_tests.R"))
source(file.path("examples", "run_bwm_example.R"))
source(file.path("examples", "run_own_data.R"))
sessionInfo()
```

The automated tests completed successfully, and both example scripts ran without unexpected errors.

The consistency warning produced by `run_own_data.R` when using the default input template is intentional. It demonstrates how the implementation alerts users to potentially inconsistent preference judgments.

## Scope of the automated tests

The test suite verifies:

- validation of the required input structure;
- identification of the best and worst criteria;
- rejection of invalid or incomplete preference data;
- calculation of Classical BWM criterion weights;
- non-negativity and normalization of the resulting weights;
- agreement of the calculated weights with the expected reference results;
- calculation of the input-based consistency measures.

The tests are implemented in:

- `tests/test_input_validation.R`;
- `tests/test_bwm.R`;
- `tests/run_tests.R`.

## Validation of the example workflows

The following example scripts were also executed:

- `examples/run_bwm_example.R` reproduces the prepared Classical BWM example and reports the criterion weights, optimal deviation, and input-consistency assessment.
- `examples/run_own_data.R` demonstrates the complete workflow for user-supplied data, including the export of weights, input data, local consistency results, the complete R result object, and session information.

Successful execution confirms that the documented workflows, relative file paths, input files, solver functions, and output-generation steps operate together as intended when the scripts are run from the repository root.

## Validation environment

The validation was performed in the following environment:

- Operating system: Microsoft Windows 10 x64 (build 26200)
- R version: R 4.6.1 (2026-06-24 ucrt)
- `lpSolve` version: 5.6.23

The environment information was obtained using:

```r
R.version.string
packageVersion("lpSolve")
Sys.info()[c("sysname", "release", "version")]
sessionInfo()
```

## Interpretation and limitations

Successful completion of the tests confirms that the implementation produces the expected results for the test cases included in this repository and that the input-validation checks operate as specified.

Successful execution of the example scripts confirms that the documented end-to-end workflows operate correctly in the validation environment stated above.

This validation does not constitute an independent formal verification of the underlying mathematical method. Users should examine the reported input-consistency measures and confirm that their judgments and model assumptions are appropriate for the decision problem being analysed.

For reproducible research, retain the input CSV file, complete result object, exported outputs, `sessionInfo()`, and the exact repository release or commit used for the analysis.