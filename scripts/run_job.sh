#!/bin/bash

set -x

SEED=$1;
NEVENTS=$2;
NEVENTS_PER_LUMIBLOCK=$3;
OUTPUT=$4;
GRIDPACK=$5;

if [[ -z "$SEED" ]] || \
   [[ -z "$NEVENTS" ]] || \
   [[ -z "$NEVENTS_PER_LUMIBLOCK" ]] || \
   [[ -z "$OUTPUT" ]] || \
   [[ -z "$GRIDPACK" ]]; then
  echo "Not enought arguments";
  exit 1;
fi

FIRST_EVENT=$(( $NEVENTS_PER_LUMIBLOCK * ($SEED - 1) + 1 ));

CUSTOM_CMDS="process.RandomNumberGeneratorService.externalLHEProducer.initialSeed=$SEED;";
CUSTOM_CMDS+="process.RandomNumberGeneratorService.generator.initialSeed=$SEED;";
CUSTOM_CMDS+="process.source.firstRun=cms.untracked.uint32(1);";
CUSTOM_CMDS+="process.source.firstLuminosityBlock=cms.untracked.uint32($SEED);";
CUSTOM_CMDS+="process.source.firstEvent=cms.untracked.uint32($FIRST_EVENT);";
CUSTOM_CMDS+="process.source.numberEventsInLuminosityBlock=cms.untracked.uint32($NEVENTS_PER_LUMIBLOCK);";
CUSTOM_CMDS+="process.externalLHEProducer.args=cms.vstring('$GRIDPACK');";
CUSTOM_CMDS+="from Configuration.CustomNanoGEN.customizeNanoGEN import customizeNanoGEN;";
CUSTOM_CMDS+="process = customizeNanoGEN(process);";

CFG=run.py

cmsDriver.py Configuration/CustomNanoGEN/python/fragment.py       \
  --fileout file:$OUTPUT --mc --eventcontent NANOAODGEN           \
  --datatier NANOAOD --conditions auto:mc --step LHE,GEN,NANOGEN  \
  --no_exec --python_filename=$CFG --number=$NEVENTS --nThreads=1 \
  --era Run2_2018 --customise_commands "$CUSTOM_CMDS";

/usr/bin/time --verbose cmsRun $CFG
rm -fv $CFG
