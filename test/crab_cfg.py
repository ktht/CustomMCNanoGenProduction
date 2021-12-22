from CRABClient.UserUtilities import config, getUsernameFromCRIC

import os
import datetime

def test_positive_int(arg):
  return arg.isdigit() and int(arg) > 0

def get_env_var(env_var, fail_if_not_exists = True, test_type = None):
  if env_var not in os.environ:
    if fail_if_not_exists:
      raise ValueError("$%s not defined" % env_var)
    else:
      return ''
  env_val = os.environ[env_var]
  if test_type != None:
    assert(test_type(env_val))
  return env_val

NEVENTS_PER_JOB = get_env_var('NEVENTS_PER_JOB', test_type = test_positive_int)
NEVENTS         = get_env_var('NEVENTS', test_type = test_positive_int)
DATASET         = get_env_var('DATASET')
VERSION         = get_env_var('VERSION')
GRIDPACK        = get_env_var('GRIDPACK')
CMSSW_VERSION   = get_env_var('CMSSW_VERSION')

TODAY         = datetime.date.today().strftime("%Y%b%d")
THIS_FILE     = os.path.realpath(__file__)
THIS_DIR      = os.path.dirname(THIS_FILE)
PSET_LOC      = os.path.join(THIS_DIR, 'run.py')
SCRIPTEXE_LOC = os.path.join(THIS_DIR, 'run_crab.sh')
CRAB_LOC      = os.path.join(os.path.expanduser('~'), 'crab_projects')

if not os.path.isdir(CRAB_LOC):
  os.makedirs(CRAB_LOC)
assert(os.path.isfile(PSET_LOC))
assert(os.path.isfile(SCRIPTEXE_LOC))

ID           = '{}_{}_{}'.format(TODAY, DATASET, VERSION)
crabUserName = getUsernameFromCRIC()

config = config()

config.General.requestName     = ID
config.General.workArea        = CRAB_LOC
config.General.transferOutputs = True
config.General.transferLogs    = True

config.JobType.pluginName              = 'PrivateMC'
config.JobType.psetName                = PSET_LOC
config.JobType.scriptExe               = SCRIPTEXE_LOC
config.JobType.scriptArgs              = [
  'gridpack={}'.format(GRIDPACK),
  'eventsPerLumi={}'.format(NEVENTS_PER_JOB),
  'maxEvents={}'.format(NEVENTS),
  'cmssw={}'.format(CMSSW_VERSION),
]
config.JobType.allowUndistributedCMSSW = True
config.JobType.numCores                = 1
config.JobType.eventsPerLumi           = int(NEVENTS_PER_JOB)
config.JobType.inputFiles              = [ SCRIPTEXE_LOC, PSET_LOC ]
config.JobType.sendPythonFolder        = True

config.Site.storageSite          = 'T2_EE_Estonia'
config.Data.outputPrimaryDataset = DATASET
config.Data.splitting            = 'EventBased'
config.Data.unitsPerJob          = int(NEVENTS_PER_JOB)
config.Data.totalUnits           = int(NEVENTS)

config.Data.outLFNDirBase    = '/store/user/%s/NanoGEN/%s' % (crabUserName, VERSION)
config.Data.publication      = False
config.Data.outputDatasetTag = ID
