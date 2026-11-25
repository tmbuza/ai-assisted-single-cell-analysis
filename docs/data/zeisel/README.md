# Zeisel mouse-brain example

Source: Zeisel et al. (2015), *Cell types in the mouse cortex and hippocampus revealed by single-cell RNA-seq*. Science 347:1138–1142. DOI: https://doi.org/10.1126/science.aaa1934

Retrieval: `scRNAseq::ZeiselBrainData(ensembl=FALSE, location=FALSE)`.
Documentation: https://bioconductor.org/packages/scRNAseq and https://bioc-release.r-universe.dev/scRNAseq/doc/manual.html#ZeiselBrainData

The main experiment contains UMI counts; spike-ins and repeats are separate alternative experiments and are not used here. `featureType` supplies mitochondrial annotation; the script stops if that field is absent or unrecognized. `level1class` is the published cell label, not a prediction made by this workflow.

The first 400 cells in source order keep this dense teaching analysis manageable. This is a convenience subset and may omit cell classes or overrepresent source ordering. Do not estimate tissue proportions or reproduce the paper's conclusions from it. Full original metadata is exported alongside the teaching files. `sample_id=unknown` explicitly records an unvalidated donor mapping; no condition comparison is permitted.

The download may be much larger than the exported subset. Internet, disk space and a working Bioconductor installation are required. Generated source files, package version, date, dimensions, selection rule and input checksums are saved locally. Review data reuse terms and original acknowledgments before redistribution; the downloaded dataset is not bundled with this scaffold.
