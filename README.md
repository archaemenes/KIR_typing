# KIR typing with KPI and KIR_graph
KIR typing using  KPI https://github.com/droeatumn/kpi and KIR_graph https://github.com/linnil1/KIR_graph for haplotypes, copy number and allele level resolution with paired end short read data.



## Download dependencies 

For **KPI** install Java, Groovy, Nextflow, Docker, and Git. Create accounts in GitHub and Docker Hub. Add 'docker.enabled = true' and 'docker.fixOwnership = true' to your Nexflow configuration at $HOME/.nextflow/config (refer [https://github.com/droeatumn/kpi](https://github.com/droeatumn/kpi))

For **KIR_graph** install python >= 3.10, muscle >= 5.1, histat2 >= 2.2.1, samtools >= 1.15.1, bwa-mem > 0.7.17 (refer [https://github.com/linnil1/KIR_graph](https://github.com/linnil1/KIR_graph))


## Choose workflows

You can choose between the two work flows KPI or KIR_graph
**KPI_pipeline.sh  for KPI** requires to run the scripts in the following order:

 

    bash download_refernces.sh 
    bash KPI_pipeline.sh 

Make sure to set the environmental variables as given in the scripts: 
 

    WORKDIR='/pathTo/workDir/'
    OUTDIR='/pathTo/outDir' 
    OUT_PREFIX='KIR_graphOut'
    READ1='/pathTo/NK-WGL_R1_val_1.fq.gz'
    READ2='/pathTo/NK-WGL_R2_val_2.fq.gz'
    THREADS=16

For the **KIR_GraphPipeline.sh for KIR_graph** requires to run the following scripts and set the environmental variables:

    cd $WORKDIR

    wget -c https://github.com/rcedgar/muscle/releases/download/5.1.0/muscle5.1.linux_intel64
    mv muscle5.1.linux_intel64 muscle
    echo "alias muscle=${WORKDIR}/muscle" >> ~/.bashrc
    source ~/.bashrc
    
    conda create -n KIR_typing python==3.12
    conda install -c "bioconda/label/cf201901" hisat2 -n KIR_typing
    conda install -c bioconda samtools -n KIR_typing
    conda install -c bioconda bwa -n KIR_typing
    conda install -c conda-forge docker -n KIR_typing
    conda install -c anaconda git -n KIR_typing
    conda activate KIR_typing
   
Run `bash KIR_GraphPipeline.sh` to obtain copy number and allele level information.
   


## Getting the expression level information 

Install dependencies bedtools, samtools for file processing, STAR rnaSeq alignment, TrimGalore for trimming adapters (required for initial steps of WGS analysis too). 
Run `bash expression.sh` with results in `${OUTDIR}/${OUT_PREFIX}_onlyKIRs_NormalizedByTPM.tsv`


## Analysing results 
**For KIR_graph**
To find the nucleic acid sequences of the allele variants  obtained from the analysis:   
`find  ~/  -name  "KIR_v*"` 

Copy number results: `cat ${OUTDIR}/${OUT_PREFIX}.cn.tsv`

Allele level typing results: `cat ${OUTDIR}/${OUT_PREFIX}.allele.tsv`

**For KPI**
Haplotype level typing: `cat ${OUTDIR}/Knew_prediction.txt`
    
