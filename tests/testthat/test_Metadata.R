library(tiledb)
context("tiledb_metadata")

tmp <- tempfile()

unlink_and_create_simple <- function(tmp) {
  if (dir.exists(tmp)) unlink(tmp, recursive = TRUE, force = TRUE)
  dir.create(tmp, recursive = TRUE)

  dim <- tiledb_dim(domain = c(1L, 4L))
  dom <- tiledb_domain(c(dim))
  a1  <- tiledb_attr("a1", type = "INT32")
  a2  <- tiledb_attr("a2", type = "INT32")
  sch <- tiledb_array_schema(dom, c(a1, a2), sparse=TRUE)
  tiledb_array_create(tmp, sch)
  arr <- tiledb_sparse(tmp, as.data.frame=FALSE)

  arr
}

unlink_and_create_ptr <- function(tmp) {
  arr <- unlink_and_create_simple(tmp)

  arrW <- tiledb:::libtiledb_array_open(arr@ptr, "WRITE")
  tiledb:::put_metadata(arrW, "vec", c(1.1, 2.2, 3.3))
  arrW <- tiledb:::libtiledb_array_open(arr@ptr, "WRITE")
  tiledb:::put_metadata(arrW, "txt", "the quick brown fox")
  tiledb:::libtiledb_array_close(arrW)

  arrR <- tiledb:::libtiledb_array_open(arr@ptr, "READ")
  return(arrR)
}

## infrastructure
setup({
  # empty
})

teardown({
  if (dir.exists(tmp)) unlink(tmp, recursive = TRUE, force = TRUE)
})



test_that("Can check presence of metadata", {
  arr <- unlink_and_create_ptr(tmp)

  expect_error(tiledb:::has_metadata(NULL, ""))
  expect_false(tiledb:::has_metadata(arr, ""))
  expect_true(tiledb:::has_metadata(arr, "vec"))
  expect_true(tiledb:::has_metadata(arr, "txt"))

  unlink(tmp, recursive = TRUE, force = TRUE)
})

test_that("Can retrieve count of metadata", {
  arr <- unlink_and_create_ptr(tmp)

  expect_error(tiledb:::num_metadata(NULL))
  expect_equal(tiledb:::num_metadata(arr), 2L)

  unlink(tmp, recursive = TRUE, force = TRUE)
})

test_that("Can get metadata", {
  arr <- unlink_and_create_ptr(tmp)

  expect_error(tiledb:::get_metadata(NULL, ""))
  expect_equal(tiledb:::get_metadata(arr, ""), NULL)
  expect_equal(tiledb:::get_metadata(arr, "vec"), c(1.1, 2.2, 3.3))

  unlink(tmp, recursive = TRUE, force = TRUE)
})

test_that("Can put metadata", {
  arr <- unlink_and_create_ptr(tmp)

  tiledb:::libtiledb_array_close(arr)
  arrW <- tiledb:::libtiledb_array_open(arr, "WRITE")

  expect_true(tiledb:::put_metadata(arrW, "foo", "the quick brown fox"))
  expect_error(tiledb:::put_metadata(arrW, "foo", list(a=c(1,2,3), b=c("a", "b"))))

  tiledb:::libtiledb_array_close(arrW)

  unlink(tmp, recursive = TRUE, force = TRUE)
})

test_that("Can do round trip", {
  ## will use 'simpler' accessors to not have to flip between read and write
  arr <- unlink_and_create_simple(tmp)

  vec <- c(1.1, 2.2, 3.3)
  expect_true(tiledb:::put_metadata_simple(tmp, "dvec", vec))
  expect_equal(tiledb:::get_metadata_simple(tmp, "dvec"), vec)

  vec <- c(1L, 2L, 3L)
  expect_true(tiledb:::put_metadata_simple(tmp, "ivec", vec))
  expect_equal(tiledb:::get_metadata_simple(tmp, "ivec"), vec)

  vec <- "the quick brown fox"
  expect_true(tiledb:::put_metadata_simple(tmp, "char", vec))
  expect_equal(tiledb:::get_metadata_simple(tmp, "char"), vec)

  unlink(tmp, recursive = TRUE, force = TRUE)
})

test_that("Can get by index", {
  arr <- unlink_and_create_ptr(tmp)

  expect_error(tiledb:::get_metadata_from_index(NULL, ""))
  expect_error(tiledb:::get_metadata_from_index(arr, -1))
  expect_equal(tiledb:::get_metadata_from_index(arr, 0), "the quick brown fox")
  expect_equal(tiledb:::get_metadata_from_index(arr, 1), c(1.1, 2.2, 3.3))

  unlink(tmp, recursive = TRUE, force = TRUE)
})