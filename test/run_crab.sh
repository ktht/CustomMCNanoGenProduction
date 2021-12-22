#!/bin/bash

set -x

jobId=$1;
gridpack=$2;
eventsPerLumi=$3;
maxEvents=$4;
cmssw=$5;

eventsPerLumi_nr=$(echo $eventsPerLumi | sed 's/eventsPerLumi=//g');
maxEvents_nr=$(echo $maxEvents | sed 's/maxEvents=//g');
cmssw_str=$(echo $cmssw | sed 's/cmssw=//g');

nEvents=$eventsPerLumi_nr;
nEvents_expected=$(( $jobId * $eventsPerLumi_nr ));
if [ $nEvents_expected -gt $maxEvents_nr ]; then
  nEvents=$(( $maxEvents_nr - ( $jobId - 1 ) * $eventsPerLumi_nr ))
fi

if [ -d $cmssw_str ]; then
  cd $cmssw_str/src;
  eval `scram runtime -sh`; # cmsenv
  scram b;
  cd -;
else
  echo "No directory named $cmssw_str in cwd:"
  ls -lh;
  exit 1;
fi;

pset=run.py;
dumpFile=dumpFile.log;
commonArgs="seed=$jobId $gridpack $eventsPerLumi nEvents=$nEvents";

python $pset $commonArgs dumpFile=$dumpFile
if [ -f $dumpFile ]; then
  cat $dumpFile;
else
  echo "File $dumpFile does not exist!";
fi

cmsRun -j FrameworkJobReport.xml $pset $commonArgs

ls -lh
