#!/bin/bash

# Modified version of GeneratorInterface/LHEInterface/data/run_generic_tarball_xrootd.sh
# Uses gfal-copy instead of xrdcp to copy the gridpack from an external server

echo "Architecture: ${SCRAM_ARCH}"
echo "CMSSW version: ${CMSSW_VERSION}"

set -e

echo "   ______________________________________     "

if [ $# -lt 1 ]; then
    echo "%MSG-ExternalLHEProducer-subprocess ERROR in external process. The gridpack path must be passed as an argument"
fi
if [[ $1 != "root://"* ]]; then
    echo "%MSG-ExternalLHEProducer-subprocess ERROR in external process. Path must have format root://<xrd_path>/<path>"
    exit 1
fi 

xrd_path=$1
gridpack=$(basename $xrd_path)

if [ -e $gridpack ]; then
    echo "%MSG-ExternalLHEProducer-subprocess WARNING: File $gridpack already exists, it will be overwritten."
    rm $gridpack
fi

echo "%MSG-ExternalLHEProducer-subprocess INFO: Copying gridpack $xrd_path locally using xrootd"
gfal-copy $xrd_path .

path=`pwd`/$gridpack
generic_script=/cvmfs/cms.cern.ch/${SCRAM_ARCH}/cms/cmssw/${CMSSW_VERSION}/src/GeneratorInterface/LHEInterface/data/run_generic_tarball_cvmfs.sh
. $generic_script $path ${@:2}
