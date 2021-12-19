import FWCore.ParameterSet.Config as cms

def customizeNanoGEN(process):
  process.nanogenSequence = cms.Sequence(
    process.nanoMetadata+
    process.genJetTable+
    process.genWeightsTable+
    process.lheInfoTable
  )
  return process
