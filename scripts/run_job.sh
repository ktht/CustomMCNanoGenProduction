#!/bin/bash

SEED=$1;
NEVENTS=$2;
OUTPUT=$3;
GRIDPACK=$4;

if [[ -z "$SEED" ]] || [[ -z "$NEVENTS" ]] || [[ -z "$OUTPUT" ]] || [[ -z "$GRIDPACK" ]]; then
  echo "Not enought arguments";
  exit 1;
fi

CUSTOM_CMDS="process.RandomNumberGeneratorService.externalLHEProducer.initialSeed=$SEED;";
CUSTOM_CMDS+="process.RandomNumberGeneratorService.generator.initialSeed=$SEED;";
CUSTOM_CMDS+="process.externalLHEProducer.args=cms.vstring('$GRIDPACK');";

CFG=run.py

cmsDriver.py Configuration/CustomNanoGEN/python/fragment.py       \
  --fileout file:$OUTPUT --mc --eventcontent NANOAODGEN           \
  --datatier NANOAOD --conditions auto:mc --step LHE,GEN,NANOGEN  \
  --no_exec --python_filename=$CFG --number=$NEVENTS --nThreads=1 \
  --era Run2_2018 --customise_commands "$CUSTOM_CMDS";

cmsRun $CFG
rm -fv $CFG
