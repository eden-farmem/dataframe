#!/bin/bash
#
# Build dataframes for AIFM/Eden
#

set -e

SCRIPT_PATH=`realpath $0`
SCRIPT_DIR=`dirname ${SCRIPT_PATH}`

# parse cli
usage="bash $0 [args]\n
-f, --force \t clean and recompile everything\n
-h, --help \t this usage information message\n"

for i in "$@"
do
case $i in
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

if [[ $FORCE ]]; then
    rm -rf ${SCRIPT_DIR}/build
fi

mkdir ${SCRIPT_DIR}/build || true
pushd ${SCRIPT_DIR}/build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER=g++-9 ..
make -j
popd