# AI-Assisted Single-Cell Analysis with R

CDI review scaffold. Quarto book: Define → Preview → Meet → Check → Run → Verify and Explain → Write.

Paths: synthetic practice → Zeisel mouse brain → your own study. Start with `00-setup.qmd`. This review archive contains source files, not a validated software release. The repository name and download URL are pending confirmation.

## Quick start

Extract the review ZIP and open the inner project folder containing `_quarto.yml`. Install R and Quarto, then run from that folder:

```bash
Rscript scripts/R/setup.R
Rscript scripts/R/prepare_synthetic.R
Rscript scripts/R/check_inputs.R synthetic
Rscript scripts/R/run_workflow.R synthetic
Rscript scripts/R/verify_cell.R synthetic Cell001
quarto preview
```

Real example: run `prepare_zeisel.R`, then the check and workflow commands with `zeisel`; verify an exact cell ID from the resulting QC table. See `data/zeisel/README.md` for provenance and selection limits.

Learner reports go in the ignored `reports/` folder. Do not add reports to the Quarto chapter list. Read `REVIEW.md` for validation status and release gates.
