#include <tiledb/tiledb>
#include "Rcpp.h"

#ifndef __tiledb_h__
#define __tiledb_h__

using namespace Rcpp;

struct var_length_char_buffer {
  std::vector<uint64_t> offsets;  // vector for offset values
  std::string str;              	// string for data values
  int32_t rows, cols;             // dimension from subarray
};
typedef struct var_length_char_buffer vlc_buf_t;

// template <typename T>
// struct var_length_vec_buffer_initial {
//   std::vector<uint64_t> offsets;  // vector for offset values
//   std::vector<T> data;            // vector for data values
// };
// using vli_buf_t_old = struct var_length_vec_buffer_initial<int32_t>;
// using vld_buf_t_old = struct var_length_vec_buffer_initial<double>;

// THIS WORKS
// template <typename T>
// struct var_length_vec_buffer {
// public:
//   std::vector<uint64_t> offsets;  // vector for offset values
//   std::vector<T> data;            // vector for data values
// };
// using vli_buf_t = struct var_length_vec_buffer<int32_t>;
// using vld_buf_t = struct var_length_vec_buffer<double>;

struct var_length_vec_buffer {
public:
  std::vector<uint64_t> offsets;  // vector for offset values
  // cannot template as cannot have the template type in the C interface for created functions
  // void *dataptr;                  // vector for data values
  std::vector<int32_t> idata;        // vector for data values
  std::vector<double> ddata;         // vector for data values
  tiledb_datatype_t dtype;           // data type
};
typedef struct var_length_vec_buffer vlv_buf_t;


struct sparse_coords_buffer {
  //void *ptr;                    // pointer to data
  std::vector<int8_t> vec;        // vector of int8_t as a memory container
  tiledb_datatype_t dtype;        // data type
  R_xlen_t ncells;                // extent
  size_t size;                    // element size
};
typedef struct sparse_coords_buffer sp_crd_buf_t;


#endif // __tiledb_h__
