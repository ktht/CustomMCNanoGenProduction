#!/bin/bash

# example (100k W+jets events):
# submit_jobs.sh wjets 100000 /hdfs/local/$USER/NanoGEN ~/log

SAMPLE=$1;
NEVENTS=$2;
OUTPUT_BASEDIR=$3;
LOG_BASEDIR=$4;

if [ "$SAMPLE" == "wjets" ]; then
  SAMPLE_NAME="WJetsToLNu_13TeV-madgraphMLM-pythia8";
elif [ "$SAMPLE" == "w1jets" ]; then
  SAMPLE_NAME="W1JetsToLNu_13TeV-madgraphMLM-pythia8";
elif [ "$SAMPLE" == "w2jets" ]; then
  SAMPLE_NAME="W2JetsToLNu_13TeV-madgraphMLM-pythia8";
elif [ "$SAMPLE" == "w3jets" ]; then
  SAMPLE_NAME="W3JetsToLNu_13TeV-madgraphMLM-pythia8";
elif [ "$SAMPLE" == "w4jets" ]; then
  SAMPLE_NAME="W4JetsToLNu_13TeV-madgraphMLM-pythia8";
elif [ "$SAMPLE" == "wjets_ht70to100" ]; then
  SAMPLE_NAME="WJetsToLNu_HT-70to100";
elif [ "$SAMPLE" == "wjets_ht100to200" ]; then
  SAMPLE_NAME="WJetsToLNu_HT-100to200";
elif [ "$SAMPLE" == "wjets_ht200to400" ]; then
  SAMPLE_NAME="WJetsToLNu_HT-200to400";
elif [ "$SAMPLE" == "wjets_ht400to600" ]; then
  SAMPLE_NAME="WJetsToLNu_HT-400to600";
elif [ "$SAMPLE" == "wjets_ht600to800" ]; then
  SAMPLE_NAME="WJetsToLNu_HT-600to800";
elif [ "$SAMPLE" == "wjets_ht800to1200" ]; then
  SAMPLE_NAME="WJetsToLNu_HT-800to1200";
elif [ "$SAMPLE" == "wjets_ht1200to2500" ]; then
  SAMPLE_NAME="WJetsToLNu_HT-1200to2500";
elif [ "$SAMPLE" == "wjets_ht2500toInf" ]; then
  SAMPLE_NAME="WJetsToLNu_HT-2500toInf";
else
  echo "Invalid option: $SAMPLE";
  exit 1;
fi

GRIDPACK=/hdfs/local/$USER/gridpacks/${SAMPLE_NAME}_slc7_amd64_gcc700_CMSSW_10_6_19_tarball.tar.xz
if [ ! -f "$GRIDPACK" ]; then
  echo "Gridpack missing: $GRIDPACK";
  exit 1;
fi

OUTPUT_DIR=$OUTPUT_BASEDIR/$SAMPLE;
mkdir -pv $OUTPUT_DIR;
LOG_DIR=$LOG_BASEDIR/$SAMPLE;
mkdir -pv $LOG_DIR;

NEVENTS_PER_SAMPLE=5000;
NOF_JOBS=$(python -c "import math; print(int(math.ceil(float($NEVENTS) / $NEVENTS_PER_SAMPLE)))");
echo "Generating $NOF_JOBS job(s)";

NOF_EVENTS_LAST=$NEVENTS_PER_SAMPLE;
EXCESS=$(($NEVENTS - $NOF_JOBS * $NEVENTS_PER_SAMPLE));

if [ $NEVENTS -lt $NEVENTS_PER_SAMPLE ]; then
  NOF_EVENTS_LAST=$NEVENTS;
elif [ $EXCESS -lt 0 ]; then
  NOF_EVENTS_LAST=$(( $EXCESS + $NEVENTS_PER_SAMPLE ));
fi

for i in `seq 1 $NOF_JOBS`; do

  NOF_EVENTS=$NEVENTS_PER_SAMPLE;
  if [ "$i" == "$NOF_JOBS" ]; then
    NOF_EVENTS=$NOF_EVENTS_LAST;
  fi

  sbatch --partition=main --output=$LOG_DIR/out_$i.log \
    job_wrapper.sh $i $NOF_EVENTS $OUTPUT_DIR $GRIDPACK;
done
