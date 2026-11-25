# Download once; export a bounded demonstration subset with full source metadata.
source("scripts/R/common.R")
if (!requireNamespace("scRNAseq", quietly = TRUE)) stop("Run setup.R first.")
sce <- scRNAseq::ZeiselBrainData(ensembl = FALSE, location = FALSE)
meta <- as.data.frame(SummarizedExperiment::colData(sce))
if (!"level1class" %in% names(meta)) stop("Source annotation changed; inspect colData(sce).")
gene_meta <- as.data.frame(SummarizedExperiment::rowData(sce))
if (!"featureType" %in% names(gene_meta)) stop("Source gene annotation changed.")
mito <- grepl("mito", gene_meta$featureType, ignore.case = TRUE)
if (!any(mito)) stop("No mitochondrial annotation recognized; inspect featureType.")
# First 400 source-order cells: reproducible, deliberately NOT representative sampling.
idx <- seq_len(min(400L, ncol(sce)))
x <- SummarizedExperiment::assay(sce, "counts")[, idx, drop = FALSE]
ids <- colnames(x)
if (is.null(ids) || anyDuplicated(ids) || anyNA(ids)) stop("Invalid source cell IDs.")
if (is.null(rownames(x)) || anyDuplicated(rownames(x))) stop("Invalid source gene IDs.")
dir.create("data/zeisel", recursive = TRUE, showWarnings = FALSE)
saveRDS(x, "data/zeisel/counts.rds")
# sample_id is deliberately unknown rather than inferred from cell names.
write_tsv(data.frame(cell_id = ids, sample_id = "unknown",
                     reference_label = as.character(meta$level1class[idx])),
          "data/zeisel/cell-metadata.tsv")
write_tsv(data.frame(gene_id = rownames(x), is_mito = mito), "data/zeisel/gene-metadata.tsv")
write_tsv(data.frame(cell_id = ids, meta[idx, , drop = FALSE], check.names = FALSE),
          "data/zeisel/source-cell-metadata.tsv")
write_tsv(data.frame(gene_id = rownames(x), gene_meta, check.names = FALSE),
          "data/zeisel/source-gene-metadata.tsv")
writeLines(c("Source: scRNAseq::ZeiselBrainData(ensembl=FALSE, location=FALSE)",
 "Zeisel et al. 2015; DOI: 10.1126/science.aaa1934",
 paste("scRNAseq version:", packageVersion("scRNAseq")),
 paste("Downloaded:", Sys.Date()), paste("Source dimensions:", nrow(sce), ncol(sce)),
 paste("Export dimensions:", nrow(x), ncol(x)),
 "Selection: first 400 cells in source order; main experiment only.",
 "Published level1class retained for context; donor mapping not validated."),
 "data/zeisel/provenance.txt")
write_tsv(data.frame(file = c("counts.rds", "cell-metadata.tsv", "gene-metadata.tsv"),
 md5 = unname(tools::md5sum(file.path("data/zeisel", c("counts.rds", "cell-metadata.tsv", "gene-metadata.tsv"))))),
 "data/zeisel/checksums.tsv")
