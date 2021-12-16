# Producing W+jets NanoGEN samples

## TODO

- CRAB submissions for larger productions (> 1-2k jobs)
- Parse logs to compute the cross sections

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

Run the jobs (matching efficiency and number of jobs in the comments):

```bash
submit_jobs.sh wjets   7000000 /hdfs/local/$USER/NanoGEN/prod ~/NanoGEN/log # ?%, 
submit_jobs.sh w1jets 20000000 /hdfs/local/$USER/NanoGEN/prod ~/NanoGEN/log # 24%, 4k
submit_jobs.sh w2jets 15000000 /hdfs/local/$USER/NanoGEN/prod ~/NanoGEN/log # 20%, 3k
submit_jobs.sh w3jets 10000000 /hdfs/local/$USER/NanoGEN/prod ~/NanoGEN/log # 8%, 2k
submit_jobs.sh w4jets  6000000 /hdfs/local/$USER/NanoGEN/prod ~/NanoGEN/log # 5.5%, 1.2k

submit_jobs.sh wjets_ht70to100    6000000 /hdfs/local/$USER/NanoGEN/prod ~/NanoGEN/log # ?%, 1.2k
submit_jobs.sh wjets_ht100to200   7500000 /hdfs/local/$USER/NanoGEN/prod ~/NanoGEN/log # 12.5%, 1.5k
submit_jobs.sh wjets_ht200to400   3000000 /hdfs/local/$USER/NanoGEN/prod ~/NanoGEN/log # 12.5%, 600
submit_jobs.sh wjets_ht400to600    450000 /hdfs/local/$USER/NanoGEN/prod ~/NanoGEN/log # 8%, 90
submit_jobs.sh wjets_ht600to800    100000 /hdfs/local/$USER/NanoGEN/prod ~/NanoGEN/log # 9.5%, 20
submit_jobs.sh wjets_ht800to1200   100000 /hdfs/local/$USER/NanoGEN/prod ~/NanoGEN/log # 7%, 20
submit_jobs.sh wjets_ht1200to2500  100000 /hdfs/local/$USER/NanoGEN/prod ~/NanoGEN/log # 6%, 20
submit_jobs.sh wjets_ht2500toInf   100000 /hdfs/local/$USER/NanoGEN/prod ~/NanoGEN/log # ?%, 20
``````

The number of requested events are estimated from FR2 pre-legacy samples, so the estimates can be off.
For instance, the `w4jets` sample has efficiency of about  0.08 in FR2, while preliminary efficiency
derived from the new gridpacks is around 0.055. Of course, this may be compensated by changes in
the cross section. However, it's not possible to compute the process cross section until the samples
have been produced with sufficient statistics.

In the following table:

- matching efficiency is computed by dividing cross section after the matching with cross section before the matching
- expected number of events is estimated by dividing the exclusive cross section to the inclusive cross section, times the expected number of events from the inclusive sample, times 10
- required number of events is what we need to generate, and derived by dividing the expected number of events with the matching efficiency
- number of jobs equals to the required number of events divided by the number of events processed by a single job.

The expected number of events is an order of magnitude greater than what would be expected from
the same phase space region in the inclusive sample. Considering that we need to account for up
to 50% more event statistics in some of the samples, and that we also need considerable amount of
statistics to estimate the sample cross section accurately, the required number of events shown
below really set the lower bound on how many events we really need to generate.

One job can generate up to 5000 events. This parameter is chosen such that the job can finish in
roughly a day. Interactive testing revealed that it takes about 6 s/event to run the sample
production (so about 8h for 5000 events) but it can double on a more modest hardware.

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
    <th># jobs</th>
  </tr>
</thead>
<tbody>
  <tr>
    <td>wjets</td>
    <td>1.127e+05</td>
    <td>5.274e+04</td>
    <td>0.47</td>
    <td>3e6</td>
    <td>3e6 (1x)</td>
    <td>6.4e6</td>
    <td>1283</td>
  </tr>
  <tr>
    <td>w1jets</td>
    <td>2.638e+04</td>
    <td>8.094e+03</td>
    <td>0.31</td>
    <td>4.6e6</td>
    <td>5e5 (9.2x)</td>
    <td>1.5e7</td>
    <td>3002</td>
  </tr>
  <tr>
    <td>w2jets</td>
    <td>1.737e+04</td>
    <td>2.788e+03</td>
    <td>0.16</td>
    <td>1.6e6</td>
    <td>3e5 (5.3x)</td>
    <td>9.9e6</td>
    <td>1977</td>
  </tr>
  <tr>
    <td>w3jets</td>
    <td>1.272e+04</td>
    <td>9.887e+02</td>
    <td>0.08</td>
    <td>5.6e5</td>
    <td>2e5 (2.8x)</td>
    <td>7.2e6</td>
    <td>1448</td>
  </tr>
  <tr>
    <td>w4jets</td>
    <td>6.783e+03</td>
    <td>5.435e+02</td>
    <td>0.08</td>
    <td>3.1e5</td>
    <td>1e5 (3.1x)</td>
    <td>3.9e6</td>
    <td>772</td>
  </tr>
  <tr>
    <td>wjets_ht70to100</td>
    <td>6.948e+03</td>
    <td>1.290e+03</td>
    <td>0.19</td>
    <td>7.3e5</td>
    <td>1e6 (0.73x)</td>
    <td>4e6</td>
    <td>791</td>
  </tr>
  <tr>
    <td>wjets_ht100to200</td>
    <td>9.224e+03</td>
    <td>1.393e+03</td>
    <td>0.15</td>
    <td>8e5</td>
    <td>1e6 (0.8x)</td>
    <td>5.2e6</td>
    <td>1050</td>
  </tr>
  <tr>
    <td>wjets_ht200to400</td>
    <td>3.179e+03</td>
    <td>4.097e+02</td>
    <td>0.13</td>
    <td>2.3e5</td>
    <td>5e5 (0.46x)</td>
    <td>1.8e6</td>
    <td>362</td>
  </tr>
  <tr>
    <td>wjets_ht400to600</td>
    <td>5.043e+02</td>
    <td>5.781e+01</td>
    <td>0.11</td>
    <td>3.3e4</td>
    <td>2.5e5 (0.13x)</td>
    <td>2.9e5</td>
    <td>58</td>
  </tr>
  <tr>
    <td>wjets_ht600to800</td>
    <td>1.142e+02</td>
    <td>1.294e+01</td>
    <td>0.11</td>
    <td>7.4e3</td>
    <td>1e5 (0.07x)</td>
    <td>6.5e4</td>
    <td>13</td>
  </tr>
  <tr>
    <td>wjets_ht800to1200</td>
    <td>5.070e+01</td>
    <td>5.454e+00</td>
    <td>0.11</td>
    <td>3.1e3</td>
    <td>1e5 (0.03x)</td>
    <td>2.9e4</td>
    <td>6</td>
  </tr>
  <tr>
    <td>wjets_ht1200to2500</td>
    <td>1.033e+01</td>
    <td>1.085e+00</td>
    <td>0.11</td>
    <td>6.2e2</td>
    <td>1e5 (0.01x)</td>
    <td>5.9e3</td>
    <td>2</td>
  </tr>
  <tr>
    <td>wjets_ht2500toInf</td>
    <td>6.858e-02</td>
    <td>8.062e-03</td>
    <td>0.12</td>
    <td>4.6e0</td>
    <td>1e5 (~0x)</td>
    <td>3.9e1</td>
    <td>1</td>
  </tr>
  <tr>
    <td><b>Total</b></td>
    <td></td>
    <td></td>
    <td></td>
    <td><b>1.2e7</b></td>
    <td><b>7.3e5 (16x)</b></td>
    <td><b>5.4e7</b></td>
    <td><b>10765</b></td>
  </tr>
</tbody>
</table>
