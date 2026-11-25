# Independent arithmetic: does not source workflow functions or reuse its metrics.
a <- commandArgs(trailingOnly = TRUE)
if (length(a) != 2 || !a[1] %in% c("synthetic", "zeisel", "your-study"))
  stop("Usage: Rscript scripts/R/verify_cell.R DATASET CELL_ID")
d <- file.path("data", a[1]); out <- file.path("results", a[1]); id <- a[2]
if (file.exists(file.path(d, "counts.rds"))) {
  raw <- readRDS(file.path(d, "counts.rds"))
} else {
  tab <- read.delim(file.path(d, "counts.tsv"), check.names = FALSE)
  raw <- as.matrix(tab[-1]); rownames(raw) <- tab[[1]]
}
if (!id %in% colnames(raw)) stop("Cell not found.")
recorded <- read.delim(file.path(out, "input-checksums.tsv"))
paths <- c(if (file.exists(file.path(d, "counts.rds"))) file.path(d, "counts.rds") else
           file.path(d, "counts.tsv"), file.path(d, "cell-metadata.tsv"), file.path(d, "gene-metadata.tsv"))
if (!identical(as.character(recorded$md5), unname(tools::md5sum(paths))))
  stop("Input files changed since analysis; rerun workflow before verification.")
x <- as.numeric(raw[, id]); names(x) <- rownames(raw)
g <- read.delim(file.path(d, "gene-metadata.tsv"))
mito_ids <- g$gene_id[g$is_mito]
total <- sum(x); detected <- length(x[x > 0])
pct <- if (total > 0) 100 * sum(x[names(x) %in% mito_ids]) / total else NA_real_
qc <- read.delim(file.path(out, "cell-qc.tsv")); saved <- qc[qc$cell_id == id, ]
if (nrow(saved) != 1) stop("Saved QC row missing or duplicated.")
equal <- function(a,b) isTRUE(all.equal(as.numeric(a), as.numeric(b), tolerance = 1e-8))
stopifnot(equal(total, saved$total_counts), equal(detected, saved$detected_genes), equal(pct, saved$mito_pct))
cfg <- read.delim(file.path(out, "parameters.tsv"))
expected_keep <- total > 0 && total >= cfg$min_counts && detected >= cfg$min_genes &&
                 !is.na(pct) && pct <= cfg$max_mito_pct
stopifnot(identical(expected_keep, saved$retained))
if (expected_keep) {
  y <- readRDS(file.path(out, "normalized.rds"))
  # Select the first positive gene so a zero value cannot make this check trivial.
  gene <- names(x)[which(x > 0)[1]]
  expected <- log(1 + 10000 * x[gene] / total)
  stopifnot(equal(expected, y[gene, id]))
  cat("Verified normalized value for", gene, ":", expected, "\n")
}
cat("PASS:", id, "total", total, "detected", detected, "mito %", pct, "retained", expected_keep, "\n")
