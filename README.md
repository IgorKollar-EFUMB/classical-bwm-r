# Classical Best-Worst Method (BWM) in R

This project calculates **criterion importance weights** from
Best-to-Others and Others-to-Worst judgments. 
Use linear BWM when pairwise preferences are intended to be precise numerical
judgments.

Comparisons are precise numerical judgments. The method returns point weights and a ranking using the linear formulation of BWM.
A weight of 0.30 means 30% of the total importance in this criterion set.
It is not a performance score of an alternative or a probability.

## Quick start

The implementation is a collection of R scripts, not an installable R
package. Download the complete repository, set the extracted repository as
the R working directory, install the single required package, and run the
prepared example.

```r
setwd("C:/Users/UserName/Documents/classical-bwm-r")
install.packages("lpSolve", repos = "https://cloud.r-project.org")
source(file.path("examples", "run_bwm_example.R"))
```

Replace the example path with the actual location on your computer.

The following sections explain every step and then show two ways to analyse your own data.

## Repository structure

| Path | Purpose |
|---|---|
| `R/validate_bwm_input.R` | Local input validation and Liang input-based consistency. |
| `R/solve_bwm.R` | The method's solver. |
| `examples/run_bwm_example.R` | Fixed nine-criterion installation and reproducibility check; do not edit. |
| `examples/run_own_data.R` | Sole recommended template for custom data; copy before editing. |
| `data/bwm_example.csv` | Input for the prepared example. |
| `data/my_input_template.csv` | Five-criterion teaching template; deliberately fails consistency. |
| `data/pension_sustainability_input.csv` | Input for the associated study. |
| `output/` | Your exported results. |
| `tests/` | Independent validation and method regression tests. |
| `REPRODUCIBILITY.md` | Recording and checking the computational environment. |

## 1. Download and extract the repository

1. Open <https://github.com/IgorKollar-EFUMB/classical-bwm-r>.
2. For a published version, open **Releases**, select the required release,
   and download its source-code ZIP archive. If no release is available yet,
   select **Code → Download ZIP** on the repository's main page.
3. Extract the complete archive to a permanent folder. Do not open or run the
   R scripts directly inside the ZIP archive.

Depending on how the archive was downloaded, the extracted folder may be
named `classical-bwm-r`, `classical-bwm-r-0.1.0`, or
`classical-bwm-r-main`. The folder name itself is not important. Its contents
must include `R`, `data`, `examples`, `tests`, and `README.md`.

On Windows, for example, the repository may be extracted to:

```text
C:\Users\UserName\Documents\classical-bwm-r
```

## 2. Install R, RStudio, and the required package

Install a current version of R from <https://cran.r-project.org/>. RStudio is
optional, but its script editor and working-directory controls are convenient
for users who are new to R. If desired, install RStudio Desktop from
<https://posit.co/download/rstudio-desktop/>.

Open R or RStudio and install `lpSolve`:

```r
install.packages("lpSolve", repos = "https://cloud.r-project.org")
```

The package needs to be installed only once for a given R installation. An
internet connection is required during installation, but not for subsequent
calculations. If R asks whether to create or use a personal library, accept
the proposed option. No `renv` activation or automatic package installation
is required.

## 3. Set and verify the working directory

The working directory must be the extracted repository root, not its `R`,
`data`, or `examples` subdirectory. Replace the path below with the actual
path on your computer. In R code on Windows, use forward slashes:

```r
# Windows example
setwd("C:/Users/UserName/Documents/classical-bwm-r")

# macOS/Linux example
# setwd("/Users/UserName/Documents/classical-bwm-r")
```

Verify the location before running an example:

```r
getwd()
list.files()
stopifnot(
  file.exists(file.path("R", "validate_bwm_input.R")),
  file.exists(file.path("R", "solve_bwm.R")),
  file.exists(file.path("data", "bwm_example.csv"))
)
```

If the check returns without an error, the relative paths used by the scripts
are available. Set the working directory again after opening a new R session
unless your R project or editor restores it automatically.

## 4. Run the prepared Classical BWM example

From the repository root, run:

```r
source(file.path("examples", "run_bwm_example.R"))
```

The script:

1. loads `R/validate_bwm_input.R` and `R/solve_bwm.R`;
2. reads the nine-criterion input from `data/bwm_example.csv`;
3. validates the input and identifies the best and worst criteria;
4. calculates the input-based Consistency Ratio (`CR_I`);
5. solves the linear Classical BWM model; and
6. prints the consistency assessment, optimal deviation, criterion weights,
   ranking, and local consistency ratios.

The prepared example should identify C1 as the best criterion and C9 as the
worst criterion. Its global input-based consistency ratio is approximately
`0.222222`; the applicable threshold is `0.3662`, so the input judgments are
classified as acceptable. The weights sum to 1 up to numerical rounding.

Run this example unchanged. Keep both `examples/run_bwm_example.R` and
`data/bwm_example.csv` unchanged as a fixed installation and reproducibility
check. This is not the template for custom data and does not replace the
regression tests in `tests/`. For your own analysis, use only a copy of
`examples/run_own_data.R`, as described below.

## 5. Use Classical BWM with your own data

### 5.1 Copy the analysis template and prepare your data

Start by creating a copy of `examples/run_own_data.R`. This is the standard
workflow for analysing your own data. In RStudio, open the file, choose
**Save As**, and save the copy as `examples/run_my_analysis.R`.
Alternatively, copy and rename the file in your file manager.
Keep the original template and the reference files
`examples/run_bwm_example.R` and `data/bwm_example.csv` unchanged.

Next, prepare the CSV file that your copied script will read. Enter your
judgments in this CSV; you do not need to enter comparison vectors directly
in the R code. First define your criteria and select the most important
(best) and least important (worst) criteria. These labels refer to importance,
not to the performance of an alternative.

Create a comma-separated file with the following exact column names:

| Column | Required content |
|---|---|
| `criterion` | Unique, non-empty name or identifier of the criterion. |
| `best_to_others` | Preference of the best criterion over the criterion in the current row. |
| `others_to_worst` | Preference of the criterion in the current row over the worst criterion. |

Enter the two comparison columns in the following directions:

- **`best_to_others`: best criterion compared with the current criterion.**
  A value of 5 means that the best criterion is preferred over the criterion
  in the current row with intensity 5 on the adopted BWM scale.
  Enter 1 in the best criterion's own row (a self-comparison).
  Larger values express a greater preference for the best criterion over
  the current criterion.
- **`others_to_worst`: current criterion compared with the worst criterion.**
  A value of 5 means that the criterion in the current row is preferred over
  the worst criterion with intensity 5.
  Enter 1 in the worst criterion's own row (a self-comparison).
  Larger values express a greater preference for the current criterion over
  the worst criterion.

The values are comparison intensities, not criterion ranks or weights.
The two numbers in a row do not have to add up to a fixed number, and the
second column must not be obtained simply by reversing the first column.
Elicit each comparison from the decision maker.

Example for five criteria, with C1 selected as best and C5 as worst:

```csv
criterion,best_to_others,others_to_worst
C1,1,5
C2,2,4
C3,3,3
C4,4,2
C5,5,1
```

For example, the C2 row means that C1 is preferred over C2 with intensity 2,
and C2 is preferred over C5 with intensity 4. The two direct C1-to-C5
comparisons both equal 5: `best_to_others` in the C5 row and
`others_to_worst` in the C1 row. The symmetric values in this illustrative
example are not a requirement for your own data.

In a spreadsheet, put the three exact column names in the first row.
Put one criterion in each subsequent row. Do not add title rows, blank rows,
percent signs, formulas saved as text, or merged cells.
Save as **CSV UTF-8**, then inspect the file in a text editor.

These examples use commas between fields. 
Some European spreadsheet settings export semicolon-separated CSV files.
For those files replace `read.csv(...)` with `read.csv2(...)`.
Do not merely rename an XLSX file to CSV.

Save this example as `data/my_bwm.csv`. It is the five-criterion example used
in the associated article. It differs from `data/my_input_template.csv`,
which intentionally contains `C3,3,4` and produces an unacceptable
consistency assessment to demonstrate the warning. Do not overwrite either
supplied file; give each practical dataset a descriptive filename.

The input must satisfy all of these rules:

1. Each criterion must have a unique name.
2. Both comparison columns must contain finite integer values from 1 to 9.
3. The `best_to_others` column must contain exactly one value equal to 1. This
   value identifies the best criterion.
4. The `others_to_worst` column must contain exactly one value equal to 1.This
   value identifies the worst criterion.
5. The best and worst criteria must be different.
6. The direct best-to-worst judgment must be identical in both vectors.
   `best_to_others[worst] = others_to_worst[best]`.
7. Additional ties with the best or worst criterion are not supported.


### 5.2 Edit the input and output paths

At the beginning of your R script file, update the two settings with your paths:

```r
input_path <- file.path("data", "my_bwm.csv")
output_dir <- file.path("output", "my_bwm_analysis")
```

Both paths are relative to the repository root, even though the copied script
is stored in `examples`. The unchanged template uses
`data/my_input_template.csv` and `output/my_analysis`.
The input file must already exist. The script creates the output directory.
For another decision problem, use a descriptive CSV filename and a separate
output directory. Reusing an output directory overwrites the named exports;
the script reports which existing files will be replaced.

For the comma-separated example above, no further code changes are required.
For a semicolon-separated CSV, replace `read.csv()` with `read.csv2()`
at the import step. Check the printed column names and data types.

The original template points to `data/my_input_template.csv`, which deliberately
has unacceptable consistency. Its warning is expected. To reproduce the article,
use `data/my_bwm.csv`, not the unchanged teaching template.

### 5.3 Save and run the copy

Save the edited file, ensure that the working directory is still the repository
root, and run this command in the R console:

```r
source(file.path("examples", "run_my_analysis.R"))
```

Run the complete script after every input change. The script uses explicit
`print()` calls so that results appear when executed with `source()`.
Do not interpret objects left from an earlier run if the current run stops
with an error.

The numbered script sections perform the following tasks:

1. Check the working directory, required package, and input file.
2. Print the imported path, dimensions, column names, types, values, and
   missing-value counts. These reports support inspection; formal validation
   occurs inside the solver.
3. Call `solve_bwm(my_input)`, which validates the input internally once.
4. Print the global ratio, threshold, availability, assessment, critical
   criteria, and all local ratios sorted by decreasing discrepancy.
5. Print best/worst criteria, ranking, weight sum, minimum weight, solver
   status, and optimal linear-model deviation.
6. Export the complete result and the computational environment.

A consistency value of `FALSE` produces a warning; `NA` produces an
informational message that a nonzero ratio cannot be classified using the
published table. `TRUE` confirms the implemented consistency rule is met.
The script prints this confirmation explicitly.
Perfect consistency can be recognized even when no threshold is available.
Invalid inputs stop the calculation; unacceptable consistency normally does
not prevent optimization or export under R's default warning settings.

**Expected warning for the teaching template.** The unchanged
`data/my_input_template.csv` contains `C3,3,4`, giving `CR_I = 0.35`
against a threshold of `0.2306`. Its unacceptable assessment is intentional
and does not indicate a software error. The script repeats this explanation
in the comments at the beginning of section 4; those comments are not printed
to the console. This explanation applies only to the unchanged teaching
dataset. For your own data, review every unacceptable assessment before
using the weights, and revise judgments only with the decision maker's
justification.

For the five-criterion example, expect `CR_I = 0.2`, threshold `0.2306`,
and an acceptable assessment. C3 has the largest local discrepancy.

| Criterion | Weight (rounded) | Rank |
|---|---:|---:|
| C1 | 0.41577061 | 1 |
| C2 | 0.23655914 | 2 |
| C3 | 0.15770609 | 3 |
| C4 | 0.11827957 | 4 |
| C5 | 0.07168459 | 5 |

| Output file | Content |
|---|---|
| `weights.csv` | Weights sorted by rank. |
| `input.csv` | Validated input used by the solver. |
| `local_consistency.csv` | Local calculations in original criterion order. |
| `consistency_summary.csv` | Number of criteria, direct best-to-worst value, global ratio, threshold, availability, acceptability, assessment, critical criteria, deviation, and solver status. |
| `result.rds` | Complete result object at full numerical precision. |
| `sessionInfo.txt` | R, platform, and package environment. |

The export is a record of the calculation, not an endorsement of inconsistent
judgments. Retain the original CSV and the edited script as well.

### 5.4 Classical BWM results and interpretation

The principal result table is available as both `weights` and `ranking`:

| Column | Interpretation |
|---|---|
| `criterion` | Criterion identifier copied from the input. |
| `weight` | Non-negative point weight; all weights sum to 1. |
| `rank` | Descending rank based on `weight`; rank 1 is the largest weight. |

`weights` preserves the CSV row order. `ranking` sorts the same rows by rank.

The value `result$deviation` is the optimal maximum absolute deviation
`xi` in the linear BWM model:

\[
|w_B-a_{Bj}w_j|\leq\xi,
\qquad
|w_j-a_{jW}w_W|\leq\xi.
\]

A smaller `xi` means that the calculated weights fit the entered linear BWM
relations more closely. It does not establish the accuracy of the weights.
`xi` is not `CR_I` and must not be compared with the input-consistency
threshold. Optimal solver status does not establish acceptable input
consistency. These distinctions are also printed in section 5 of the script.

Interpret a Classical BWM result in this order:

1. **Check `input_consistency$assessment`.** If it is unacceptable, inspect
   `by_criterion` and reconsider the comparisons for the reported critical
   criterion or tied criteria.
2. **Check the weight sum.** `sum(result$weights$weight)` should be 1 up to
   numerical rounding.
3. **Read weights comparatively.** A weight of 0.30 means a 30% share of total
   importance within this criterion set; it is not an absolute performance
   score.
4. **Inspect close weights and tied ranks.** Small numerical differences may
   not represent a meaningful managerial distinction.
5. **Use `xi` as a model-fit diagnostic.** A smaller value indicates a closer
   fit to the entered linear preference relations, but the acceptance
   decision comes from `CR_I`, not from an unsupported universal threshold for
   `xi`.

A practical result should therefore have defensible input judgments, an
acceptable `CR_I` where a published threshold is available, normalized
weights, and a ranking that the decision maker can substantively explain.


## Understanding input consistency: CR_I

Before the optimization model is constructed, `validate_bwm_input()`:

1. checks the CSV structure and comparison values;
2. identifies the best and worst criteria;
3. verifies the direct best-to-worst comparison; and
4. calculates the input-based Consistency Ratio proposed by Liang, Brunelli,
   and Rezaei (2020).

For criterion `j`, the local ratio is

\[
CR^I_j=
\frac{|a_{Bj}a_{jW}-a_{BW}|}{a_{BW}^2-a_{BW}},
\qquad a_{BW}>1,
\]

and the global input-based Consistency Ratio is

\[
CR^I=\max_j CR^I_j.
\]

The helper defines zero ratios for `a_BW = 1`, but this case cannot be entered through the current solver interface: the interface requires distinct best and worst criteria and exactly one self-comparison of 1 in each vector. Perfect cardinal consistency
for a criterion means

\[
a_{Bj}a_{jW}=a_{BW}.
\]

The calculated global ratio is compared with the threshold published for the
applicable combination of the number of criteria and `a_BW`. The published
table covers 3--9 criteria and `a_BW` values 3--9; a zero threshold is also
specified for scale value 2. The implementation does not extrapolate missing
thresholds. When no published threshold is available, it reports `CR_I` but
returns `NA` for the threshold and, for a nonzero ratio, the acceptability decision. Perfect consistency (`CR_I = 0`) is recognized even without a published threshold.

An unacceptable assessment is a diagnostic result, not an error. The solver
still returns weights so that the decision maker can inspect the complete
consequences of the judgments. The judgments should then be reconsidered and
the method rerun. Values should not be changed mechanically only to pass the
threshold; revisions should be confirmed by the decision maker.

The object `result$input_consistency` contains:

| Component | Interpretation |
|---|---|
| `ratio` | Global input-based ratio `CR_I`; the largest local discrepancy. |
| `threshold` | Published acceptance threshold for the applicable `n` and `a_BW`. |
| `threshold_available` | Whether the published threshold exists. |
| `acceptable` | `TRUE`, `FALSE`, or `NA` when a decision cannot be made from the published table. |
| `assessment` | Plain-language assessment. |
| `n_criteria` | Number of criteria used to select the threshold. |
| `scale_value` | Direct best-to-worst value `a_BW`. |
| `most_inconsistent_criteria` | Criterion or tied criteria attaining the global ratio. |
| `by_criterion` | Detailed local calculation for every criterion. |

`by_criterion` contains the original two comparisons, their product
`indirect_best_to_worst`, and the local `input_consistency_ratio`. It is the
most useful table when reviewing an unacceptable result.


### A worked check and what to revise

The supplied nine-criterion example has `a_BW = 9`. For C4,
`a_B4 = 5` and `a_4W = 5`, so its indirect comparison is 25.
Its local ratio is `abs(25 - 9)/(81 - 9) = 0.222222...`.
This is the maximum local ratio, so C4 is reported as critical.
For **nine criteria and a_BW = 9**, the threshold is **0.3662**.
The input assessment is therefore acceptable.

Do not reuse 0.3662 for every dataset. For the supplied five-criterion teaching template, `a_BW = 5`, the largest local discrepancy is at C3:
`abs(3*4 - 5)/(25 - 5) = 0.35`. Its threshold is **0.2306**,
so this deliberately instructive template is **unacceptable**.
The optimizer still runs; the template demonstrates why valid CSV data
and acceptable judgments are different things.

The threshold is selected from Liang et al. (2020), Table 3, using the number
of criteria and the direct best-to-worst value used by this implementation.
`scale_value` in the result is this `a_BW`, not simply the largest
permitted number in the CSV format. The permitted modal scale remains 1--9.

To review your own result:

```r
ci <- my_result$input_consistency
ci[c("ratio", "threshold", "assessment", "n_criteria", "scale_value")]
ci$by_criterion[order(-ci$by_criterion$input_consistency_ratio), ]
```

1. Read the critical criterion's two original judgments.
2. Compare their product with the direct best-to-worst judgment.
3. Ask whether either local judgment or the direct judgment needs revision.
   The critical criterion identifies the largest conflict, not a proven erroneous answer.
4. Revise only comparisons that the decision maker can justify and rerun the calculation.
   Keep the original and revised input files.
5. Review all local ratios: after revising the largest one, another may become critical.

`CR_I` is a dimensionless discrepancy measure, not a probability, an error
percentage in the weights, or an agreement score between experts.
An acceptable result means that this specific input-consistency rule is met.
It does not prove correct criterion selection, reliable expertise, stable
ranks, or correct decisions. A ratio near the threshold merits particular
attention to plausible changes in judgments.

The software uses `ratio <= threshold` for acceptance. If the threshold is
unavailable, a nonzero ratio is reported as **not assessed**, not acceptable
and not automatically unacceptable. More criteria can still be solved;
the program does not invent a threshold for them.

### Scope of the input interface

The current implementation requires exactly one value of 1 in each comparison
column and distinct best and worst criteria. It therefore does not support
additional ties with the best or worst criterion, or an all-equal criterion set.
Do not enter artificial preferences just to bypass this restriction.
Integer intensities express importance comparisons; they are not positions
in a ranking and are not raw criterion measurements.

Choose criteria that are understandable and suitable for the same decision.
Select the most and least important criteria before filling in the comparisons.
A cost criterion can still be very important: "best criterion" means highest
importance, not the largest observed performance or a benefit rather than a cost.

## Assess whether the point weights are usable

The output is one normalized point-weight vector. This implementation does
not compute ranges of alternative optimal weights; the absence of intervals
does not establish uniqueness or certainty.

`deviation` (xi) measures the worst residual in the linear equations, not in
the original input products. `objective_value` is the same optimization
objective; `solver_status = 0` means the linear program was solved optimally.
Successful optimization is separate from acceptable input consistency.
A value of xi = 0.05 is not a statement that all weights have 5% error.

Exact weight ties use minimum ranks (1, 1, 3). Near ties are still ordered.
The order in `weights` follows the CSV; `ranking` is sorted.
Do not infer a substantial managerial difference from rounded close weights.

For a practical sensitivity check, copy the input and revise a judgment only
within a range the decision maker considers plausible. Preserve matching
direct best-to-worst entries if that comparison changes. Rerun the method,
recheck CR_I and compare weights by criterion identifier.
If a small justified revision changes the important ranking, disclose that
sensitivity instead of describing the original ranks as definitive.

To use these weights in a weighted score of alternatives, first define how
their performance measures are normalized and how benefit/cost directions
are handled. This repository estimates importance weights; it does not
automatically make raw performance columns comparable.

## Preserve and reopen the analysis

The user-data workflow automatically exports the six files listed above.
Keep the input CSV, your copied script, output files, and the exact repository
release or commit together. Use a new output directory for each scenario.

To inspect an existing result without running the optimizer again:

```r
saved_result <- readRDS(
  file.path("output", "my_bwm_analysis", "result.rds")
)
print(saved_result$ranking)
print(saved_result$input_consistency)
```

Report criterion definitions, decision maker, judgments, CR_I, threshold,
weights, and model deviation. Keep full precision for calculations and round
only displayed results.

## Troubleshooting

| Symptom | What to check |
|---|---|
| File cannot be opened | Check `getwd()`, extraction, filename and file extension. |
| Required columns are missing | Check spelling and CSV separator. |
| Comparison columns are not numeric | Inspect `str(my_input)`; remove text, units and formatting. |
| More than one comparison equals 1 | This interface does not support additional ties with the best/worst. |
| Direct comparisons do not match | Check the worst row of Best-to-Others and the best row of Others-to-Worst. |
| Consistency is unacceptable | Inspect local ratios and discuss the conflicting judgments; optimization may still return weights. |
| Threshold is NA | The published table does not cover the combination; a nonzero CR_I is not assessed. |
| Package is missing | Install `lpSolve` in the R installation used for this session. |
| Optimization stops with an error | Preserve the input, parameters, error and `sessionInfo()`; do not interpret a previous run as the failed run. |

## Tests and maintenance

From the repository root:

```r
source(file.path("tests", "run_tests.R"))
```

The tests check structural validation, input consistency and expected linear BWM weights. The project is intended for stable use and corrective maintenance.

## Associated manuscript

**Best-Worst Method and α-cut intervals based Fuzzy Best-Worst Method in R: A
Pension Sustainability Index Case Study**

Authors:

- Michaela Bruteničová
  ([ORCID 0000-0003-0208-6816](https://orcid.org/0000-0003-0208-6816))
- Miroslav Hužvár
  ([ORCID 0000-0001-9797-5602](https://orcid.org/0000-0001-9797-5602))
- Igor Kollár
  ([ORCID 0000-0003-4734-812X](https://orcid.org/0000-0003-4734-812X))
- Jana Špirková
  ([ORCID 0000-0001-5864-9353](https://orcid.org/0000-0001-5864-9353))

Affiliation: Matej Bel University in Banská Bystrica, Slovakia.

The manuscript is in preparation. Journal, publication year, and DOI metadata
will be added when they become available.


## References and citation

- Liang, F., Brunelli, M., & Rezaei, J. (2020). Consistency issues in the best
  worst method: Measurements and thresholds. *Omega, 96*, 102175.
  https://doi.org/10.1016/j.omega.2019.102175
- Rezaei, J. (2016). Best-worst multi-criteria decision-making method:
  Some properties and a linear model. *Omega, 64*, 126–130.
  https://doi.org/10.1016/j.omega.2015.12.001

Software author metadata are in `CITATION.cff`. This standalone distribution
has no assigned DOI yet. Once archived, cite the exact software version used
and the methodological publications. Do not use the future release DOI
as if it had already been assigned.

## License

MIT; see `LICENSE`.
