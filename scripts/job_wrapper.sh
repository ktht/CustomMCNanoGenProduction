#!/bin/bash

echo "Host is: `hostname`"
echo "Date is: `date`"

SEED=$1;
NEVENTS=$2;
NEVENTS_PER_LUMIBLOCK=$3;
OUTPUT_DIR=$4;
GRIDPACK=$5;

if [[ -z "$SEED" ]] || \
   [[ -z "$NEVENTS" ]] || \
   [[ -z "$NEVENTS_PER_LUMIBLOCK" ]] || \
   [[ -z "$OUTPUT_DIR" ]] || \
   [[ -z "$GRIDPACK" ]]; then
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
mkdir -pv $TMP_DIR
cd $TMP_DIR

OUTPUT=tree_$SEED.root
run_job.sh $SEED $NEVENTS $NEVENTS_PER_LUMIBLOCK $OUTPUT $GRIDPACK
cp -v $OUTPUT $OUTPUT_DIR

sleep 60
cd -
rm -rfv $TMP_DIR
