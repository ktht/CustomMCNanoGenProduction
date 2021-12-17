#!/bin/bash

set -x

jobId=$1;
gridpack=$2;
eventsPerLumi=$3;
maxEvents=$4;

eventsPerLumi_nr=$(echo $eventsPerLumi | sed 's/eventsPerLumi=//g');
maxEvents_nr=$(echo $maxEvents | sed 's/maxEvents=//g');

nEvents=$eventsPerLumi_nr;
nEvents_expected=$(( $jobId * $eventsPerLumi_nr ));
if [ $nEvents_expected -gt $maxEvents_nr ]; then
  nEvents=$(( $maxEvents_nr - ( $jobId - 1 ) * $eventsPerLumi_nr ))
fi

ls -lh

pset=run.py;
dumpFile=dumpFile.log;
commonArgs="seed=$jobId $gridpack $eventsPerLumi nEvents=$nEvents";

python $pset $commonArgs dumpFile=$dumpFile
if [ -f $dumpFile]; then
  cat $dumpFile;
else
  echo "File $dumpFile does not exist!";
fi

cmsRun -j FrameworkJobReport.xml $pset $commonArgs
