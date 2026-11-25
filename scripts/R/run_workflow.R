source("scripts/R/common.R")
dataset <- get_dataset(); z <- read_inputs(dataset); x <- z$x
cfg <- read.delim("config/qc.tsv"); cfg <- cfg[cfg$dataset == dataset, , drop = FALSE]
if (nrow(cfg) != 1 || any(!is.finite(as.matrix(cfg[-1]))) ||
    cfg$min_counts < 0 || cfg$min_genes < 0 || cfg$max_mito_pct < 0 || cfg$max_mito_pct > 100)
  stop("Invalid QC configuration.")
out <- file.path("results", dataset)
dir.create(out, recursive = TRUE, showWarnings = FALSE)
# Total counts include all main-experiment genes; mitochondrial fraction uses that denominator.
total <- colSums(x); detected <- colSums(x > 0)
mito_pct <- ifelse(total > 0, 100 * colSums(x[z$g$is_mito, , drop = FALSE]) / total, NA_real_)
keep <- total >= cfg$min_counts & detected >= cfg$min_genes &
        !is.na(mito_pct) & mito_pct <= cfg$max_mito_pct & total > 0
qc <- data.frame(z$m, total_counts = total, detected_genes = detected,
                 mito_pct = mito_pct, retained = keep)
write_tsv(qc, file.path(out, "cell-qc.tsv"))
write_tsv(cfg, file.path(out, "parameters.tsv"))
write_tsv(data.frame(file = c("counts", "cell-metadata.tsv", "gene-metadata.tsv"),
 md5 = unname(tools::md5sum(c(if (file.exists(file.path("data", dataset, "counts.rds")))
 file.path("data", dataset, "counts.rds") else file.path("data", dataset, "counts.tsv"),
 file.path("data", dataset, "cell-metadata.tsv"), file.path("data", dataset, "gene-metadata.tsv"))))),
 file.path(out, "input-checksums.tsv"))
# Delete stale downstream files if a rerun stops before PCA.
for (f in c("pca.tsv", "pca.png", "pca-variance.tsv", "selected-genes.tsv", "normalized.rds"))
  unlink(file.path(out, f))
if (sum(keep) < 3) stop("Fewer than three retained cells. Review QC; do not lower cutoffs blindly.")
y <- log1p(sweep(x[, keep, drop = FALSE], 2, total[keep], "/") * 10000)
saveRDS(y, file.path(out, "normalized.rds"))
v <- apply(y, 1, var)
selected <- head(order(-v, rownames(y)), min(500L, sum(v > 0)))
if (length(selected) < 2) stop("Fewer than two variable genes.")
write_tsv(data.frame(gene_id = rownames(y)[selected], variance = v[selected]),
          file.path(out, "selected-genes.tsv"))
pc <- prcomp(t(y[selected, , drop = FALSE]), center = TRUE, scale. = FALSE, rank. = 2)
variance <- pc$sdev^2 / sum(pc$sdev^2)
write_tsv(data.frame(component = seq_along(variance), fraction = variance), file.path(out, "pca-variance.tsv"))
scores <- data.frame(cell_id = colnames(y), PC1 = pc$x[, 1], PC2 = pc$x[, 2])
write_tsv(scores, file.path(out, "pca.tsv"))
png(file.path(out, "qc.png"), width = 1200, height = 700, res = 120)
plot(total, detected, col = ifelse(keep, "steelblue", "tomato"), pch = 16,
     xlab = "Total counts", ylab = "Detected genes", main = "QC: blue retained; red excluded")
dev.off()
png(file.path(out, "pca.png"), width = 1200, height = 700, res = 120)
plot(scores$PC1, scores$PC2, pch = 16, col = "steelblue",
     xlab = sprintf("PC1 (%.1f%%)", 100 * variance[1]),
     ylab = sprintf("PC2 (%.1f%%)", 100 * variance[2]), main = "Retained cells: exploratory PCA")
dev.off()
writeLines(capture.output(sessionInfo()), file.path(out, "session-info.txt"))
cat(sum(keep), "of", ncol(x), "cells retained. Review cell-qc.tsv before interpreting PCA.\n")
