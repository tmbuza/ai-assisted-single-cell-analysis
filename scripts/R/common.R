write_tsv <- function(x, path) write.table(x, path, sep = "\t", quote = FALSE,
                                          row.names = FALSE, na = "NA")
get_dataset <- function() {
  a <- commandArgs(trailingOnly = TRUE)
  if (!length(a) || !a[1] %in% c("synthetic", "zeisel", "your-study"))
    stop("Use synthetic, zeisel or your-study as the first argument.")
  a[1]
}
read_inputs <- function(dataset) {
  root <- file.path("data", dataset)
  read_tab <- function(name) read.delim(file.path(root, name), check.names = FALSE,
                                      stringsAsFactors = FALSE)
  if (file.exists(file.path(root, "counts.rds"))) {
    if (!requireNamespace("Matrix", quietly = TRUE)) stop("Install Matrix before reading RDS counts.")
    x <- readRDS(file.path(root, "counts.rds"))
  } else {
    tab <- read_tab("counts.tsv")
    if (names(tab)[1] != "gene_id") stop("First counts column must be gene_id.")
    x <- as.matrix(tab[-1]); rownames(x) <- tab[[1]]
  }
  if (length(dim(x)) != 2L || any(dim(x) == 0L)) stop("Counts must be a nonempty two-dimensional matrix.")
  # This deliberately bounded, dense teaching workflow is not a production pipeline.
  if (nrow(x) * ncol(x) > 2e7) stop("Input too large for this practical; use a sparse workflow.")
  x <- as.matrix(x)
  if (!is.numeric(x) || any(!is.finite(x)) || any(x < 0) || any(x != floor(x)))
    stop("Counts must be finite, nonnegative integers, not normalized expression.")
  valid_ids <- function(z) !is.null(z) && !anyNA(z) && all(nzchar(trimws(z))) && !anyDuplicated(z)
  if (!valid_ids(rownames(x)) || !valid_ids(colnames(x))) stop("Counts IDs missing or duplicated.")
  m <- read_tab("cell-metadata.tsv"); g <- read_tab("gene-metadata.tsv")
  if (!all(c("cell_id", "sample_id", "reference_label") %in% names(m)) ||
      !all(c("gene_id", "is_mito") %in% names(g))) stop("Required metadata columns missing.")
  if (!valid_ids(m$cell_id) || !valid_ids(g$gene_id) ||
      !setequal(m$cell_id, colnames(x)) || !setequal(g$gene_id, rownames(x)))
    stop("Metadata and matrix IDs must match exactly, without duplicates.")
  m <- m[match(colnames(x), m$cell_id), , drop = FALSE]
  g <- g[match(rownames(x), g$gene_id), , drop = FALSE]
  if (anyNA(m$sample_id) || any(!nzchar(trimws(m$sample_id)))) stop("sample_id missing.")
  if (!is.logical(g$is_mito) || anyNA(g$is_mito)) stop("is_mito must contain TRUE/FALSE.")
  if (!any(g$is_mito)) stop("No mitochondrial genes flagged; review gene annotation.")
  list(x = x, m = m, g = g)
}
