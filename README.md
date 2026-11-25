# AI-Assisted Single-Cell Analysis with R

A learner-friendly Quarto guide from raw counts to an exploratory result you can explain and check.

**Define → Preview → Meet → Check → Run → Verify and Explain → Write**

Start with synthetic practice, repeat the workflow with published mouse-brain data, then bring your own study. The introductory analysis covers cell QC, counts per 10,000, log transformation and PCA. It does not perform cell-type discovery or condition testing.

## Get started

Download this complete repository using **Code → Download ZIP**, extract it, and open the inner project folder in VS Code or RStudio. Follow [00-setup.qmd](00-setup.qmd), including the tool and terminal checks.

With the tested renv.lock and activation files included, run from the main project folder:

```bash
Rscript scripts/R/setup.R
Rscript scripts/R/prepare_synthetic.R
Rscript scripts/R/check_inputs.R synthetic
Rscript scripts/R/run_workflow.R synthetic
Rscript scripts/R/verify_cell.R synthetic Cell001
Rscript scripts/R/verify_cell.R synthetic Cell047
Rscript scripts/R/verify_cell.R synthetic Cell048
quarto preview
```

Expected: 1,000 genes x 200 cells, 190 retained and three verification PASS messages. Independent checks confirm the included synthetic arithmetic. The real example uses a convenience subset of 400 cells, not a representative sample of mouse-brain cell types.

## Outputs

Each dataset writes plots to results/DATASET/figures/ and TSV tables to results/DATASET/tables/. normalized.rds and session-info.txt stay directly in results/DATASET/. Input data remain in data/DATASET/.

Create a learner report with `Rscript scripts/R/create_report.R synthetic`. Reports and rendered HTML stay inside ignored reports/ and are separate from book chapters. See [02-write-the-report.qmd](02-write-the-report.qmd).

Installation troubleshooting is in [99-appendix.qmd](99-appendix.qmd). Learners restore the supplied lockfile; they should not snapshot a failed installation or change package repositories to work around errors.
