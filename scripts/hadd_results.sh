#!/bin/bash

# Usage: hadd_results.sh output.root input_dir_1 input_dir_2 .. input_dir_N
# You can use glob of course

output=$1;
shift;

NFILES=100;
SFX=.in.txt;

tmp_dir=tmp;
mkdir -pv $tmp_dir;
cd $tmp_dir;

file_list=files.txt;
echo "Creating the list of files";
for dirn in $@;do
  ls $dirn/*.root >> $file_list;
done

echo "Found $(wc -l $file_list | awk '{print $1}') file(s)";

split -l $NFILES files.txt  --additional-suffix=$SFX -d '';
echo "Split into $(ls *$SFX | wc -l) job(s)";

if [ ! -f haddnano.py ]; then
  wget -q https://raw.githubusercontent.com/cms-nanoAOD/nanoAOD-tools/master/scripts/haddnano.py;
  chmod +x ./haddnano.py;
fi

out_files="$output "
for f in *$SFX; do
  out_file=$(basename ${f%%.*}).root;
  ./haddnano.py $out_file $(cat 00.in.txt | tr '\n' ' ');
  out_files+="$out_file "
done

./haddnano.py $out_files;
mv -v $output ..;

cd -
rm -rfv $tmp_dir;
