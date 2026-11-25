source("scripts/R/common.R")
dataset <- get_dataset(); z <- read_inputs(dataset); x <- z$x
cfg <- read.delim("config/qc.tsv"); cfg <- cfg[cfg$dataset == dataset, , drop = FALSE]
if (nrow(cfg) != 1 || any(!is.finite(as.matrix(cfg[-1]))) ||
    cfg$min_counts < 0 || cfg$min_genes < 0 || cfg$max_mito_pct < 0 || cfg$max_mito_pct > 100)
  stop("Invalid QC configuration.")
out <- file.path("results", dataset)
dir.create(out, recursive = TRUE, showWarnings = FALSE)
tables <- file.path(out, "tables")
dir.create(tables, recursive = TRUE, showWarnings = FALSE)
figures <- file.path(out, "figures")
dir.create(figures, recursive = TRUE, showWarnings = FALSE)
# Total counts include all main-experiment genes; mitochondrial fraction uses that denominator.
total <- colSums(x); detected <- colSums(x > 0)
mito_pct <- ifelse(total > 0, 100 * colSums(x[z$g$is_mito, , drop = FALSE]) / total, NA_real_)
keep <- total >= cfg$min_counts & detected >= cfg$min_genes &
        !is.na(mito_pct) & mito_pct <= cfg$max_mito_pct & total > 0
qc <- data.frame(z$m, total_counts = total, detected_genes = detected,
                 mito_pct = mito_pct, retained = keep)
write_tsv(qc, file.path(tables, "cell-qc.tsv"))
write_tsv(cfg, file.path(tables, "parameters.tsv"))
write_tsv(data.frame(file = c("counts", "cell-metadata.tsv", "gene-metadata.tsv"),
 md5 = unname(tools::md5sum(c(if (file.exists(file.path("data", dataset, "counts.rds")))
 file.path("data", dataset, "counts.rds") else file.path("data", dataset, "counts.tsv"),
 file.path("data", dataset, "cell-metadata.tsv"), file.path("data", dataset, "gene-metadata.tsv"))))),
 file.path(tables, "input-checksums.tsv"))
# Delete stale downstream files if a rerun stops before PCA.
unlink(file.path(tables, c("pca.tsv", "pca-variance.tsv", "selected-genes.tsv")))
unlink(file.path(out, "normalized.rds"))
unlink(file.path(figures, c("qc.png", "pca.png")))
if (sum(keep) < 3) stop("Fewer than three retained cells. Review QC; do not lower cutoffs blindly.")
y <- log1p(sweep(x[, keep, drop = FALSE], 2, total[keep], "/") * 10000)
saveRDS(y, file.path(out, "normalized.rds"))
v <- apply(y, 1, var)
selected <- head(order(-v, rownames(y)), min(500L, sum(v > 0)))
if (length(selected) < 2) stop("Fewer than two variable genes.")
write_tsv(data.frame(gene_id = rownames(y)[selected], variance = v[selected]),
          file.path(tables, "selected-genes.tsv"))
pc <- prcomp(t(y[selected, , drop = FALSE]), center = TRUE, scale. = FALSE, rank. = 2)
variance <- pc$sdev^2 / sum(pc$sdev^2)
write_tsv(data.frame(component = seq_along(variance), fraction = variance), file.path(tables, "pca-variance.tsv"))
scores <- data.frame(cell_id = colnames(y), PC1 = pc$x[, 1], PC2 = pc$x[, 2])
write_tsv(scores, file.path(tables, "pca.tsv"))
# Both QC panels use all cells, including excluded cells.
png(file.path(figures, "qc.png"), width = 1600, height = 750, res = 120)
par(mfrow = c(1, 2), mar = c(5, 5, 4, 1))
qc_color <- ifelse(keep, "steelblue", "tomato")
plot(total, detected, col = qc_color, pch = 16,
     xlab = "Total counts", ylab = "Detected genes", main = "Counts and detected genes")
abline(v = cfg$min_counts, h = cfg$min_genes, lty = 2, col = "grey40")
legend("topleft", c("Retained", "Excluded", "QC cutoff"),
       col = c("steelblue", "tomato", "grey40"), pch = c(16, 16, NA),
       lty = c(NA, NA, 2), bty = "n", cex = 0.8)
plot(total, mito_pct, col = qc_color, pch = 16,
     ylim = c(0, max(c(mito_pct, cfg$max_mito_pct), na.rm = TRUE) * 1.1),
     xlab = "Total counts", ylab = "Mitochondrial counts (%)", main = "Mitochondrial fraction")
abline(v = cfg$min_counts, h = cfg$max_mito_pct, lty = 2, col = "grey40")
dev.off()
png(file.path(figures, "pca.png"), width = 1200, height = 700, res = 120)
point_color <- rep("steelblue", nrow(scores))
if (dataset == "synthetic") {
  point_color <- ifelse(z$m$reference_label[keep] == "Simulated A", "steelblue", "darkorange3")
}
plot(scores$PC1, scores$PC2, pch = 16, col = point_color,
     xlab = sprintf("PC1 (%.1f%%)", 100 * variance[1]),
     ylab = sprintf("PC2 (%.1f%%)", 100 * variance[2]), main = "Retained cells: exploratory PCA")
if (dataset == "synthetic") legend("topright", c("Simulated A", "Simulated B"),
                                  col = c("steelblue", "darkorange3"), pch = 16, bty = "n")
dev.off()
writeLines(capture.output(sessionInfo()), file.path(out, "session-info.txt"))
cat(sum(keep), "of", ncol(x), "cells retained. Review tables/cell-qc.tsv before interpreting PCA.\n")
