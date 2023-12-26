#! /bin/bash

WORKDIR='/pathTo/workDir/'
OUTDIR='/pathTo/outDir'
OUT_PREFIX='KIR_graphOut'
READ1='/pathTo/NK-WGL_R1_val_1.fq.gz'
READ2='/pathTo/NK-WGL_R2_val_2.fq.gz'
THREADS=16

cd $WORKDIR

#wget -c https://github.com/rcedgar/muscle/releases/download/5.1.0/muscle5.1.linux_intel64
#mv muscle5.1.linux_intel64 muscle
#echo "alias muscle=${WORKDIR}/muscle" >> ~/.bashrc
#source ~/.bashrc

#conda create -n KIR_typing python==3.12
#conda install -c "bioconda/label/cf201901" hisat2 -n KIR_typing
#conda install -c bioconda samtools -n KIR_typing
#conda install -c bioconda bwa -n KIR_typing
#conda install -c conda-forge docker -n KIR_typing
#conda install -c anaconda git -n KIR_typing

#conda activate KIR_typing

git clone https://github.com/linnil1/KIR_graph
cd KIR_graph
pip install .
graphkir --help

graphkir --thread $THREADS \
--r1 $READ1 \
--r2 $READ2 \
--output-folder $OUTDIR  \
--output-cohort-name ${OUTDIR}/${OUT_PREFIX}  \
--cn-3dl3-not-diploid 

echo "_____COPY NUMBER OUTPUT IN ${OUTDIR}/${OUT_PREFIX}.cn.tsv"
cat ${OUTDIR}/${OUT_PREFIX}.cn.tsv
echo " "
echo "_____ALLELE OUTPUT IN ${OUTDIR}/${OUT_PREFIX}.allele.tsv"
cat  ${OUTDIR}/${OUT_PREFIX}.allele.tsv
echo " "
echo "For references visit https://github.com/linnil1/KIR_graph"

