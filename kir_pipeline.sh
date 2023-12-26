#! /bin/bash

### // WGS ANALYSIS //

TRIMGALORE='/pathTo/trim_galore'
KPI='/pathTo/kpi/main.nf'
READ1='NK-WGL_R1_val_1.fq.gz'
READ2='NK-WGL_R2_val_2.fq.gz'
READ1RAW='/pathTo/NK-WGL_R1.fastq.gz'
READ2RAW='/pathTo/NK-WGL_R2.fastq.gz'

KIR_R1='KIR_r1.fq'
KIR_R2='KIR_r2.fq'
BAM2FASTQ='/pathTo/bamToFastq'
SAMTOOLS='/pathTo/samtools'
BWA='/pathTo/bwa'
BWA_INDEX='/pathTo/GRCh38.p14.genome.fa'
REF='/pathTo/GRCh38.p14.genome.fa'
KIR_BED='pathTo/KIRs.bed'
PICARD='/pathTo/picard.jar'
OUTDIR='/pathTo/output'
OUT_PREFIX='WGL_KIR'
THREADS=8
JAVA='pathTo/java'

# setting the desired work directory
WORKDIR='/pathToWorkDIR/'
cd $WORKDIR

# trimming reads for adapters
$TRIMGALORE --paired $READ1RAW $READ2RAW -o $OUTDIR

# aligning reads to reference
$BWA index $REF
$BWA mem $BWA_INDEX ${OUTDIR}/$READ1 ${OUTDIR}/$READ2 -o $OUTDIR/${OUT_PREFIX}.sam -t $THREADS 

# file processing
$SAMTOOLS view -bS $OUTDIR/${OUT_PREFIX}.sam -o $OUTDIR/${OUT_PREFIX}.bam -@ $THREADS
$SAMTOOLS sort  $OUTDIR/${OUT_PREFIX}.bam -o $OUTDIR/${OUT_PREFIX}.sorted.bam -@ $THREADS
$SAMTOOLS index $OUTDIR/${OUT_PREFIX}.bam -o $OUTDIR/${OUT_PREFIX}.sorted -@ $THREADS

# marking pcr duplicates
$JAVA -jar $PICARD MarkDuplicates I=$OUTDIR/${OUT_PREFIX}.sorted.bam O=$OUTDIR/${OUT_PREFIX}.sorted.dupRem.bam M=$OUTDIR/${OUT_PREFIX}.metrics.txt REMOVE_DUPlICATES=true AS=true
$JAVA -jar $PICARD AddOrReplaceReadGroups INPUT=$OUTDIR/${OUT_PREFIX}.deDupRG.bam  RGID=1 RGLB="$OUT_PREFIX" RGPL=Illumina RGPU=HISeq2500 RGSM="$OUT_PREFIX" RGCN=IBAB

# extracting kir locus specific reads
$SAMTOOLS view -L $KIR_BED $OUTDIR/${OUT_PREFIX}.deDupRG.bam -o $OUTDIR/${OUT_PREFIX}.KIR_locus.bam -@ $THREADS
$SAMTOOLS sort -n $OUTDIR/${OUT_PREFIX}.KIR_locus.bam -o $OUTDIR/${OUT_PREFIX}.sortedByReads.bam -@ $THREADS

$BAM2FASTQ -i $OUTDIR/${OUT_PREFIX}.sortedByReads.bam -fq $KIR_R1 -fq2 $KIR_R2

# running the KPI tool
echo -e "Knew""\t""${OUTDIR}""/""$KIR_R1" > $OUTDIR/Knew.txt 
echo -e "Knew""\t""${OUTDIR}""/""$KIR_R2" >> $OUTDIR/Knew.txt

$KPI --id Knew --map $OUTDIR/Knew.txt --output $OUTDIR

cat ${OUTDIR}/Knew_prediction.txt
sed 's/\t/,/g'${OUTDIR}/Knew_prediction.txt > ${OUTDIR}/Knew_prediction.csv
echo " "
echo "For references visit https://github.com/droeatumn/kpi"
