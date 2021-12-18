#!/usr/bin/env python

# Usage: prune_nanogen.py output.root input1.root input2.root .. inputN.root

import ROOT
import sys
import os.path
import array

ROOT.gROOT.SetBatch(True)

MAX_OBJS = 128

fn_out = sys.argv[1]
fns_in = sys.argv[2:]

if os.path.isfile(fn_out):
  raise RuntimeError("Remove the output file: %s" % fn_out)

f_out = ROOT.TFile.Open(fn_out, 'recreate')
t_out = ROOT.TTree('Events', 'Events')

genw_out = array.array('f', [0.])
lhe_ht_out = array.array('f', [0.])
lhe_njet_out = array.array('I', [0])
njet_out = array.array('I', [0])
lead_pt = array.array('f', [0.])
sublead_pt = array.array('f', [0.])
ht_vec = array.array('f', [0.])
ht_scalar = array.array('f', [0.])

t_out.Branch('genWeight', genw_out, 'genWeight/F')
t_out.Branch('LHE_HT', lhe_ht_out, 'LHE_HT/F')
t_out.Branch('LHE_Njets', lhe_njet_out, 'LHE_Njets/i')
t_out.Branch('nGenJet', njet_out, 'nGenJet/i')
t_out.Branch('GenJet_leadPt', lead_pt, 'GenJet_leadPt/F')
t_out.Branch('GenJet_subLeadPt', sublead_pt, 'GenJet_subLeadPt/F')
t_out.Branch('GenJet_HT_vector', ht_vec, 'GenJet_HT_vector/F')
t_out.Branch('GenJet_HT_scalar', ht_scalar, 'GenJet_HT_scalar/F')

for fn_in in fns_in:
  print('Pruning {}'.format(fn_in))
  f_in = ROOT.TFile.Open(fn_in, 'read')
  t_in = f_in.Get('Events')

  genw_in = array.array('f', [0.])
  lhe_ht_in = array.array('f', [0.])
  lhe_njet_in = array.array('I', [0])
  njet_in = array.array('I', [0])
  jet_pt = array.array('f', [0.] * MAX_OBJS)
  jet_eta = array.array('f', [0.] * MAX_OBJS)
  jet_phi = array.array('f', [0.] * MAX_OBJS)
  jet_mass = array.array('f', [0.] * MAX_OBJS)

  t_in.SetBranchAddress('genWeight', genw_in)
  t_in.SetBranchAddress('LHE_HT', lhe_ht_in)
  t_in.SetBranchAddress('LHE_Njets', lhe_njet_in)
  t_in.SetBranchAddress('nGenJet', njet_in)
  t_in.SetBranchAddress('GenJet_pt', jet_pt)
  t_in.SetBranchAddress('GenJet_eta', jet_eta)
  t_in.SetBranchAddress('GenJet_phi', jet_phi)
  t_in.SetBranchAddress('GenJet_mass', jet_mass)

  t_in.SetBranchStatus('*', 0)
  t_in.SetBranchStatus('genWeight', 1)
  t_in.SetBranchStatus('LHE_HT', 1)
  t_in.SetBranchStatus('LHE_Njets', 1)
  t_in.SetBranchStatus('nGenJet', 1)
  t_in.SetBranchStatus('GenJet_pt', 1)
  t_in.SetBranchStatus('GenJet_eta', 1)
  t_in.SetBranchStatus('GenJet_phi', 1)
  t_in.SetBranchStatus('GenJet_mass', 1)

  n = t_in.GetEntries()
  n10th = int(n / 10)
  n100th = int(n / 100)
  for i in range(n):
    t_in.GetEntry(i)
    if n > 1e5:
      if i % n100th == 0:
        sys.stdout.write('\r  .. {}%'.format(int(i / n100th)))
        sys.stdout.flush()
    elif n > 1e4:
      if i % n10th == 0:
        sys.stdout.write('\r  .. {}%'.format(int(i / n10th * 10)))
        sys.stdout.flush()

    genw_out[0] = genw_in[0]
    lhe_ht_out[0] = lhe_ht_in[0]
    lhe_njet_out[0] = lhe_njet_in[0]
    njet_out[0] = njet_in[0]

    lead_pt[0] = -1.
    sublead_pt[0] = -1.
    ht_vec[0] = -1.
    ht_scalar[0] = -1.

    jet_idxs = [ jet_idx for jet_idx in range(njet_in[0]) if jet_pt[jet_idx] > 25. and abs(jet_eta[jet_idx]) < 5. ]
    if jet_idxs:
      lead_pt[0] = jet_pt[jet_idxs[0]]
      if len(jet_idxs) > 1:
        sublead_pt[0] = jet_pt[jet_idxs[1]]
      ht_scalar[0] = sum(jet_pt[jet_idx] for jet_idx in jet_idxs)
      ht_p4 = ROOT.TLorentzVector()
      for jet_idx in jet_idxs:
        jet_p4 = ROOT.TLorentzVector()
        jet_p4.SetPtEtaPhiM(jet_pt[jet_idx], jet_eta[jet_idx], jet_phi[jet_idx], jet_mass[jet_idx])
        ht_p4 += jet_p4
      ht_vec[0] = ht_p4.Pt()

    t_out.Fill()
  f_in.Close()

f_out.cd()
t_out.Write()
f_out.Close()
sys.stdout.write('\r .. 100%\n')
