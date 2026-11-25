# Base-R helper: create a report starter, never overwrite learner writing.
a <- commandArgs(trailingOnly = TRUE)
if (length(a) != 1L || !a[1] %in% c("synthetic", "zeisel", "your-study"))
  stop("Usage: Rscript scripts/R/create_report.R synthetic|zeisel|your-study", call. = FALSE)
if (!file.exists("_quarto.yml") || !file.exists("templates/report.qmd"))
  stop("Run this command from the main project folder.", call. = FALSE)
dataset <- a[1]
labels <- c(synthetic = "Synthetic practice", zeisel = "Zeisel mouse brain", "your-study" = "Your own study")
dir.create("reports", showWarnings = FALSE)
config <- "reports/_quarto.yml"
if (!file.exists(config)) writeLines(c("project:", "  type: default", "  output-dir: ."), config)
path <- file.path("reports", paste0(dataset, "-report.qmd"))
if (file.exists(path)) {
  cat("Existing report kept:", path, "\n")
} else {
  content <- readLines("templates/report.qmd", warn = FALSE)
  content <- gsub("__DATASET__", dataset, content, fixed = TRUE)
  content <- gsub("__LABEL__", labels[[dataset]], content, fixed = TRUE)
  writeLines(content, path)
  cat("Created", path, "\n")
}
cat("Edit the report, then run: cd reports; quarto render", paste0(dataset, "-report.qmd"), "\n")
cat("After rendering, return to the main folder with: cd ..\n")
