% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/getEnrichedPathways.R
\name{enrichr}
\alias{enrichr}
\title{Gene enrichment using Enrichr.}
\usage{
enrichr(genes, databases = NULL)
}
\arguments{
\item{genes}{Character vector of gene names or dataframe of gene names in 
first column and a score between 0 and 1 in the other.}

\item{databases}{Character vector of databases to search.
See http://amp.pharm.mssm.edu/Enrichr/ for available databases.}
}
\value{
Returns a data frame of enrichment terms, p-values, ...
}
\description{
Gene enrichment using Enrichr.
}
\details{
Gene enrichment using Enrichr.
}
\author{
Wajid Jawaid
}
