# Synthetic v2: seeded negative-binomial counts for teaching, not a fitted model.
source("scripts/R/common.R")
RNGkind("Mersenne-Twister", "Inversion", "Rejection")
set.seed(20261125)
ng <- 1000L; nc <- 200L
genes <- sprintf("Gene%03d", seq_len(ng))
cells <- sprintf("Cell%03d", seq_len(nc))
is_mito <- seq_len(ng) <= 20L
population <- rep(c("Simulated A", "Simulated B"), each = 100)
sample_id <- rep(paste0("Practice", 1:4), length.out = nc)
# Variable baseline expression, library size and cell-specific expression noise.
baseline <- rlnorm(ng, meanlog = -0.4, sdlog = 1.4)
depth <- round(rlnorm(nc, meanlog = log(8000), sdlog = 0.55))
low <- c(47L, 88L, 129L, 170L, 191L)
high <- c(48L, 89L, 130L, 171L, 192L)
x <- matrix(0L, ng, nc, dimnames = list(genes, cells))
for (j in seq_len(nc)) {
  weights <- baseline * rlnorm(ng, meanlog = 0, sdlog = 0.35)
  markers <- if (population[j] == "Simulated A") 21:100 else 101:180
  weights[markers] <- weights[markers] * 2.5
  # Set expected mitochondrial fraction explicitly, independently of depth.
  mito_fraction <- if (j %in% high) 0.50 else runif(1, 0.03, 0.12)
  weights[is_mito] <- weights[is_mito] / sum(weights[is_mito]) * mito_fraction
  weights[!is_mito] <- weights[!is_mito] / sum(weights[!is_mito]) * (1 - mito_fraction)
  if (j %in% low) {
    # Deliberately shallow cells: exact small totals, still stochastic gene allocation.
    x[, j] <- as.vector(rmultinom(1, size = 80L + match(j, low) * 5L, prob = weights))
  } else {
    x[, j] <- rnbinom(ng, mu = weights * depth[j], size = 2)
  }
}
expected_issue <- rep("ordinary variation", nc)
expected_issue[low] <- "deliberately low depth"
expected_issue[high] <- "deliberately high mitochondrial fraction"
dir.create("data/synthetic", recursive = TRUE, showWarnings = FALSE)
# An RDS would take precedence over TSV in read_inputs; refuse an ambiguous rerun.
if (file.exists("data/synthetic/counts.rds"))
  stop("Move data/synthetic/counts.rds aside before recreating TSV practice inputs.")
write.table(data.frame(gene_id = genes, x, check.names = FALSE),
            "data/synthetic/counts.tsv", sep = "\t", quote = FALSE, row.names = FALSE)
write_tsv(data.frame(cell_id = cells, sample_id = sample_id,
                     reference_label = population, simulation_note = expected_issue),
          "data/synthetic/cell-metadata.tsv")
write_tsv(data.frame(gene_id = genes, is_mito = is_mito), "data/synthetic/gene-metadata.tsv")
writeLines(c("Synthetic v2; seed 20261125; 1000 genes x 200 cells.",
 "Negative-binomial counts; log-normal library sizes and cell-specific variation.",
 "Genes 1:20 mitochondrial; 21:100 A markers; 101:180 B markers.",
 "Two simulated populations, four artificial sample labels, no treatment contrast.",
 paste("Low-depth cells:", paste(cells[low], collapse = ", ")),
 paste("High-mitochondrial cells:", paste(cells[high], collapse = ", ")),
 paste("Generated using", R.version.string),
 "Simulation labels are known construction settings, not biological discoveries.",
 "This is an educational simulation, not a fit to the Zeisel dataset."),
 "data/synthetic/provenance.txt")
cat("Created 1000 genes x 200 cells; seed 20261125. Rerun analysis before verification.\n")
