
.isArray <- function(arr) is(arr, "tiledb_sparse") || is(arr, "tiledb_dense")
.assertArray <- function(arr) stopifnot(is(arr, "tiledb_sparse") || is(arr, "tiledb_dense"))

##' Test if TileDB Array has Metadata
##'
##' @param arr A TileDB Array object
##' @param key A character value describing a metadata key
##' @return A logical value indicating if the given key exists in the
##'   metdata of the given array
##' @export
tiledb_has_metadata <- function(arr, key) {
  if (!is(arr, "tiledb_sparse") && !is(arr, "tiledb_dense")) {
    stop("Argument must be a TileDB (dense or sparse) array.", call.=FALSE)
  }

  ## Now deal with (default) case of an array object
  ## Check for 'is it open' ?
  if (!libtiledb_array_is_open_for_reading(arr@ptr)) {
    stop("Array is not open for reading, cannot access metadata.", call.=FALSE)
  }

  res <- libtiledb_array_get_metadata_list(arr@ptr)
  return(key %in% names(res))
}

##' Return count of TileDB Array Metadata objects
##'
##' @param arr A TileDB Array object, or a character URI describing one
##' @return A integer variable with the number of Metadata objects
##' @export
tiledb_num_metadata <- function(arr) {
  if (!is(arr, "tiledb_sparse") && !is(arr, "tiledb_dense")) {
    stop("Argument must be a TileDB (dense or sparse) array.", call.=FALSE)
  }

  ## Now deal with (default) case of an array object
  ## Check for 'is it open' ?
  if (!libtiledb_array_is_open_for_reading(arr@ptr)) {
    stop("Array is not open for reading, cannot access metadata.", call.=FALSE)
  }

  ## Run query
  return(libtiledb_array_get_metadata_num(arr@ptr))
}

##' Return a TileDB Array Metadata object given by key
##'
##' @param arr A TileDB Array object, or a character URI describing one
##' @param key A character value describing a metadata key
##' @return A object stored in the Metadata under the given key,
##' or \sQuote{NULL} if none found.
##' @export
tiledb_get_metadata <- function(arr, key) {
  if (!is(arr, "tiledb_sparse") && !is(arr, "tiledb_dense")) {
    stop("Argument must be a TileDB (dense or sparse) array.", call.=FALSE)
  }

  ## Now deal with (default) case of an array object
  ## Check for 'is it open' ?
  if (!libtiledb_array_is_open_for_reading(arr@ptr)) {
    stop("Array is not open for reading, cannot access metadata.", call.=FALSE)
  }

  res <- libtiledb_array_get_metadata_list(arr@ptr)
  if (key %in% names(res))
    return(res[[key]])
  else
    return(NULL)
}

##' Store an object in TileDB Array Metadata under given key
##'
##' @param arr A TileDB Array object, or a character URI describing one
##' @param key A character value describing a metadata key
##' @param val An object to be store
##' @return A boolean value indicating success
##' @export
tiledb_put_metadata <- function(arr, key, val) {
  if (!is(arr, "tiledb_sparse") && !is(arr, "tiledb_dense")) {
    stop("Argument must be a TileDB (dense or sparse) array.", call.=FALSE)
  }

  ## Now deal with (default) case of an array object
  ## Check for 'is it open' ?
  if (!libtiledb_array_is_open_for_writing(arr@ptr)) {
    stop("Array is not open for writing, cannot access metadata.", call.=FALSE)
  }

  ## Run query
  return(libtiledb_array_put_metadata(arr@ptr, key, val))
}


##' Return a TileDB Array Metadata object given by key
##'
##' @param arr A TileDB Array object, or a character URI describing one
##' @return A object stored in the Metadata under the given key
##' @export
tiledb_get_all_metadata <- function(arr) {
  if (!is(arr, "tiledb_sparse") && !is(arr, "tiledb_dense")) {
    stop("Argument must be a TileDB (dense or sparse) array.", call.=FALSE)
  }

  ## Now deal with (default) case of an array object
  ## Check for 'is it open' ?
  if (!libtiledb_array_is_open_for_reading(arr@ptr)) {
    stop("Array is not open for reading, cannot access metadata.", call.=FALSE)
  }

  ## Run query
  res <- libtiledb_array_get_metadata_list(arr@ptr)
  class(res) <- "tiledb_metadata"
  return(res)
}

##' @export
print.tiledb_metadata <- function(x, width=NULL, ...) {
  nm <- names(x)
  for (i in 1:length(nm)) {
    cat(nm[i], ":\t", format(x[i]), "\n", sep="")
  }
  invisible(x)
}

##' Delete a TileDB Array Metadata object given by key
##'
##' @param arr A TileDB Array object
##' @param key A character value describing a metadata key
##' @return A boolean indicating success
##' @export
tiledb_delete_metadata <- function(arr, key) {
  if (!is(arr, "tiledb_sparse") && !is(arr, "tiledb_dense")) {
    stop("ctx argument must be a TileDB (dense or sparse) array.", call.=FALSE)
  }

  ## Now deal with (default) case of an array object
  ## Check for 'is it open' ?
  if (!libtiledb_array_is_open_for_writing(arr@ptr)) {
    stop("Array is not open for writing, cannot access metadata.", call.=FALSE)
  }

  ## Run metadata removal
  libtiledb_array_delete_metadata(arr@ptr, key);
  invisible(TRUE)
}
