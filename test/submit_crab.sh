#!/bin/bash

# Example: 100 W+jets events, 20 events per job
# submit_crab.sh -s wjets -n 100 -v test_v0 -j 20

echo "Checking if crab is available ..."
CRAB_AVAILABLE=$(which crab 2>/dev/null)
if [ -z "$CRAB_AVAILABLE" ]; then
  echo "crab not available! please do: source /cvmfs/cms.cern.ch/crab3/crab.sh"
  exit 1;
fi

echo "Checking if VOMS is available ..."
VOMS_PROXY_AVAILABLE=$(which voms-proxy-info 2>/dev/null)
if [ -z "$VOMS_PROXY_AVAILABLE" ]; then
  echo "VOMS proxy not available! please do: source /cvmfs/grid.cern.ch/glite/etc/profile.d/setup-ui-example.sh";
  exit 1;
fi

echo "Checking if VOMS is open long enough ..."
MIN_HOURSLEFT=72
MIN_TIMELEFT=$((3600 * $MIN_HOURSLEFT))
VOMS_PROXY_TIMELEFT=$(voms-proxy-info --timeleft)
if [ "$VOMS_PROXY_TIMELEFT" -lt "$MIN_TIMELEFT" ]; then
  echo "Less than $MIN_HOURSLEFT hours left for the proxy to be open: $VOMS_PROXY_TIMELEFT seconds";
  echo "Please update your proxy: voms-proxy-init -voms cms -valid 192:00";
  exit 1;
fi

declare -A SAMPLES;
SAMPLES["wjets"]="WJetsToLNu_13TeV-madgraphMLM-pythia8";
SAMPLES["w1jets"]="W1JetsToLNu_13TeV-madgraphMLM-pythia8";
SAMPLES["w2jets"]="W2JetsToLNu_13TeV-madgraphMLM-pythia8";
SAMPLES["w3jets"]="W3JetsToLNu_13TeV-madgraphMLM-pythia8";
SAMPLES["w4jets"]="W4JetsToLNu_13TeV-madgraphMLM-pythia8";
SAMPLES["wjets_ht70to100"]="WJetsToLNu_HT-70to100";
SAMPLES["wjets_ht100to200"]="WJetsToLNu_HT-100to200";
SAMPLES["wjets_ht200to400"]="WJetsToLNu_HT-200to400";
SAMPLES["wjets_ht400to600"]="WJetsToLNu_HT-400to600";
SAMPLES["wjets_ht600to800"]="WJetsToLNu_HT-600to800";
SAMPLES["wjets_ht800to1200"]="WJetsToLNu_HT-800to1200";
SAMPLES["wjets_ht1200to2500"]="WJetsToLNu_HT-1200to2500";
SAMPLES["wjets_ht2500toInf"]="WJetsToLNu_HT-2500toInf";

export NEVENTS_PER_JOB=5000;

DRYRUN="";
CRAB_CFG=$(realpath $(dirname "${BASH_SOURCE[0]}"))/crab_cfg.py

CRAB_USERNAME=$(crab checkusername | grep "^Username" | awk '{print $NF}')
PREFIX=gsiftp://ganymede.hep.kbfi.ee:2811/cms/store/user/${CRAB_USERNAME}/gridpacks;

show_help() {
  KEYS=$(echo $(for key in "${!SAMPLES[@]}"; do echo $key; done | sort | tr '\n' ',') | sed 's/,$//g' | sed 's/,/, /g');
  THIS_SCRIPT=$0;
  echo -ne "Usage: $(basename $THIS_SCRIPT) -s <sample>  -n nevents -v version " 1>&2;
  echo     "[-j <nof events per job> = $NEVENTS_PER_JOB] [-c $CRAB_CFG] [-d]" 1>&2;
  echo "Available samples: $KEYS"
  exit 0;
}

while getopts "h?ds:n:v:j:c:" opt; do
  case "${opt}" in
  h|\?) show_help
        ;;
  s) export DATASET=${SAMPLES[${OPTARG}]}
     ;;
  n) export NEVENTS=${OPTARG}
     ;;
  v) export VERSION=${OPTARG}
     ;;
  j) export NEVENTS_PER_JOB=${OPTARG}
     ;;
  c) CRAB_CFG=${OPTARG}
     ;;
  d) DRYRUN="--dryrun"
     ;;
  esac
done

if [ -z "$DATASET" ]; then
  echo "Invalid sample name given, exiting";
  exit 1;
fi

if [ ! -f "$CRAB_CFG" ]; then
  echo "No such CRAB config file: $CRAB_CFG";
fi

export GRIDPACK=${PREFIX}/${DATASET}_slc7_amd64_gcc700_CMSSW_10_6_19_tarball.tar.xz
echo "Testing if the gridpack is accessible"
LD_LIBRARY_PATH=${GLITE_LOCATION}/lib64:${GLITE_LOCATION}/lib gfal-ls $GRIDPACK
GRIDPACK_EXISTS=$?
if [ "$GRIDPACK_EXISTS" -gt 0 ]; then
  echo "Gridpack missing: $GRIDPACK";
  exit 1;
fi

echo "Submitting jobs with the following parameters:"
echo "Dataset: $DATASET"
echo "Number of events: $NEVENTS";
echo "Number of events per job: $NEVENTS_PER_JOB";
echo -ne "Dryrun: ";
if [ -z "$DRYRUN" ]; then echo "No"; else echo "Yes"; fi

read -p "Submitting jobs? [y/N]" -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
fi

crab submit $DRYRUN --config="$CRAB_CFG"
