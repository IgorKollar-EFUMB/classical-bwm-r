# Reproducibility

Install R and `lpSolve`, then run `tests/run_tests.R` from this project root.
The solvers and their regression tests originate from combined candidate v7.
The combined project's lockfile is intentionally not copied: it installs
packages for the other method and research document rendering.

Record `sessionInfo()` for every research run and retain the CSV, result RDS,
parameters and repository version. This distribution does not claim to
restore a frozen package environment. Before publication, run the complete
test suite on the intended release environment and record its versions.

See VALIDATION.md for checks actually performed during this split.
