#!/bin/bash

jobId=$1;
gridpack=$2;
eventsPerLumi=$3;

# for debugging purposes
echo "================= Dumping PSet ===================="
python -c "import PSet; print PSet.process.dumpPython()"

# PSet.py should correspond to the tweaked PSet
cmsRun -j FrameworkJobReport.xml PSet.py seed=$jobId gridpack=$gridpack eventsPerLumi=$eventsPerLumi
