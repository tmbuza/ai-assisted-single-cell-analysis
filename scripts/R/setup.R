# Learners restore the maintainer-tested environment. Never snapshot here.
options(repos = c(CRAN = "https://cloud.r-project.org"))
if (!file.exists("_quarto.yml") || !dir.exists("scripts/R"))
  stop("Open the main ai-assisted-single-cell-analysis folder and run setup there.", call. = FALSE)
if (!file.exists("renv.lock"))
  stop("renv.lock is missing. Download the complete project or ask the guide maintainer for the tested lockfile. Setup has not installed or changed packages.", call. = FALSE)
if (!file.exists("renv/activate.R") || !file.exists(".Rprofile"))
  stop("The renv activation files are missing. Download the complete project, including .Rprofile and renv/activate.R.", call. = FALSE)
if (!requireNamespace("renv", quietly = TRUE)) install.packages("renv")
renv::load(project = getwd())
renv::settings$snapshot.type("all")
tryCatch(renv::restore(prompt = FALSE), error = function(e)
  stop("Environment restore failed: ", conditionMessage(e),
       "\nStop here. See Appendix > Installation troubleshooting. Do not snapshot a failed installation.", call. = FALSE))
required <- c("Matrix", "scRNAseq", "SingleCellExperiment", "SummarizedExperiment", "knitr", "rmarkdown")
missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) stop("Required packages cannot load: ", paste(missing, collapse = ", "),
                          ". Restore is incomplete; do not continue to analysis.", call. = FALSE)
s <- renv::status()
if (!isTRUE(s$synchronized)) stop("The environment is not synchronized. Read renv::status() before continuing.", call. = FALSE)
cat("Setup complete. Continue with the synthetic practice.\n")
