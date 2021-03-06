% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Attribute.R
\name{filter_list,tiledb_attr-method}
\alias{filter_list,tiledb_attr-method}
\title{Returns the \code{tiledb_filter_list} object associated with the given \code{tiledb_attr}}
\usage{
\S4method{filter_list}{tiledb_attr}(object)
}
\arguments{
\item{object}{tiledb_attr}
}
\value{
a tiledb_filter_list object
}
\description{
Returns the \code{tiledb_filter_list} object associated with the given \code{tiledb_attr}
}
\examples{
attr <- tiledb_attr(type = "INT32", filter_list=tiledb_filter_list(list(tiledb_filter("ZSTD"))))
filter_list(attr)

}
