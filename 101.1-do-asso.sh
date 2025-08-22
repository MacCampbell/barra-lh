#! /usr/bin/bash

# We can generate per chrom files with a loop like this to speed things up
# Feeding a list of chroms meta/test.chroms
# bash $HOME/shernook/202-do-asso.sh $HOME/shernook/bamlists/bamlist56.bamlist $HOME/shernook/meta/test.chroms $HOME/shernook/bamlists/bamlist56-early-late.pheno

# To do: generalize a bit more so that 1/2 of bamlist is specified for -minInd

bamlist=$1
list=$2
phenos=$3

#Setting minInd to 1/2 of inds
lines=$(wc -l < "$bamlist")
thresh=$((lines/2))

while read chrom; do
  echo "#!/bin/bash -l
  $HOME/angsd/angsd -doAsso 1 -yBin $phenos -GL 1 -nThreads 12 -minInd $thresh  \
   -minMapQ 20 -minQ 20 \
  -doMajorMinor 1 -doMaf 1 -SNP_pval 1e-6 -r $chrom -out $chrom-asso \
  -bam $bamlist  > $chrom-asso.out 2> $chrom-asso.err " > $chrom-asso.sh
  
sbatch -p high -t 48:00:00 --mem=32G --nodes=2 $chrom-asso.sh

done < $list