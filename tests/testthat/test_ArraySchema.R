library(testthat)
library(tiledb)

context("tiledb_array_schema")

test_that("tiledb_array_schema default constructor works", {
  d1  <- tiledb_dim(domain=c(1L, 100L))
  dom <- tiledb_domain(c(d1))
  a1  <- tiledb_attr(type = "FLOAT64")
  sch <- tiledb_array_schema(dom, c(a1))
  expect_is(sch, "tiledb_array_schema")
})

test_that("tiledb_array_schema default constructor arugment values are correct",  {
  d1  <- tiledb_dim(domain = c(1L, 100L))
  d2  <- tiledb_dim(domain = c(1L, 100L))
  dom <- tiledb_domain(c(d1, d2))
  a1  <- tiledb_attr(type = "FLOAT64")
  sch <- tiledb_array_schema(dom, c(a1))

  # test domain
  expect_is(domain(sch), "tiledb_domain")

  # test dimensions
  ds <- tiledb::dimensions(sch)
  expect_equal(length(ds), 2)
  expect_is(ds[[1]], "tiledb_dim")
  expect_is(ds[[2]], "tiledb_dim")

  # test attrs
  as <- tiledb::attrs(sch)
  expect_equal(length(as), 1)
  expect_is(as[[1]], "tiledb_attr")

  # test that default R schema is COL_MAJOR
  expect_equal(tiledb::cell_order(sch), "COL_MAJOR")
  expect_equal(tiledb::tile_order(sch), "COL_MAJOR")

  # test that the default R schema is dense
  expect_false(is.sparse(sch))
})

test_that("tiledb_array_schema full constructor argument values are correct",  {
  d1  <- tiledb_dim(domain = c(1L, 100L))
  d2  <- tiledb_dim(domain = c(1L, 100L))
  d3  <- tiledb_dim(domain = c(1L, 100L))

  dom <- tiledb_domain(c(d1, d2, d3))

  a1  <- tiledb_attr("attribute1", type = "FLOAT64")
  a2  <- tiledb_attr("attribute2", type = "INT32")

  sch <- tiledb_array_schema(dom, c(a1, a2),
                             cell_order = "ROW_MAJOR",
                             tile_order = "ROW_MAJOR",
                             coords_filter_list = tiledb_filter_list(c(tiledb_filter("GZIP"))),
                             offsets_filter_list = tiledb_filter_list(c(tiledb_filter("ZSTD"))),
                             sparse = TRUE
                             )

  # test domain
  expect_is(domain(sch), "tiledb_domain")

  # test dimensions
  ds <- tiledb::dimensions(sch)
  expect_equal(length(ds), 3)
  expect_is(ds[[1]], "tiledb_dim")
  expect_is(ds[[2]], "tiledb_dim")
  expect_is(ds[[3]], "tiledb_dim")

  # test attrs
  as <- tiledb::attrs(sch)
  expect_equal(length(as), 2)
  expect_equal(names(as), c("attribute1", "attribute2"))
  expect_is(as[[1]], "tiledb_attr")
  expect_is(as[[2]], "tiledb_attr")

  expect_equal(tiledb::cell_order(sch), "ROW_MAJOR")
  expect_equal(tiledb::tile_order(sch), "ROW_MAJOR")

  filter_list <- tiledb::filter_list(sch)
  expect_equal(tiledb_filter_type(filter_list[["coords"]][0]), "GZIP")
  expect_equal(tiledb_filter_get_option(filter_list[["coords"]][0], "COMPRESSION_LEVEL"), -1)
  expect_equal(tiledb_filter_type(filter_list[["offsets"]][0]), "ZSTD")
  expect_equal(tiledb_filter_get_option(filter_list[["offsets"]][0], "COMPRESSION_LEVEL"), -1)

  expect_true(is.sparse(sch))

  tiledb:::libtiledb_array_schema_set_capacity(sch@ptr, 100000)
  expect_equal(tiledb:::libtiledb_array_schema_get_capacity(sch@ptr), 100000)
  expect_error(tiledb:::libtiledb_array_schema_set_capacity(sch@ptr, -10))

})


test_that("tiledb_array_schema created with encryption",  {
  uri <- tempfile()
  key <- "0123456789abcdeF0123456789abcdeF"

  dom <- tiledb_domain(dims = c(tiledb_dim("rows", c(1L, 4L), 4L, "INT32"),
                                tiledb_dim("cols", c(1L, 4L), 4L, "INT32")))
  schema <- tiledb_array_schema(dom, attrs = c(tiledb_attr("a", type = "INT32")))

  ##tiledb_array_create_with_key(uri, schema, key)
  ## for now calling into function
  tiledb:::libtiledb_array_create_with_key(uri, schema@ptr, key)

  ctx <- tiledb_ctx()
  arrptr <- tiledb:::libtiledb_array_open_with_key(ctx@ptr, uri, "WRITE", key)
  A <- new("tiledb_dense", ctx=ctx, uri=uri, as.data.frame=FALSE, ptr=arrptr)

  expect_true(is(A, "tiledb_dense"))
  ##expect_true(is(schema(A), "tiledb_dense"))
  ## can't yet read / write as scheme getter not generalized for encryption
})
