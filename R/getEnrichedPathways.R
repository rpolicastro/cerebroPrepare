#' Get enriched pathways based on marker genes from EnrichR.
#' @title Get enriched pathways based on marker genes from EnrichR.
#' @description This function uses the enrichR API to look for enriched pathways in marker gene sets of samples and clusters.
#' @param object Seurat object.
#' @param column_sample Column in object@meta.data that contains information about sample; defaults to "sample".
#' @param column_cluster Column in object@meta.data that contains information about cluster; defaults to "cluster".
#' @param databases Which databases to query. Use enrichR::listEnrichrDbs() to check what databases are available.
#' @param adj_p_cutoff Cut-off for adjusted p-value of enriched pathways; defaults to 0.05,
#' @param max_terms Save only first n entries of each database; defaults to 100.
#' @keywords seurat cerebro
#' @export
#' @import dplyr
#' @examples
#' getEnrichedPathways(object = seurat)
getEnrichedPathways <- function(
  object,
  column_sample = "sample",
  column_cluster = "cluster",
  databases = c(
    "GO_Biological_Process_2018",
    "GO_Cellular_Component_2018",
    "GO_Molecular_Function_2018",
    "KEGG_2016",
    "WikiPathways_2016",
    "Reactome_2016",
    "Panther_2016",
    "Human_Gene_Atlas",
    "Mouse_Gene_Atlas"
  ),
  adj_p_cutoff = 0.05,
  max_terms = 100
) {
  ##--------------------------------------------------------------------------##
  ## create backup of Seurat object (probably not necessary)
  ##--------------------------------------------------------------------------##
  temp_seurat <- object
  ##--------------------------------------------------------------------------##
  ## check if marker genes are present and stop if they aren't
  ##--------------------------------------------------------------------------##
  if ( is.null(temp_seurat@misc$marker_genes) ) {
    stop("Please run 'getMarkerGenes()' first.", call. = FALSE)
  }
  ##--------------------------------------------------------------------------##
  ## samples
  ## - check if marker genes by sample are available
  ## - get sample names
  ## - extract marker genes by sample
  ## - create slot for annotation if doesn't already exist
  ## - annotate marker genes for each sample in parallel
  ## - try up to three times to run enrichR annotation (fails sometimes)
  ## - filter results
  ##--------------------------------------------------------------------------##
  if ( !is.null(temp_seurat@misc$marker_genes$by_sample) ) {
    if ( is.data.frame(temp_seurat@misc$marker_genes$by_sample) ) {
      message("Get enriched pathway for samples...")
      #
      if ( is.factor(temp_seurat@meta.data[[column_sample]]) ) {
        sample_names <- levels(temp_seurat@meta.data[[column_sample]])
      } else {
        sample_names <- unique(temp_seurat@meta.data[[column_sample]])
      }
      #
      markers_by_sample <- temp_seurat@misc$marker_genes$by_sample
      #
      if ( is.null(temp_seurat@misc$marker_genes$by_sample_annotation) ) {
        temp_seurat@misc$marker_genes$by_sample_annotation <- list()
      }
      #
      temp_seurat@misc$marker_genes$by_sample_annotation <- future.apply::future_sapply(
        sample_names, USE.NAMES = TRUE, simplify = FALSE, future.globals = FALSE, function(x) {
        temp <- list()
        attempt <- 1
        while( length(temp) == 0 && !("Adjusted.P.value" %in% names(temp)) && attempt <= 3 ) {
          attempt <- attempt + 1
          try(
            temp <- markers_by_sample %>%
              filter(sample == x) %>%
              dplyr::select("gene") %>%
              t() %>%
              as.vector() %>%
              enrichr(databases = databases)
          )
        }
        #
        results_2 <- sapply(names(temp), USE.NAMES = TRUE, simplify = FALSE, function(y) {
          length <- temp[[y]] %>% filter(Adjusted.P.value <= adj_p_cutoff) %>% nrow()
          # if there are more than max_terms entries with an adjusted p-value of 1 or less...
          if ( length > max_terms ) {
            temp[[y]] %>% top_n(-max_terms, Adjusted.P.value)
          # if there is at least 1 entry with an adjusted p-value of 1 or less...
          } else if ( length > 0 ) {
            temp[[y]] %>% filter(Adjusted.P.value <= adj_p_cutoff)
          # remove the curent database
          } else {
            NULL
          }
        })
        for ( i in names(results_2) ) {
          if ( is.null(results_2[[i]]) ) {
            results_2[[i]] <- NULL
          }
        }
        results_2
      })
    } else if ( temp_seurat@misc$marker_genes$by_sample == "no_markers_found" ) {
      message("Skipping pathway enrichment for samples because no marker genes were identified for any sample.")
      temp_seurat@misc$marker_genes$by_sample_annotation <- "no_markers_found"
    } else {
      warning("Unexpected data format of marker genes for samples. Please submit an issue on GitHub: https://github.com/romanhaa/cerebroPrepare.")
    }
  } else {
    warning("No marker genes for samples available.")
  }
  ##--------------------------------------------------------------------------##
  ## clusters
  ## - check if marker genes by cluster are available
  ## - get cluster names
  ## - extract marker genes by cluster
  ## - create slot for annotation if doesn't already exist
  ## - annotate marker genes for each cluster in parallel
  ## - try up to three times to run enrichR annotation (fails sometimes)
  ## - filter results
  ##--------------------------------------------------------------------------##
  if ( !is.null(temp_seurat@misc$marker_genes$by_cluster) ) {
    if ( is.data.frame(temp_seurat@misc$marker_genes$by_cluster) ) {
      message("Get enriched pathway for clusters...")
      #
      if ( is.factor(temp_seurat@meta.data[[column_cluster]]) ) {
        cluster_names <- as.character(levels(temp_seurat@meta.data[[column_cluster]]))
      } else {
        cluster_names <- sort(unique(temp_seurat@meta.data[[column_cluster]]))
      }
      markers_by_cluster <- temp_seurat@misc$marker_genes$by_cluster
      if ( is.null(temp_seurat@misc$marker_genes$by_cluster_annotation) ) {
        temp_seurat@misc$marker_genes$by_cluster_annotation <- list()
      }
      #
      temp_seurat@misc$marker_genes$by_cluster_annotation <- future.apply::future_sapply(
        cluster_names, USE.NAMES = TRUE, simplify = FALSE, future.globals = FALSE, function(x) {
        temp <- list()
        attempt <- 1
        while( length(temp) == 0 && !("Adjusted.P.value" %in% names(temp)) && attempt <= 3 ) {
          attempt <- attempt + 1
          try(
            temp <- markers_by_cluster %>%
              filter(cluster == x) %>%
              dplyr::select("gene") %>%
              t() %>%
              as.vector() %>%
              enrichr(databases = databases)
          )
        }
        #
        results_2 <- sapply(names(temp), USE.NAMES = TRUE, simplify = FALSE, function(y) {
          length <- temp[[y]] %>% filter(Adjusted.P.value <= adj_p_cutoff) %>% nrow()
          # if there are more than max_terms entries with an adjusted p-value of 1 or less...
          if ( length > max_terms ) {
            temp[[y]] %>% top_n(-max_terms, Adjusted.P.value)
          # if there is at least 1 entry with an adjusted p-value of 1 or less...
          } else if ( length > 0 ) {
            temp[[y]] %>% filter(Adjusted.P.value <= adj_p_cutoff)
          # remove the curent database
          } else {
            NULL
          }
        })
        for ( i in names(results_2) ) {
          if ( is.null(results_2[[i]]) ) {
            results_2[[i]] <- NULL
          }
        }
        results_2
      })
    } else if ( temp_seurat@misc$marker_genes$by_cluster == "no_markers_found" ) {
      message("Skipping pathway enrichment for cluster because no marker genes were identified for any cluster.")
      temp_seurat@misc$marker_genes$by_clusters_annotation <- "no_markers_found"
    } else {
      warning("Unexpected data format of marker genes for clusters. Please submit an issue on GitHub: https://github.com/romanhaa/cerebroPrepare.")
    }
  } else {
    warning("No marker genes for clusters available.")
  }
  ##--------------------------------------------------------------------------##
  ##
  ##--------------------------------------------------------------------------##
  temp_seurat@misc$marker_genes$parameters_annotation <- list(
    databases = databases,
    adj_p_cutoff = adj_p_cutoff,
    max_terms = max_terms
  )
  ##--------------------------------------------------------------------------##
  ## return Seurat object
  ##--------------------------------------------------------------------------##
  return(temp_seurat)
}


#' Gene enrichment using Enrichr.
#' @title Gene enrichment using Enrichr.
#' @description Gene enrichment using Enrichr.
#' @param genes Character vector of gene names or dataframe of gene names in 
#' first column and a score between 0 and 1 in the other.
#' @param databases Character vector of databases to search.
#' See http://amp.pharm.mssm.edu/Enrichr/ for available databases.
#' @return Returns a data frame of enrichment terms, p-values, ...
#' @author Wajid Jawaid
enrichr <- function(
  genes,
  databases = NULL
) {
  if (is.vector(genes) & ! all(genes == "") & length(genes) != 0) {
    temp <- httr::POST(
      url="http://amp.pharm.mssm.edu/Enrichr/enrich",
      body=list(list=paste(genes, collapse="\n"))
    )
  } else if (is.data.frame(genes)) {
    temp <- httr::POST(
      url="http://amp.pharm.mssm.edu/Enrichr/enrich",
      body=list(list=paste(paste(genes[,1], genes[,2], sep=","), collapse="\n"))
    )
  } else {
    warning("genes must be a non-empty vector of gene names or a dataframe with genes and score.")
  }
  httr::GET(url = "http://amp.pharm.mssm.edu/Enrichr/share")
  dfSAF <- options()$stringsAsFactors
  options(stringsAsFactors = FALSE)
  result <- future.apply::future_sapply(databases, USE.NAMES = TRUE, simplify = FALSE, function(x) {
    r <- httr::GET(
      url = "http://amp.pharm.mssm.edu/Enrichr/export",
      query = list(file = "API", backgroundType = x)
    )
    r <- gsub("&#39;", "'", intToUtf8(r$content))
    tc <- textConnection(r)
    r <- read.table(tc, sep = "\t", header = TRUE, quote = "", comment.char = "")
    close(tc)
    return(r)
  })
  options(stringsAsFactors = dfSAF)
  return(result)
}
