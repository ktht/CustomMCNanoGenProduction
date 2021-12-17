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

# PSet.py should correspond to the tweaked PSet
cmsRun -j FrameworkJobReport.xml run.py seed=$jobId $gridpack $eventsPerLumi nEvents=$nEvents
