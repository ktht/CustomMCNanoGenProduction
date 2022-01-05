import FWCore.ParameterSet.Config as cms

def customizeNanoGEN(process):
  process.nanogenSequence = cms.Sequence(
    process.nanoMetadata+
    process.genJetTable+
    process.genWeightsTable+
    process.lheInfoTable
  )
  process.genJetTable.src = "ak4GenJetsNoNu"
  return process
