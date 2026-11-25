# Synthetic practice v2

1,000 genes x 200 cells, generated in R with seed 20261125. Run `Rscript scripts/R/prepare_synthetic.R` from the project root to recreate the files. The script specifies RNG kinds explicitly. Record R version; shipped files provide fixed input bytes across platforms.

Counts are simulated negative-binomial draws with gene baseline variation, cell-specific variation, unequal depths and two predefined expression populations. Natural zero counts occur through count sampling; no extra dropout mechanism is fitted. Genes 1–20 are mitochondrial; genes 21–100 have elevated expected expression in A, genes 101–180 in B. Four artificial sample IDs are balanced across populations; they do not represent measured donors or independent experimental evidence.

Five low-depth and five high-mitochondrial cells are deliberately constructed. The `simulation_note` column records known construction settings only. The QC workflow never reads that column for decisions. Do not use these labels as a substitute for checking counts.

With config/qc.tsv cutoffs (500 counts, 200 genes, 30% mitochondrial), 190 cells pass. PCA colours show known simulation labels, not discovered types. The simulation is educational and is not fitted to the Zeisel study. Synthetic and real PCA percentages need not match.

Old 48-cell verification values no longer apply. Recreate inputs, rerun the workflow and independently verify before interpreting. Generated learner reports remain in ignored reports/.
