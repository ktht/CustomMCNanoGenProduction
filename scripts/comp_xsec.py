#!/usr/bin/env python3

# Examples:
#
# comp_xsec.py /hdfs/cms/store/.../0000/log
# comp_xsec.py ~/NanoGEN/log/...
#
# The final cross section will be underlined

import argparse
import logging
import sys
import math
import os.path
import re
import tarfile

class SmartFormatter(argparse.HelpFormatter):
  def _split_lines(self, text, width):
    if text.startswith('R|'):
      return text[2:].splitlines()
    return argparse.HelpFormatter._split_lines(self, text, width)

parser = argparse.ArgumentParser(
  formatter_class = lambda prog: SmartFormatter(prog, max_help_position = 40),
)

parser.add_argument('-i', '--input', dest = 'input', metavar = 'directory', required = True, type = str,
                    help = 'R|Directory containing log files (tarballed or otherwise)')
parser.add_argument('-v', '--verbose', dest = 'verbose', action = 'store_true', default = False,
                    help = 'R|Enable verbose printout')
args = parser.parse_args()

logging.basicConfig(
  stream = sys.stdout,
  level  = logging.DEBUG if args.verbose else logging.INFO,
  format = '%(asctime)s - %(levelname)s: %(message)s'
)
if not os.path.isdir(args.input):
  raise RuntimeError("Not a directory: %s" % args.input)

TARFILE_PATTERN = re.compile('cmsRun_(?P<idx>\d+).log.tar.gz')

GENXSECANALYZER = 'GenXsecAnalyzer'
PROCESS = 'Process'
TACK = '-'

def get_str(s, is_bytes):
  return bytes(s, encoding = 'utf-8') if is_bytes else s

def extract_lines(fptr):
  found_xsec = False
  read_lines = False
  lines = []
  for line in fptr:
    is_bytes = type(line) == bytes
    if line.startswith(get_str(GENXSECANALYZER, is_bytes)):
      found_xsec = True
      continue
    if found_xsec and line.startswith(get_str(PROCESS, is_bytes)):
      read_lines = True
      continue
    if read_lines:
      if line.startswith(get_str(TACK, is_bytes)):
        break
      else:
        lines.append(line.strip())
  return lines

procs = {}
def parse_file(fn, file_idx):
  if not os.path.isfile(fn):
    raise RuntimeError("No such file: %s" % fn)
  logging.debug(f'Processing: {fn}')
  
  lines = None
  if fn.endswith('.log'):
    with open(fn, 'r') as f:
      lines = extract_lines(f)
  elif fn.endswith('.tar.gz'):
    with tarfile.open(fn, 'r:gz') as ftar:
      match_idx = re.match(TARFILE_PATTERN, os.path.basename(fn))
      assert(match_idx)
      idx = match_idx.group('idx')
      logname = f'cmsRun-stdout-{idx}.log'
      for member in ftar.getmembers():
        if member.name != logname:
          continue
        with ftar.extractfile(member) as logfile:
          lines = extract_lines(logfile)
        break
  else:
    raise RuntimeError("Invalid file: %s" % fn)

  assert(lines)
  for line in lines:
    line_split = line.split()
    assert(len(line_split) == 19)
    proc_id = int(line_split[0])
    if proc_id not in procs:
      procs[proc_id] = []
    procs[proc_id].append(
      {
        'file_idx' : file_idx,
        'xsec' : float(line_split[1]),
        'xsec_err' : float(line_split[3]),
        'N_passed_pos' : int(line_split[5]),
        'N_passed_neg' : int(line_split[6]),
        'N_tried_pos' : int(line_split[8]),
        'N_tried_neg' : int(line_split[9]),
        'xsec_err_match' : float(line_split[12]),
      }
    )

fns = []
for fn in os.listdir(args.input):
  if fn.endswith(('.log', '.tar.gz')):
    fns.append(os.path.join(args.input, fn))
nfiles = len(fns)
logging.debug(f'Found {nfiles} file(s)')

for file_idx, fn in enumerate(fns):
  parse_file(fn, file_idx)
nprocs = len(procs)
logging.debug(f'Found {nprocs} subprocess(es)')

def populate_dict(key):
  result = {}
  for proc_id in procs:
    available_file_idx = {
      procs[proc_id][file_idx]['file_idx'] : file_idx for file_idx in range(len(procs[proc_id]))
    }
    result[proc_id] = {
      file_idx : procs[proc_id][available_file_idx[file_idx]][key] if file_idx in available_file_idx else 0
      for file_idx in range(nfiles)
    }
  return result

N_tried_pos = populate_dict('N_tried_pos')
N_tried_neg = populate_dict('N_tried_neg')
N_passed_pos = populate_dict('N_passed_pos')
N_passed_neg = populate_dict('N_passed_neg')
xsec = populate_dict('xsec')
xsec_err = populate_dict('xsec_err')
xsec_err_match = populate_dict('xsec_err_match')

N_tried = {
  proc_idx : [ N_tried_pos[proc_idx][file_idx] - N_tried_neg[proc_idx][file_idx] for file_idx in range(nfiles) ]
  for proc_idx in range(nprocs)
}
N_passed = {
  proc_idx : [ N_passed_pos[proc_idx][file_idx] - N_passed_neg[proc_idx][file_idx] for file_idx in range(nfiles) ]
  for proc_idx in range(nprocs)
}

N_tried_per_proc = {
  proc_idx : sum(N_tried[proc_idx][file_idx] for file_idx in range(nfiles)) for proc_idx in range(nprocs)
}
N_passed_per_proc = {
  proc_idx : sum(N_passed[proc_idx][file_idx] for file_idx in range(nfiles)) for proc_idx in range(nprocs)
}

xsec_per_process = {
  proc_idx : sum(xsec[proc_idx][file_idx] * N_tried[proc_idx][file_idx] for file_idx in range(nfiles)) /
             sum(N_tried[proc_idx][file_idx] for file_idx in range(nfiles))
  for proc_idx in range(nprocs)
}
xsec_per_process_match = {
  proc_idx : xsec_per_process[proc_idx] * N_passed_per_proc[proc_idx] / N_tried_per_proc[proc_idx]
  for proc_idx in range(nprocs)
}
xsec_err_per_process = {
  proc_idx : math.sqrt(
    sum((xsec_err[proc_idx][file_idx] * N_tried[proc_idx][file_idx])**2 for file_idx in range(nfiles))
  ) / sum(N_tried[proc_idx][file_idx] for file_idx in range(nfiles))
  for proc_idx in range(nprocs)
}
xsec_err_per_process_match = {
  proc_idx : math.sqrt(
    sum((xsec_err_match[proc_idx][file_idx] * N_tried[proc_idx][file_idx])**2 for file_idx in range(nfiles))
  ) / sum(N_tried[proc_idx][file_idx] for file_idx in range(nfiles))
  for proc_idx in range(nprocs)
}

N_passed_per_process = { proc_idx : sum(N_passed[proc_idx]) for proc_idx in range(nprocs) }
N_tried_per_process = { proc_idx : sum(N_tried[proc_idx]) for proc_idx in range(nprocs) }

N_passed_final = sum(N_passed_per_proc[proc_idx] for proc_idx in range(nprocs))
N_tried_final = sum(N_tried_per_proc[proc_idx] for proc_idx in range(nprocs))

xsec_final = sum(xsec_per_process[proc_idx] for proc_idx in range(nprocs))
xsec_err_final = math.sqrt(sum(xsec_err_per_process[proc_idx]**2 for proc_idx in range(nprocs)))

xsec_match_final = sum(xsec_per_process_match[proc_idx] for proc_idx in range(nprocs))
xsec_err_match_final = math.sqrt(sum(xsec_err_per_process_match[proc_idx]**2 for proc_idx in range(nprocs)))

indent_passed = math.ceil(math.log10(N_passed_final))
indent_tried = math.ceil(math.log10(N_tried_final))
for proc_idx in range(nprocs):
  line = f'{proc_idx}: '
  line += f'xsec before = {xsec_per_process[proc_idx]:.3e} +/- {xsec_err_per_process[proc_idx]:.3e} '
  line += f'N(passed) = {N_passed_per_proc[proc_idx]:>{indent_passed}} '
  line += f'N(tried) = {N_tried_per_proc[proc_idx]:>{indent_tried}} '
  line += f'xsec after = {xsec_per_process_match[proc_idx]:.3e} +/- {xsec_err_per_process_match[proc_idx]:.3e}'
  print(line)
line = '>: '
line += f'xsec before = {xsec_final:.3e} +/- {xsec_err_final:.3e} '
line += f'N(passed) = {N_passed_final:>{indent_passed}} '
line += f'N(tried) = {N_tried_final:>{indent_tried}} '
line += 'xsec after = '
line_len = len(line)
line_append = f'{xsec_match_final:.3e} +/- {xsec_err_match_final:.3e}'
line += line_append
underline_len = len(line_append)

print(line)
print(' ' * line_len + '=' * underline_len)
