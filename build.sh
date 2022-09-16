#!/bin/bash
#
# Build dataframes for AIFM/Eden
#

set -e

SCRIPT_PATH=`realpath $0`
SCRIPT_DIR=`dirname ${SCRIPT_PATH}`
AIFMDIR=${SCRIPT_DIR}/../../other-systems/aifm/aifm

# parse cli
usage="bash $0 [args]\n
-a, --aifm \t build aifm too\n
-f, --force \t clean and recompile everything\n
-h, --help \t this usage information message\n"

for i in "$@"
do
case $i in
    -a|--aifm)
    AIFM=1
    ;;

    -f|--force)
    FORCE=1
    ;;

    -h | --help)
    echo -e $usage
    exit
    ;;

    *)                      # unknown option
    echo "Unknown Option: $i"
    echo -e $usage
    exit
    ;;
esac
done

if [[ $AIFM ]]; then
    # disable offloading in aifm
    CXXFLAGS="-DDISABLE_OFFLOAD_UNIQUE -DDISABLE_OFFLOAD_COPY_DATA_BY_IDX"
    CXXFLAGS="${CXXFLAGS} -DDISABLE_OFFLOAD_SHUFFLE_DATA_BY_IDX "
    CXXFLAGS="${CXXFLAGS} -DDISABLE_OFFLOAD_ASSIGN -DDISABLE_OFFLOAD_AGGREGATE"
    pushd ${AIFMDIR}
    make clean
    make CXXFLAGS="$CXXFLAGS" -j$(nproc)
    popd
fi

if [[ $FORCE ]]; then
    rm -rf ${SCRIPT_DIR}/build
fi

mkdir ${SCRIPT_DIR}/build || true
pushd ${SCRIPT_DIR}/build
cmake -E env CXXFLAGS="$CXXFLAGS" cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER=g++-9 ..
make -j
popd