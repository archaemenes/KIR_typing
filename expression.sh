#! /bin/bash

STAR='/pathTo/STAR'
PYTHON='/pathTo/python'
TPM_PY='/pathTo/tpm.py'
BEDTOOLS='/pathTo/bedtools'
SAMTOOLS='/pathTo/samtools'
THREADS=8
REF_DIR='/pathTo/refDir'
REF='/pathTo/GRCh38.p14.genome.fa'
GTF='/pathTo/gencode.v44.chr_patch_hapl_scaff.annotation.gtf'
READ1='NK-WGL_R1_val_1.fq.gz'
READ2='NK-WGL_R2_val_2.fq.gz'
OUTDIR='/pathTo/output'
OUT_PREFIX='TL_KIR'
GENES_BED='/pathTo/genes.bed'

READ2RAW='/pathTo/NK-TL_R2.fastq.gz'
READ1RAW='/pathTo/NK-TL_R1.fastq.gz'

# setting the desired work directory
WORKDIR='/pathToWorkDIR/'
cd $WORKDIR

# trimming reads for adapters
$TRIMGALORE --paired $READ1RAW $READ2RAW -o $OUTDIR

$STAR --runThreadN $THREADS \
 --runMode genomeGenerate  \
 --genomeDir $REF_DIR  \ 
 --genomeFastaFiles $REF  \ 
 --sjdbGTFfile $GTF  \
 --sjdbOverhang 99

$STAR --runMode alignReads \
--genomeDir $REF_DIR \
--runThreadN  $THREADS \
--readFilesCommand zcat \
--quantMode GeneCounts \
--readFilesIn ${OUTDIR}/$READ1 ${OUTDIR}/$READ2 \
--outFileNamePrefix ${OUTDIR}/${OUT_PREFIX}_ \
--outSAMtype BAM SortedByCoordinate \
--outSAMunmapped Within \
--outSAMattributes Standard

$SAMTOOLS index ${OUTDIR}/${OUT_PREFIX}_Aligned.sortedByCoord.out.bam -o ${OUTDIR}/${OUT_PREFIX}_Aligned.sortedByCoord.out -@ $THREADS
$BEDTOOLS multicov -bams ${OUTDIR}/${OUT_PREFIX}_Aligned.sortedByCoord.out.bam -bed $GENES_BED > ${OUTDIR}/${OUT_PREFIX}_readCount.tsv
 
echo -e "chr""\t""start""\t""end""\t""gene"  > header
cat header ${OUTDIR}/${OUT_PREFIX}_readCount.tsv > tmp && cp tmp ${OUTDIR}/${OUT_PREFIX}_readCount.tsv

$PYTHON $TPM_PY ${OUTDIR}/${OUT_PREFIX}_readCount.tsv ${OUTDIR}/${OUT_PREFIX}_allGenes_NormalizedByTPM.tsv

pip install numpy && pip install pandas && pip install os-sys && pip install syspath

# expression of top expressed KIRS
grep "KIR[2-3]" ${OUTDIR}/${OUT_PREFIX}_NormalizedByTPM.tsv | sort -k3,3nr | cut -f2- > ${OUTDIR}/${OUT_PREFIX}_onlyKIRs_NormalizedByTPM.tsv
