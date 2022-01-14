# Producing W+jets NanoGEN samples

## Gridpack generation

NB! Do the following in clean environment, no CMSSW:

```bash
cd $HOME
#git clone -b NanoGEN_WJets https://github.com/ktht/genproductions.git # using 2.6.5
git clone -b NanoGEN_WJets_HT_avgNorm https://github.com/ktht/genproductions.git # using 2.6.5
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

mkdir -p /hdfs/local/$USER/gridpacks/v0
cp *.tar.xz /hdfs/local/$USER/gridpacks/v0/.
ls /hdfs/local/$USER/gridpacks/v0/*.tar.xz | xargs -I {} gfal-copy file://{} gsiftp://$SERVER:$PORT/cms/store/user/$CRAB_USERNAME/gridpacks/v0
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

Run the jobs locally:

```bash
#submit_jobs.sh wjets   7000000 /hdfs/local/$USER/NanoGEN/prod ~/NanoGEN/log
#submit_jobs.sh w1jets 20000000 /hdfs/local/$USER/NanoGEN/prod ~/NanoGEN/log
#submit_jobs.sh w2jets 15000000 /hdfs/local/$USER/NanoGEN/prod ~/NanoGEN/log
#submit_jobs.sh w3jets 10000000 /hdfs/local/$USER/NanoGEN/prod ~/NanoGEN/log
#submit_jobs.sh w4jets  6000000 /hdfs/local/$USER/NanoGEN/prod ~/NanoGEN/log

#submit_jobs.sh wjets_ht70to100    6000000 /hdfs/local/$USER/NanoGEN/prod ~/NanoGEN/log
#submit_jobs.sh wjets_ht100to200   7500000 /hdfs/local/$USER/NanoGEN/prod ~/NanoGEN/log
submit_jobs.sh wjets_ht200to400   3000000 /hdfs/local/$USER/NanoGEN/prod ~/NanoGEN/log
submit_jobs.sh wjets_ht400to600    450000 /hdfs/local/$USER/NanoGEN/prod ~/NanoGEN/log
submit_jobs.sh wjets_ht600to800    100000 /hdfs/local/$USER/NanoGEN/prod ~/NanoGEN/log
submit_jobs.sh wjets_ht800to1200   100000 /hdfs/local/$USER/NanoGEN/prod ~/NanoGEN/log
submit_jobs.sh wjets_ht1200to2500  100000 /hdfs/local/$USER/NanoGEN/prod ~/NanoGEN/log
submit_jobs.sh wjets_ht2500toInf   100000 /hdfs/local/$USER/NanoGEN/prod ~/NanoGEN/log
``````

Or equivalently with CRAB:

```bash
./test/submit_crab.sh -s wjets  -n  7000000 -v v0
./test/submit_crab.sh -s w1jets -n 20000000 -v v0
./test/submit_crab.sh -s w2jets -n 15000000 -v v0
./test/submit_crab.sh -s w3jets -n 10000000 -v v0
./test/submit_crab.sh -s w4jets -n  6000000 -v v0

./test/submit_crab.sh -s wjets_ht70to100    -n 6000000 -v v0
./test/submit_crab.sh -s wjets_ht100to200   -n 7500000 -v v0
#./test/submit_crab.sh -s wjets_ht200to400   -n 3000000 -v v0
#./test/submit_crab.sh -s wjets_ht400to600   -n  450000 -v v0
#./test/submit_crab.sh -s wjets_ht600to800   -n  100000 -v v0
#./test/submit_crab.sh -s wjets_ht800to1200  -n  100000 -v v0
#./test/submit_crab.sh -s wjets_ht1200to2500 -n  100000 -v v0
#./test/submit_crab.sh -s wjets_ht2500toInf  -n  100000 -v v0
```

One job can generate up to 5000 events. This parameter is chosen such that the job can finish in
roughly a day. Interactive testing revealed that it takes about 6 s/event to run the sample
production (so about 8h for 5000 events) but it can double on a more modest hardware.

## Cross sections and statistics

In the following table:

- matching efficiency is computed by dividing cross section after the matching with cross section before the matching
- expected number of events is estimated by dividing the exclusive cross section to the inclusive cross section, times the expected number of events from the inclusive sample, times 10
- required number of events is what we need to generate, and derived by dividing the expected number of events with the matching efficiency

The expected number of events is an order of magnitude greater than what would be expected from
the same phase space region in the inclusive sample. Considering that we needed to estimate
the sample cross section accurately, a minimum of 100k events were requested for each sample.

<table>
<thead>
  <tr>
    <th>Sample</th>
    <th>Cross section<br>(before matching)</th>
    <th>Cross section<br>(after matching)</th>
    <th>Matching<br>efficiency</th>
    <th>Expected<br># events</th>
    <th>Previous<br># events</th>
    <th>Required<br># events</th>
    <th>Delievered<br># events</th>
  </tr>
</thead>
<tbody>
  <tr>
    <td>wjets</td>
    <td>1.206e+05</td>
    <td>5.416e+04</td>
    <td>0.45</td>
    <td>3e6</td>
    <td>3e6 (1x)</td>
    <td>6.7e6</td>
    <td>3.1e6</td>
  </tr>
  <tr>
    <td>w1jets</td>
    <td>3.038e+04</td>
    <td>8.919e+03</td>
    <td>0.3</td>
    <td>4.9e6</td>
    <td>5e5 (8.9x)</td>
    <td>1.6e7</td>
    <td>5.9e6</td>
  </tr>
  <tr>
    <td>w2jets</td>
    <td>1.828e+04</td>
    <td>2.829e+03</td>
    <td>0.15</td>
    <td>1.6e6</td>
    <td>3e5 (5.3x)</td>
    <td>1e7</td>
    <td>2.3e6</td>
  </tr>
  <tr>
    <td>w3jets</td>
    <td>1.097e+04</td>
    <td>8.255e+02</td>
    <td>0.075</td>
    <td>4.6e5</td>
    <td>2e5 (2.3x)</td>
    <td>6.1e6</td>
    <td>7.5e5</td>
  </tr>
  <tr>
    <td>w4jets</td>
    <td>6.505e+03</td>
    <td>3.901e+02</td>
    <td>0.06</td>
    <td>2.2e5</td>
    <td>1e5 (2.2x)</td>
    <td>3.7e6</td>
    <td>3.4e5</td>
  </tr>
  <tr>
    <td>wjets_ht70to100</td>
    <td>7.495e+03</td>
    <td>1.255e+03</td>
    <td>0.17</td>
    <td>7e5</td>
    <td>1e6 (0.7x)</td>
    <td>4.1e6</td>
    <td>9.5e5</td>
  </tr>
  <tr>
    <td>wjets_ht100to200</td>
    <td>9.344e+03</td>
    <td>1.243e+03</td>
    <td>0.13</td>
    <td>6.9e5</td>
    <td>1e6 (0.69x)</td>
    <td>5.3e6</td>
    <td>8.9e5</td>
  </tr>
  <tr>
    <td>wjets_ht200to400</td>
    <td>3.037e+03</td>
    <td>3.339e+02</td>
    <td>0.11</td>
    <td>1.9e5</td>
    <td>5e5 (0.38x)</td>
    <td>1.7e6</td>
    <td>3.3e5</td>
  </tr>
  <tr>
    <td>wjets_ht400to600</td>
    <td>4.578e+02</td>
    <td>4.516e+01</td>
    <td>0.10</td>
    <td>2.5e4</td>
    <td>2.5e5 (0.1x)</td>
    <td>2.5e5</td>
    <td>4.5e4</td>
  </tr>
  <tr>
    <td>wjets_ht600to800</td>
    <td>1.169e+02</td>
    <td>1.112e+01</td>
    <td>0.10</td>
    <td>6e3</td>
    <td>1e5 (0.06x)</td>
    <td>6.7e4</td>
    <td>9.2e3</td>
  </tr>
  <tr>
    <td>wjets_ht800to1200</td>
    <td>6.017e+01</td>
    <td>5.527e+00</td>
    <td>0.09</td>
    <td>3e3</td>
    <td>1e5 (0.03x)</td>
    <td>3.3e4</td>
    <td>9.1e3</td>
  </tr>
  <tr>
    <td>wjets_ht1200to2500</td>
    <td>2.062e+01</td>
    <td>1.850e+00</td>
    <td>0.09</td>
    <td>1e3</td>
    <td>1e5 (0.01x)</td>
    <td>1.1e4</td>
    <td>9.0e3</td>
  </tr>
  <tr>
    <td>wjets_ht2500toInf</td>
    <td>4.678e-01</td>
    <td>4.594e-02</td>
    <td>0.10</td>
    <td>2.5e1</td>
    <td>1e5 (~0x)</td>
    <td>1.6e2</td>
    <td>9.3e3</td>
  </tr>
  <tr>
    <td>Total</td>
    <td></td>
    <td></td>
    <td></td>
    <td><b>1.2e7</b></td>
    <td><b>7.3e5 (16x)</b></td>
    <td><b>5.4e7</b></td>
    <td><b>1.5e7</b></td>
  </tr>
</tbody>
</table>

## Post-processing

Done in two steps:

```bash
# 1) hadd the results, eg
for d in /hdfs/local/$USER/NanoGEN/prod/*; do hadd_results.sh $(basename $d)_hadded.root $d; done
# the second argument to hadd_results.sh can list multiple directories if needed
# (useful when hadding results from CRAB)

# 2) prune the Ntuples
for f in *_hadded.root; do prune_nanogen.py "${f%_hadded.root}_pruned.root" $f; done
```
