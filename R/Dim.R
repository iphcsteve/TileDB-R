#' @exportClass Dim
setClass("Dim", 
         slots = list(ptr = "externalptr"))

Dim.from_ptr <- function(ptr) {
  if (missing(ptr) || typeof(ptr) != "externalptr" || is.null(ptr)) {
    stop("ptr argument must be a non NULL externalptr to a tiledb::Dim instance")
  }
  new("Dim", ptr = ptr)
}

#' @export Dim
Dim <- function(ctx, name="", domain, tile, type) {
  if (!is(ctx, "Ctx")) {
    stop("ctx argument must be a tiledb::Ctx")
  } else if (!is.scalar(name, "character")) {
    stop("name argument must be a scalar string")
  } else if ((typeof(domain) != "integer" && typeof(domain) != "double") 
             || (length(domain) != 2)) {
    stop("domain must be an integer or double vector of length 2")   
  } 
  if (missing(tile)) {
    if (is.integer(domain)) {
      tile <- 0L
    } else {
      tile <- 0.0
    }
  }
  if (missing(type)) {
    type <- "FLOAT64"
  } else if (type != "INT32" && type != "FLOAT64") {
    stop("type argument must be \"INT32\" or \"FLOAT64\"")
  }
  ptr <- tiledb_dim(ctx@ptr, name, type, domain, tile)
  new("Dim", ptr = ptr)
}

#setGeneric("name", function(object) standardGeneric("name"))

#' @export
setMethod("name", signature(object = "Dim"),
          function(object) {
            tiledb_dim_name(object@ptr)
          })

#' @export
setGeneric("domain", function(object) standardGeneric("domain"))

#' @export
setMethod("domain", signature(object = "Dim"),
          function(object) {
            tiledb_dim_domain(object@ptr)
          })

#' @export
setGeneric("tile", function(object) standardGeneric("tile"))

#' @export
setMethod("tile", signature(object = "Dim"),
          function(object) {
            tiledb_dim_tile_extent(object@ptr)
          })

#setGeneric("datatype", function(object) standardGeneric("datatype"))

#' @export
setMethod("datatype", signature(object = "Dim"),
          function(object) {
            tiledb_dim_datatype(object@ptr)
          })

#' @export
is.anonymous.Dim <- function(object) {
  name <- tiledb_dim_name(object@ptr)
  nchar(name) == 0
}