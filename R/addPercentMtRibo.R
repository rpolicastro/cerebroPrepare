#' Add percentage of mitochondrial and ribosomal transcripts.
#' @title Add percentage of mitochondrial and ribosomal transcripts.
#' @description Get percentage of transcripts of gene list compared to all transcripts per cell.
#' @param object Seurat object.
#' @param organism Organism, can be either human ("hg") or mouse ("mm"). Genes need to annotated as gene symbol, e.g. MKI67 (human) / Mki67 (mouse).
#' @param gene_nomenclature Define if genes are saved by their name ('name'), ENSEMBL ID ('ensembl') or GENCODE ID ('gencode_v27', 'gencode_vM16').
#' @keywords seurat cerebro
#' @export
#' @import dplyr
#' @import readr
#' @import Seurat
#' @examples
#' calculatePercentGenes(object = seurat, genes = gene_list)
addPercentMtRibo <- function(
  object,
  organism,
  gene_nomenclature
) {
  ##--------------------------------------------------------------------------##
  ## check if organism is supported
  ##--------------------------------------------------------------------------##
  supported_organisms <- c("hg","mm")
  if ( !(organism %in% supported_organisms) ) {
    stop(
      paste0(
        "User-specified organism ('", organism ,
        "') not in list of supported organisms: ",
        paste(supported_organisms, collapse = ", ")
      )
    )
  }
  supported_nomenclatures <- c("name","ensembl","gencode_v27","gencode_vM16")
  if ( !(gene_nomenclature %in% supported_nomenclatures) ) {
    stop(
      paste0(
        "User-specified gene nomenclature ('", gene_nomenclature,
        "') not in list of supported nomenclatures: ",
        paste(supported_nomenclatures, collapse = ", ")
      )
    )
  }
  ##--------------------------------------------------------------------------##
  ## load mitochondrial and ribosomal gene lists from extdata
  ##--------------------------------------------------------------------------##
  genes_mt <- readr::read_tsv(
      system.file(
        "extdata",
        paste0("genes_mt_", organism, "_", gene_nomenclature, ".txt"),
        package = "cerebroPrepare"
      ),
      col_types = cols(),
      col_names = FALSE
    ) %>%
    dplyr::select(1) %>%
    t() %>%
    as.vector()
  genes_ribo <- readr::read_tsv(
      system.file(
        "extdata",
        paste0("genes_ribo_", organism, "_", gene_nomenclature, ".txt"),
        package = "cerebroPrepare"
      ),
      col_types = cols(),
      col_names = FALSE
    ) %>%
    dplyr::select(1) %>%
    t() %>%
    as.vector()
  ##--------------------------------------------------------------------------##
  ## keep only genes that are present in data set
  ##--------------------------------------------------------------------------##
  if ( object@version < 3 ) {
    genes_mt_here <- intersect(genes_mt, rownames(object@raw.data))
    genes_ribo_here <- intersect(genes_ribo, rownames(object@raw.data))
  } else {
    genes_mt_here <- intersect(genes_mt, rownames(object@assays$RNA@counts))
    genes_ribo_here <- intersect(genes_ribo, rownames(object@assays$RNA@counts))
  }
  ##--------------------------------------------------------------------------##
  ## save gene lists in Seurat object and create place if not existing yet
  ##--------------------------------------------------------------------------##
  if ( is.null(object@misc$gene_lists) ) {
    object@misc$gene_lists <- list()
  }
  object@misc$gene_lists$mitochondrial_genes <- genes_mt_here
  object@misc$gene_lists$ribosomal_genes <- genes_ribo_here
  ##--------------------------------------------------------------------------##
  ## calculate percentage of transcripts for mitochondrial and ribosomal genes
  ##--------------------------------------------------------------------------##
  message("Calculate percentage of mitochondrial and ribosomal transcripts...")
  values <- cerebroPrepare::calculatePercentGenes(
    object,
    list(
      "genes_mt" = genes_mt_here,
      "genes_ribo" = genes_ribo_here
    )
  )
  ##--------------------------------------------------------------------------##
  ## add results to Seurat object
  ##--------------------------------------------------------------------------##
  if ( object@version < 3 ) {
    object <- Seurat::AddMetaData(
      object,
      data.frame(
        row.names = colnames(object@raw.data),
        "percent_mt" = values[["genes_mt"]],
        "percent_ribo" = values[["genes_ribo"]]
      )
    )
  } else {
    object$percent_mt <- values[["genes_mt"]]
    object$percent_ribo <- values[["genes_ribo"]]
  }
  ##--------------------------------------------------------------------------##
  ##
  ##--------------------------------------------------------------------------##
  return(object)
}









