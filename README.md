# Producing W+jets NanoGEN samples

## Gridpack generation

NB! Do the following in clean environment, no CMSSW:

```bash
cd $HOME
git clone https://github.com/ktht/genproductions.git # using 2.6.5
cd genproductions/bin/MadGraph5_aMCatNLO
```

Produce the gridpacks:

```bash
./gridpack_generation.sh WJetsToLNu_13TeV-madgraphMLM-pythia8  cards/production/2017/13TeV/WJetsToLNu/WJetsToLNu_13TeV-madgraphMLM-pythia8 slurm

./gridpack_generation.sh W1JetsToLNu_13TeV-madgraphMLM-pythia8 cards/production/2017/13TeV/WJetsToLNu/W1JetsToLNu_13TeV-madgraphMLM-pythia8 slurm
./gridpack_generation.sh W2JetsToLNu_13TeV-madgraphMLM-pythia8 cards/production/2017/13TeV/WJetsToLNu/W2JetsToLNu_13TeV-madgraphMLM-pythia8 slurm
./gridpack_generation.sh W3JetsToLNu_13TeV-madgraphMLM-pythia8 cards/production/2017/13TeV/WJetsToLNu/W3JetsToLNu_13TeV-madgraphMLM-pythia8 slurm
./gridpack_generation.sh W4JetsToLNu_13TeV-madgraphMLM-pythia8 cards/production/2017/13TeV/WJetsToLNu/W4JetsToLNu_13TeV-madgraphMLM-pythia8 slurm

./gridpack_generation.sh WJetsToLNu_HT-70to100    cards/production/2017/13TeV/WJets_HT_LO_MLM/WJetsToLNu_HT-70to100 slurm
./gridpack_generation.sh WJetsToLNu_HT-100to200   cards/production/2017/13TeV/WJets_HT_LO_MLM/WJetsToLNu_HT-100to200 slurm
./gridpack_generation.sh WJetsToLNu_HT-200to400   cards/production/2017/13TeV/WJets_HT_LO_MLM/WJetsToLNu_HT-200to400 slurm
./gridpack_generation.sh WJetsToLNu_HT-400to600   cards/production/2017/13TeV/WJets_HT_LO_MLM/WJetsToLNu_HT-400to600 slurm
./gridpack_generation.sh WJetsToLNu_HT-600to800   cards/production/2017/13TeV/WJets_HT_LO_MLM/WJetsToLNu_HT-600to800 slurm
./gridpack_generation.sh WJetsToLNu_HT-800to1200  cards/production/2017/13TeV/WJets_HT_LO_MLM/WJetsToLNu_HT-800to1200 slurm
./gridpack_generation.sh WJetsToLNu_HT-1200to2500 cards/production/2017/13TeV/WJets_HT_LO_MLM/WJetsToLNu_HT-1200to2500 slurm
./gridpack_generation.sh WJetsToLNu_HT-2500toInf  cards/production/2017/13TeV/WJets_HT_LO_MLM/WJetsToLNu_HT-2500toInf slurm

mkdir -p /hdfs/local/$USER/gridpacks
cp *.tar.xz /hdfs/local/$USER/gridpacks/.
```

## NanoGEN production

Set up CMSSW:

```bash
cd $HOME
source /cvmfs/cms.cern.ch/cmsset_default.sh;
cmsrel CMSSW_10_6_19
cd $_/src
cmsenv
git clone https://github.com/ktht/CustomMCNanoGenProduction.git Configuration/CustomNanoGEN
scram b -j8
```

Run the jobs (TBD)
