options(repos = c(CRAN = "https://cloud.r-project.org"))
if (!requireNamespace("renv", quietly = TRUE)) install.packages("renv")
if (file.exists("renv.lock")) {
  renv::restore(prompt = FALSE)
} else {
  renv::init(bare = TRUE, restart = FALSE)
  renv::install(c("BiocManager", "Matrix", "knitr", "rmarkdown"))
  BiocManager::install(c("scRNAseq", "SingleCellExperiment", "SummarizedExperiment"),
                       ask = FALSE, update = FALSE)
  renv::snapshot(type = "all", prompt = FALSE)
}
renv::status()
