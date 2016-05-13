#!/bin/bash

CUDA_LIB_DIR=/usr/local/cuda/lib
CUDA_VERSION=7.5
CUDA_LIBS="cublas cudart curand"

CUDNN_LIB_DIR=/opt/cuda/lib
CUDNN_VERSION=4
CUDNN_LIBS="cudnn"

HDF5_LIB_DIR=/Users/d0xy/anaconda/pkgs/hdf5-1.8.15.1-1/
HDF5_VERSION=hl.10
HDF5_LIBS="hdf5"

CAFFE_ROOT=${1:-.}

for x in $(find $CAFFE_ROOT/build/tools -name '*.bin' -o -name '*.so' -o -name '*.testbin'); do
    for lib in $CUDA_LIBS; do
        name=lib$lib.$CUDA_VERSION.dylib
        install_name_tool -change "@rpath/$name" "$CUDA_LIB_DIR/$name" $x
    done
    for lib in $CUDNN_LIBS; do
        name=lib$lib.$CUDNN_VERSION.dylib
        install_name_tool -change "@rpath/$name" "$CUDNN_LIB_DIR/$name" $x
    done
    for lib in $HDF5_LIBS; do
    	name=lib$lib_$HDF5_VERSION.dylib
    	install_name_tool -change "@rpath/$name" "$HDF5_LIB_DIR/$name" $x
    done
done