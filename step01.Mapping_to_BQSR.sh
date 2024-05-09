#!/bin/bash
########################################
#contact: jaeyoonkim@kribb.re.kr########
########################################

if [ $# -ne 2 ]
then
    echo ""
    echo "    Usage :  [ Sample_T_R1.fastq.gz(=Forward read) ]   [ Sample_T_R2.fastq.gz(=Reverse read)]   "
    echo ""
    exit
fi



########################################
###Configure############################
BWA2=/path/to/bwa-mem2
GATK=/path/to/gatk
SAMTOOLS=/path/to/samtools

REF=/path/to/Homo_sapiens_assembly38_reduced.fa 
KS1=/path/to/resources_broad_hg38_v0_Homo_sapiens_assembly38.dbsnp138.vcf 
KS2=/path/to/resources_broad_hg38_v0_1000G_phase1.snps.high_confidence.hg38.vcf.gz 
KS3=/path/to/resources_broad_hg38_v0_Homo_sapiens_assembly38.known_indels.vcf.gz 
KS4=/home/jyoon/jyoon/SKIN/Annot/resources_broad_hg38_v0_Mills_and_1000G_gold_standard.indels.hg38.vcf.gz 

TMP=/path/to/TMP
OUTDIR_BASE=/path/to/Results

read_R1=$1 
read_R2=$2
outfile_basename=$(basename $read_R1 .fastq.gz)
outfile_basename=$(basename $outfile_basename .fq.gz)
outfile_basename=${outfile_basename%%_R1}
outfile_basename=${outfile_basename%%_1}

SM=$(echo $outfile_basename | cut -d '_' -f1-2)
outfile_basename=${SM}


#######################################
#(1)#make dir
#######################################
mkdir -p ${OUTDIR_BASE}/${SM}
OUTDIR=${OUTDIR_BASE}/${SM}


#######################################
#(2)BWA-eme2
#######################################
${BWA2} mem \
    -M \
    -R "@RG\tID:${SM}\tSM:${SM}\tPL:ILLUMINA\tLB:UNKNOWN" \
    -v 3 -t 2 -K 1000000 ${REF} \
    $read_R1 $read_R2 2> ${OUTDIR}/${outfile_basename}.bwa2.err \
    | ${SAMTOOLS} view -@ 2 -bS -h -o ${OUTDIR}/${outfile_basename}.bwa2.bam \
    2> ${OUTDIR}/${outfile_basename}.bwa2.bam.err


######################################
#(3)GATK-sort
######################################
${GATK} AddOrReplaceReadGroups \
        --REFERENCE_SEQUENCE ${REF} \
        --INPUT ${OUTDIR}/${outfile_basename}.bwa2.bam \
        --OUTPUT ${OUTDIR}/${outfile_basename}.bwa2.AddSort.bam \
        --TMP_DIR ${TMP}  \
        --RGID NORMAL --RGLB ${SM} --RGPL ILLUMINA --RGPU NONE --RGSM ${SM}\
        --SORT_ORDER coordinate \
        1> ${OUTDIR}/${outfile_basename}.bwa2.AddSort.log \
        2> ${OUTDIR}/${outfile_basename}.bwa2.AddSort.err


######################################
#(4)GATK-Markdup-Check
######################################
${GATK} MarkDuplicates \
        --REFERENCE_SEQUENCE ${REF} \
        --INPUT ${OUTDIR}/${outfile_basename}.bwa2.AddSort.bam \
        --OUTPUT ${OUTDIR}/${outfile_basename}.bwa2.AddSort.MarkDupC.bam \
        --METRICS_FILE ${OUTDIR}/${outfile_basename}.bwa2.AddSort.MarkDup.matrics.txt \
        --TMP_DIR  ${TMP} \
        --CREATE_INDEX true \
        --ASSUME_SORTED true \
        1> ${OUTDIR}/${outfile_basename}.bwa2.AddSort.MarkDupC.log \
        2> ${OUTDIR}/${outfile_basename}.bwa2.AddSort.MarkDupC.err


######################################
#(5) BQSR table
######################################
${GATK} BaseRecalibrator \
        --reference ${REF}  \
        --input  ${OUTDIR}/${outfile_basename}.bwa2.AddSort.MarkDupC.bam  \
        --output  ${OUTDIR}/${outfile_basename}.bwa2.AddSort.MarkDupC.BQSR.table \
        --known-sites ${KS1} \
        --known-sites ${KS2} \
        --known-sites ${KS3} \
        --known-sites ${KS4} \
        --tmp-dir ${TMP} \
        1> ${OUTDIR}/${outfile_basename}.bwa2.AddSort.MarkDupC.BQSR.table.log \
        2> ${OUTDIR}/${outfile_basename}.bwa2.AddSort.MarkDupC.BQSR.table.err


######################################
#(6) BQSR applying
######################################
${GATK} ApplyBQSR \
        --reference ${REF} \
        --input ${OUTDIR}/${outfile_basename}.bwa2.AddSort.MarkDupC.bam  \
        --bqsr-recal-file ${OUTDIR}/${outfile_basename}.bwa2.AddSort.MarkDupC.BQSR.table \
        --output ${OUTDIR}/${outfile_basename}.bwa2.AddSort.MarkDupC.BQSR.bam \
        --tmp-dir ${TMP} \
        1> ${OUTDIR}/${outfile_basename}.bwa2.AddSort.MarkDupC.BQSR.log \
        2> ${OUTDIR}/${outfile_basename}.bwa2.AddSort.MarkDupC.BQSR.err



#####################################
#END#################################
#####################################

