#! /usr/bin/bash

# We can generate per chrom files with a loop like this to speed things up
# Feeding a list of chroms meta/test.chroms
# `bash $HOME/barra-lh/101.1-do.asso.sh $HOME/barra-lh/bamlists/test44.bamlist $HOME/barra-lh/meta/lates-lgs.txt  $HOME/barra-h/bamlists/test44.phenos`

# Generalized so that 1/2 of bamlist is specified for -minInd

bamlist=$1
list=$2
phenos=$3

#Setting minInd to 1/2 of inds
lines=$(wc -l < "$bamlist")
thresh=$((lines/2))

while read chrom; do
  echo "#!/bin/bash -l
  $HOME/angsd/angsd -P 12 -doAsso 1 -yBin $phenos -GL 1 -minInd $thresh  \
   -minMapQ 20 -minQ 20 \
  -doMajorMinor 1 -doMaf 1 -SNP_pval 1e-6 -r $chrom -out $chrom-asso \
  -bam $bamlist  > $chrom-asso.out 2> $chrom-asso.err " > $chrom-asso.sh
  
sbatch -p med -t 24:00:00 --mem=32G --nodes=1 --cpus-per-task=12 $chrom-asso.sh

done < $list