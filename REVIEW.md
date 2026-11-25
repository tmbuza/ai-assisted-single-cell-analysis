# Scaffold review — 25 November 2026

## Design reviewed

- All three paths contain all seven steps with learner tasks.
- Non-executable book separates teaching pages from reproducible R scripts.
- Input checks align metadata by ID and reject invalid raw counts.
- QC thresholds are explicit and recorded; zero-total cells cannot enter normalization.
- Verification independently recomputes per-cell arithmetic and retention.
- Real-data provenance, source-order subset limits and unknown donor mapping are explicit.
- Learner reports and their rendered files stay inside ignored reports/.
- No report templates or README are tracked inside reports/.

## Validation status

Static review only: R and Quarto are unavailable in the build environment. Neither analysis execution, package installation, real-data retrieval nor full HTML rendering is claimed to pass. Review pages deliberately show figure paths that will exist only after running each workflow. A validated renv.lock and rendered docs are not included.

## Before repository release

1. Run setup and all synthetic commands under R; confirm Cell001 passes and Cell047/048 fail QC as intended. Independently check those fixtures against the review notes.
2. Run `prepare_zeisel.R`; inspect featureType, level1class, full provenance and metadata. Confirm annotation assumptions against the installed package.
3. Run real-data input check, workflow and independent verifier for retained/excluded cells.
4. Run a minimal own-study example and deliberate duplicate-ID, invalid-count and zero-count checks.
5. Render the book and one learner report; inspect figure links and navigation. Until own-study inputs are supplied, its preview figures are intentionally absent.
6. Snapshot the validated environment, commit genuine renv infrastructure, then test restore in a clean project library.
7. Confirm the repository URL, replace the review download paragraph with the live Code → Download ZIP link and choose a code/content license.

This archive is for reviewing the scaffold before preparing a repository release. No repository has been created or modified.

## Automated static checks

25 chapter paths exist. All local document links resolve except the six intentionally pending QC/PCA images (two per dataset). No generated learner reports are packaged. Python independently reconstructed the deterministic synthetic counts to establish the following expected values; these do not substitute for executing R.

| Cell | Total | Detected genes | Mitochondrial % | Retained | Gene001 log1p value |
|---|---:|---:|---:|---|---:|
| Cell001 | 387 | 54 | 24.80620155 | True | 6.02692023 |
| Cell047 | 6 | 3 | 100.00000000 | False | 7.41918072 |
| Cell048 | 1372 | 55 | 72.88629738 | False | 7.28531870 |

Synthetic TSV inputs are included and match the deterministic generation rule. Basic lexical delimiter checks passed for seven R scripts; this is not an R parser or runtime test.
