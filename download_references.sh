#! /bin/bash


# setting the desired work directory
WORKDIR='/pathToWorkDIR/'
cd $WORKDIR

# downloading reference files
wget -c https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_44/gencode.v44.chr_patch_hapl_scaff.annotation.gtf.gz
gunzip gencode.v44.chr_patch_hapl_scaff.annotation.gtf.gz

wget -c https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_44/GRCh38.p14.genome.fa.gz
gunzip GRCh38.p14.genome.fa.gz

cat gencode.v44.chr_patch_hapl_scaff.annotation.gtf | sed 1,5d | awk '($3=="gene")'| cut -f1-3 -d ';'| sed 's/"\|;/\t/g'| sed 's/ \| //g'| grep "gene_name"| cut -f1,4,5,16 | grep "KIR[2-3]" > KIRs.bed

cat gencode.v44.chr_patch_hapl_scaff.annotation.gtf | sed 1,5d | awk '($3=="gene")'| cut -f1-3 -d ';'| sed 's/"\|;/\t/g'| sed 's/ \| //g'| grep "gene_name"| cut -f1,4,5,16  > genes.bed
