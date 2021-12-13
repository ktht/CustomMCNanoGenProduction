#!/bin/bash

SEED=$1;
NEVENTS=$2;
OUTPUT_DIR=$3;
GRIDPACK=$4;

if [[ -z "$SEED" ]] || [[ -z "$NEVENTS" ]] || [[ -z "$OUTPUT_DIR" ]] || [[ -z "$GRIDPACK" ]]; then
  echo "Not enought arguments";
  exit 1;
fi

if [ ! -d $OUTPUT_DIR ]; then
  echo "Output directory $OUTPUT_DIR does not exist";
  exit 1;
fi

TMP_ID=$SLURM_JOBID
if [ -z "$TMP_ID" ]; then
  TMP_ID=tmp;
fi

TMP_DIR=/scratch/$USER/$TMP_ID
mkdir -p $TMP_DIR
cd $TMP_DIR

OUTPUT=tree_$SEED.root
run_job.sh $SEED $NEVENTS $OUTPUT $GRIDPACK
cp -v $OUTPUT $OUTPUT_DIR

sleep 60
cd -
rm -f $TMP_DIR
