# Your own study inputs

Supply raw, nonnegative integer counts in `counts.tsv`: first column `gene_id`, other columns unique cell IDs. Rows are genes; columns are cells. Do not supply TPM, CPM or log-normalized values. An R matrix or Matrix object with both dimnames can instead be saved as `counts.rds`; that file takes priority if both exist.

Supply `cell-metadata.tsv` with `cell_id`, `sample_id`, `reference_label`. Use `unassigned` for unavailable labels. sample_id identifies the originating biological sample; separately add donor_id, condition and batch when known. A donor may contribute several samples. Check those relationships manually; the introductory script does not validate them.

Supply `gene-metadata.tsv` with `gene_id`, `is_mito` (TRUE/FALSE). Use a species- and identifier-matched annotation; never assume that Ensembl IDs start with MT-. Include every input gene exactly once.

All metadata IDs must match the count matrix exactly. Tab-separated UTF-8 files, no duplicate IDs or missing counts. For multi-library data, prefix barcodes consistently before merging. This dense practical stops above 20 million entries; use an appropriate sparse workflow for larger studies.

Do not commit identifiable participant metadata. The entire contents of this folder except this README are ignored.
