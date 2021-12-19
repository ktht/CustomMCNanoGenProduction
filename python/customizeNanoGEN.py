
def customizeNanoGEN(process):
  process.nanogenSequence.remove(process.rivetProducerHTXS)
  process.nanogenSequence.remove(process.particleLevelTables)
  return process
