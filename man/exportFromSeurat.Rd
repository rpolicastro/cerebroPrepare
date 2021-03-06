% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/exportFromSeurat.R
\name{exportFromSeurat}
\alias{exportFromSeurat}
\title{Export Seurat object to Cerebro.}
\usage{
exportFromSeurat(object, file, experiment_name, organism,
  column_sample = "sample", column_cluster = "cluster",
  column_nUMI = "nUMI", column_nGene = "nGene",
  column_cell_cycle_seurat = NULL, column_cell_cycle_cyclone = NULL,
  add_all_meta_data = TRUE)
}
\arguments{
\item{object}{Seurat object.}

\item{file}{Where to save the output.}

\item{experiment_name}{Experiment name.}

\item{organism}{Organism, e.g. hg (human), mm (mouse), etc.}

\item{column_sample}{Column in object@meta.data that contains information about sample; defaults to "sample".}

\item{column_cluster}{Column in object@meta.data that contains information about cluster; defaults to "cluster".}

\item{column_nUMI}{Column in object@meta.data that contains information about number of transcripts per cell; defaults to "nUMI".}

\item{column_nGene}{Column in object@meta.data that contains information about number of expressed genes per cell; defaults to "nGene".}

\item{column_cell_cycle_seurat}{Optional column in object@meta.data that contains information about cell cycle phase based on Regev method (default of Seurat); defaults to NULL.}

\item{column_cell_cycle_cyclone}{Optional column in object@meta.data that contains information about cell cycle phase based on Cyclone method; defaults to NULL.}

\item{add_all_meta_data}{If set to TRUE, all further meta data columns will be extracted as well.}
}
\value{
Returns object to be saved and loaded in Cerebro.
}
\description{
This function allows to export a Seurat object to visualize in Cerebro.
}
\details{
Export Seurat object to Cerebro.
}
\examples{
exportFromSeurat(object = seurat, file = "PDX_patient_A.crb" experiment_name = "PDX_patient_A", organism = "hg")
}
\keyword{cerebro}
\keyword{seurat}
