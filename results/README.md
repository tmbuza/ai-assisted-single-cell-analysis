# Generated analysis results

Each dataset has its own subfolder: synthetic/, zeisel/ or your-study/.

- figures/: qc.png and pca.png.
- tables/: cell-qc.tsv, pca.tsv, pca-variance.tsv, selected-genes.tsv, parameters.tsv and input-checksums.tsv.
- Dataset folder: normalized.rds and session-info.txt.

The workflow creates figures/ and tables/ automatically. The independent verifier reads tables from tables/ and the normalized R object from the dataset folder.

Generated dataset subfolders are ignored. Review figures before choosing which outputs to publish. Learner reports remain in the ignored reports/ folder.
