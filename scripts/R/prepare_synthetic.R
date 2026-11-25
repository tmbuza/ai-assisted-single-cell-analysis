# Deterministic teaching counts: no random generator or external download.
source("scripts/R/common.R")
dir.create("data/synthetic", recursive = TRUE, showWarnings = FALSE)
genes <- sprintf("Gene%03d", 1:60)
cells <- sprintf("Cell%03d", 1:48)
x <- outer(1:60, 1:48, function(g, c) (g * 7 + c * 3) %% 9)
x[1:10, 1:24] <- x[1:10, 1:24] + 15
x[11:20, 25:48] <- x[11:20, 25:48] + 15
x[, 47] <- 0; x[1:3, 47] <- c(1, 2, 3)
x[1:5, 48] <- 200
rownames(x) <- genes; colnames(x) <- cells
write.table(data.frame(gene_id = genes, x, check.names = FALSE),
            "data/synthetic/counts.tsv", sep = "\t", quote = FALSE, row.names = FALSE)
write_tsv(data.frame(cell_id = cells,
  sample_id = rep(c("Practice1", "Practice2"), 24),
  reference_label = rep(c("Simulated A", "Simulated B"), each = 24)),
  "data/synthetic/cell-metadata.tsv")
write_tsv(data.frame(gene_id = genes, is_mito = 1:60 <= 5),
          "data/synthetic/gene-metadata.tsv")
cat("Created 60 genes x 48 cells. Labels are simulation settings, not discoveries.\n")
