#!/bin/bash

set -euxo pipefail

# Let us set the C++ Standard
sed -i '/CMAKE_CXX_STANDARD/d' CMakeLists.txt

export CXXFLAGS="-DPROTOBUF_USE_DLLS=1 ${CXXFLAGS}"

if [[ "${target_platform}" == osx-* ]]; then
    # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
    export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

# Workaround for https://github.com/conda-forge/gazebo-feedstock/pull/150
# Remove when boost is updated to 1.80.0
if [[ "${target_platform}" == "osx-64" ]]; then
  export CXXFLAGS="-DBOOST_ASIO_DISABLE_STD_ALIGNED_ALLOC ${CXXFLAGS}"
fi

# point to a usable protoc if we're running on a different architecture than the target
if [[ "${build_platform}" != "${target_platform}" ]]; then
    CMAKE_ARGS="${CMAKE_ARGS} -DProtobuf_PROTOC_EXECUTABLE=$BUILD_PREFIX/bin/protoc"
fi

cmake $CMAKE_ARGS \
    -DOPENSSL_ROOT_DIR=${PREFIX} \
    -DPROTOBUF_USE_DLLS=ON \
    -DBUILD_STATIC_LIB=OFF \
    -DCMAKE_CXX_STANDARD=17 \
    -DBUILD_TESTS=OFF \
    -GNinja \
    -B build
cmake --build build
cmake --install build
