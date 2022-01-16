#!/bin/bash

# example (100k W+jets events):
# submit_jobs.sh wjets 100000 /hdfs/local/$USER/NanoGEN ~/log

SAMPLE=$1;
NEVENTS=$2;
OUTPUT_BASEDIR=$3;
LOG_BASEDIR=$4;
SKIP_TO=$5;
NEVENTS_PER_SAMPLE=5000;

if [ -z "${SKIP_TO}" ]; then
  SKIP_TO=1;
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

SAMPLE_NAME=${SAMPLES[${SAMPLE}]};
if [ -z "$SAMPLE_NAME" ]; then
  echo "Invalid sample name given, exiting";
  exit 1;
fi

if [[ "$SAMPLE_NAME" =~ .*HT.* ]]; then
  GRIDPACK_VERSION=v1;
else
  GRIDPACK_VERSION=v0;
fi;
GRIDPACK=/hdfs/local/$USER/gridpacks/${GRIDPACK_VERSION}/${SAMPLE_NAME}_slc7_amd64_gcc700_CMSSW_10_6_19_tarball.tar.xz
if [ ! -f "$GRIDPACK" ]; then
  echo "Gridpack missing: $GRIDPACK";
  exit 1;
fi

OUTPUT_DIR=$OUTPUT_BASEDIR/$SAMPLE;
mkdir -pv $OUTPUT_DIR;
LOG_DIR=$LOG_BASEDIR/$SAMPLE;
mkdir -pv $LOG_DIR;

NOF_JOBS=$(python -c "import math; print(int(math.ceil(float($NEVENTS) / $NEVENTS_PER_SAMPLE)))");
echo "Generating $NOF_JOBS job(s)";

NOF_EVENTS_LAST=$NEVENTS_PER_SAMPLE;
EXCESS=$(($NEVENTS - $NOF_JOBS * $NEVENTS_PER_SAMPLE));

if [ $NEVENTS -lt $NEVENTS_PER_SAMPLE ]; then
  NOF_EVENTS_LAST=$NEVENTS;
elif [ $EXCESS -lt 0 ]; then
  NOF_EVENTS_LAST=$(( $EXCESS + $NEVENTS_PER_SAMPLE ));
fi

if [ -z "$SBATCH_QUEUE" ]; then
  SBATCH_QUEUE=main;
fi

for i in `seq $SKIP_TO $NOF_JOBS`; do

  NOF_EVENTS=$NEVENTS_PER_SAMPLE;
  if [ "$i" == "$NOF_JOBS" ]; then
    NOF_EVENTS=$NOF_EVENTS_LAST;
  fi

  sbatch --partition=$SBATCH_QUEUE --output=$LOG_DIR/out_$i.log \
    job_wrapper.sh $i $NOF_EVENTS $NEVENTS_PER_SAMPLE $OUTPUT_DIR $GRIDPACK;
done
