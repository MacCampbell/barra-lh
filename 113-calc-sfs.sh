#!/bin/bash
#SBATCH -o outputs/113/calc_sfs-%j.out
#SBATCH --partition=bmh
#SBATCH --time=24:00:00


mkdir outputs/113
wc=$(wc -l meta/poplist | awk '{print $1}')
x=1
while [ $x -le $wc ]
do
	string="sed -n ${x}p meta/poplist"
	str=$($string)

	var=$(echo $str | awk -F"\t" '{print $1}')
	set -- $var
	pop=$1

echo "#!/bin/bash
#SBATCH --job-name=sfs${x}
#SBATCH -n 8
#SBATCH -N 1
#SBATCH --partition=bmh
#SBATCH --time=48:00:00
#SBATCH --output=outputs/113/${pop}-%j.slurmout

##############################################

#ls \${PWD}/1004_alignments/${pop}*_ss40k.bam | sed 's/_ss40k//' > 0011/${pop}.bamlist
#This isn't going to work, let's make our own pop.bamlists

nInd=\$(wc -l bamlists/${pop}.bamlist | awk '{print \$1}')
mInd=\$((\${nInd}/1.111))

#############################################
#Getting sites together (base) maccamp@farm:~/spineflower/0009$ cat selection.sites | perl -pe 's/_/:/g' > sites


angsd -b bamlists/${pop}.bamlist -anc genome/GCF_001640805.2_TLL_Latcal_v3_genomic.fna -ref genome/GCF_001640805.2_TLL_Latcal_v3_genomic.fna -out outputs/113/${pop} -uniqueOnly 1 -remove_bads 1 -only_proper_pairs 1 -baq 2 -GL 1 -doMajorMinor 1 -doMaf 1 -minInd $mInd -nind $nInd -minMapQ 20 -minQ 20 -doSaf 2 -nThreads 8 

#-rf 0009/sites

realSFS outputs/113/${pop}.saf.idx > outputs/113/${pop}.sfs

" > sfs_${pop}.sh

sbatch sfs_${pop}.sh
rm sfs_${pop}.sh

x=$(( $x + 1 ))
done