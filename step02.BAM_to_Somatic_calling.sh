#!/bin/bash
########################################
#contact: jaeyoonkim@kribb.re.kr########
########################################

if [ $# -ne 2 ]
then
    echo ""
    echo "    Usage :   [ Sample_N.mapping.bam(=Normal bam)]     [ Sample_T.mapping.bam(=Tumor bam)]   "
    echo ""
    exit
fi


########################################
###Configure############################
GATK=/path/to/gatk-4.3.0.0/gatk
SAMTOOLS=/path/to/samtools
BCFTOOLS=/path/to/bcftools

MANTA_Config=/path/to/configManta.py
STRELKA_Config=/path/to/configureStrelkaSomaticWorkflow.py
VARSCAN=/path/to/VarScan.v2.4.6.jar

REF=/path/to/Homo_sapiens_assembly38_reduced.fa  ##download: https://console.cloud.google.com/storage/browser/_details/genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.fasta
Intervals=/path/to/Homo_sapiens_assembly38_reduced.intervals   ## make as below:
#####Ex. of Intervals#####
#1:1-248956422
#2:1-242193529
#3:1-198295559
#4 4:1-190214555
GERM_ANNOT=/path/to/somatic-hg38_af-only-gnomad.hg38.vcf.gz  ##download: https://console.cloud.google.com/storage/browser/_details/gcp-public-data--broad-references/hg38/v0/somatic-hg38/af-only-gnomad.hg38.vcf.gz?pageState=(%22StorageObjectListTable%22:(%22f%22:%22%255B%255D%22))

TMP=/path/to/TMP
OUTDIR_BASE=/path/to/Results

Nor_BAM=$1 
Tur_BAM=$2
outfile_basename=$(basename $Nor_BAM)
SM=$(echo $outfile_basename | cut -d '.' -f 1 | cut -d '_' -f 1)  ##TEST1_N.etc.bam -> TEST1_N -> TEST1
outfile_basename=${SM}


#########################################
########(1)STRELKA2######################
#########################################
#(1-1)
mkdir -p ${OUTDIR_BASE}/${SM}
OUTDIR=${OUTDIR_BASE}/${SM}

#(1-2) Strelka2 - Manta config 
mkdir -p ${OUTDIR}/1.Manta/
${MANTA_Config} \
      --referenceFasta ${REF} \
      --normalBam ${Nor_BAM} \
      --tumorBam ${Tur_BAM} \
      --runDir ${OUTDIR}/1.Manta/ \
      1> ${OUTDIR}/1.Manta/${SM}.manta-config.log \
      2> ${OUTDIR}/1.Manta/${SM}.manta-config.err 

#(1-3) Strelka2 - Manta run
${OUTDIR}/1.Manta/runWorkflow.py  \
     1> ${OUTDIR}/1.Manta/${SM}.manta-runWorkflow.log \
     2> ${OUTDIR}/1.Manta/${SM}.manta-runWorkflow.err 

#(1-4) Strelka2 - Strelka2 config
mkdir -p ${OUTDIR}/2.Strelka2/
${STRELKA_Config} \
      --referenceFasta ${REF} \
      --normalBam ${Nor_BAM} \
      --tumorBam ${Tur_BAM} \
      --indelCandidates ${OUTDIR}/1.Manta/results/variants/candidateSmallIndels.vcf.gz \
      --runDir ${OUTDIR}/2.Strelka2/ \
      1> ${OUTDIR}/2.Strelka2/${SM}.strelka2-config.log \
      2> ${OUTDIR}/2.Strelka2/${SM}.strelka2-config.err 

#(1-5) Strelka2 - Strelka2 run
${OUTDIR}/2.Strelka2/runWorkflow.py -m local \
     1> ${OUTDIR}/2.Strelka2/${SM}.strelka2-runWorkflow.log \
     2> ${OUTDIR}/2.Strelka2/${SM}.strelka2-runWorkflow.err 


#(1-6) Strelka2 - filtering
${BCFTOOLS} view \
     -f 'PASS' \
     ${OUTDIR}/2.Strelka2/results/variants/somatic.snvs.vcf.gz \
     -O z \
     -o ${OUTDIR}/2.Strelka2/results/variants/somatic.snvs.pass.vcf.gz \
     1> ${OUTDIR}/2.Strelka2/results/variants/somatic.snvs.pass.vcf.gz.log \
     2> ${OUTDIR}/2.Strelka2/results/variants/somatic.snvs.pass.vcf.gz.err


${BCFTOOLS} view \
     -f 'PASS' \
     ${OUTDIR}/2.Strelka2/results/variants/somatic.indels.vcf.gz \
     -O z \
     -o ${OUTDIR}/2.Strelka2/results/variants/somatic.indels.pass.vcf.gz \
     1> ${OUTDIR}/2.Strelka2/results/variants/somatic.indels.pass.vcf.gz.log \
     2> ${OUTDIR}/2.Strelka2/results/variants/somatic.indels.pass.vcf.gz.err


#(1-7) Strelka2 - final
${BCFTOOLS} concat \
     ${OUTDIR}/2.Strelka2/results/variants/somatic.snvs.pass.vcf.gz \
     ${OUTDIR}/2.Strelka2/results/variants/somatic.indels.pass.vcf.gz \
     -O z \
     -o ${OUTDIR}/2.Strelka2/results/variants/somatic.variant.pass.vcf.gz \
     1> ${OUTDIR}/2.Strelka2/results/variants/somatic.variant.pass.vcf.gz.log \
     2> ${OUTDIR}/2.Strelka2/results/variants/somatic.variant.pass.vcf.gz.err \



#########################################
########(2)Varscan2######################
#########################################
#(2-1) Varscan - mpileup
mkdir -p ${OUTDIR}/3.Varscan2/
${SAMTOOLS} mpileup \
    -B \
    -f ${REF} 
    -q 10 \
    ${Tur_BAM} \
    1> ${OUTDIR}/3.Varscan2/${SM}_T.mpile \
    2> ${OUTDIR}/3.Varscan2/${SM}_T.mpile.err 

${SAMTOOLS} mpileup \
    -B \
    -f ${REF}
    -q 10 \
    ${Nor_BAM} \
    1> ${OUTDIR}/3.Varscan2/${SM}_N.mpile \
    2> ${OUTDIR}/3.Varscan2/${SM}_N.mpile.err 

#(2-2) Varscan - calling
java -jar ${VARSCAN} somatic \
    ${OUTDIR}/3.Varscan2/${SM}_N.mpile \
    ${OUTDIR}/3.Varscan2/${SM}_T.mpile \
    ${OUTDIR}/3.Varscan2/${SM}.varscan \
    --output-vcf \
    1> ${OUTDIR}/3.Varscan2/${SM}.varscan.log \
    2> ${OUTDIR}/3.Varscan2/${SM}.varscan.err


#(2-3) Varscan - filtering
java -jar ${VARSCAN} processSomatic \
    ${OUTDIR}/3.Varscan2/${SM}.varscan.snp.vcf  \
    1> ${OUTDIR}/3.Varscan2/${SM}.varscan.snp.vcf.proc.log \
    2> ${OUTDIR}/3.Varscan2/${SM}.varscan.snp.vcf.proc.err 

java -jar ${VARSCAN} processSomatic \
    ${OUTDIR}/3.Varscan2/${SM}.varscan.indel.vcf  \
    1> ${OUTDIR}/3.Varscan2/${SM}.varscan.indel.vcf.proc.log \
    2> ${OUTDIR}/3.Varscan2/${SM}.varscan.indel.vcf.proc.err

${BCFTOOLS} view \
     -f 'PASS' \
     ${OUTDIR}/3.Varscan2/${SM}.varscan.snp.Somatic.hc.vcf \
     -O z \
     -o ${OUTDIR}/3.Varscan2/${SM}.varscan.snp.Somatic.hc.pass.vcf.gz \
     1> ${OUTDIR}/3.Varscan2/${SM}.varscan.snp.Somatic.hc.pass.vcf.gz.log \
     2> ${OUTDIR}/3.Varscan2/${SM}.varscan.snp.Somatic.hc.pass.vcf.gz.err 

${BCFTOOLS} view \
     -f 'PASS' \
     ${OUTDIR}/3.Varscan2/${SM}.varscan.indel.Somatic.hc.vcf \     
     -O z \
     -o ${OUTDIR}/3.Varscan2/${SM}.varscan.indel.Somatic.hc.pass.vcf.gz \
     1> ${OUTDIR}/3.Varscan2/${SM}.varscan.indel.Somatic.hc.pass.vcf.gz.log \
     2> ${OUTDIR}/3.Varscan2/${SM}.varscan.indel.Somatic.hc.pass.vcf.gz.err

#(2-4) Varscan - final
${BCFTOOLS} concat \
     ${OUTDIR}/3.Varscan2/${SM}.varscan.snp.Somatic.hc.pass.vcf.gz \
     ${OUTDIR}/3.Varscan2/${SM}.varscan.indel.Somatic.hc.pass.vcf.gz \
     -O z \
     -o ${OUTDIR}/3.Varscan2/${SM}.varscan.variant.Somatic.hc.pass.vcf.gz \
     1> ${OUTDIR}/3.Varscan2/${SM}.varscan.variant.Somatic.hc.pass.vcf.gz.log \
     2> ${OUTDIR}/3.Varscan2/${SM}.varscan.variant.Somatic.hc.pass.vcf.gz.err



#########################################
########(3)MUTECT2#######################
#########################################
#(3-1) Mutect - Normal call
mkdir -p ${OUTDIR}/4.Mutect2/
${GATK} Mutect2 
        --reference ${REF} \
        -I ${Nor_BAM} \
        -O ${OUTDIR}/4.Mutect2/${SM}_N.vcf.gz \
        1> ${OUTDIR}/4.Mutect2/${SM}_N.vcf.gz.log \ 
        2>  ${OUTDIR}/4.Mutect2/${SM}_N.vcf.gz.err 

#(3-2) Mutect - PON
###CAVEAT: (3-2) Step must be performed after calculating all normal samples ((3-1) step).
norms=$(for i in $(ls ${OUTDIR_BASE}/*/4.Mutect2/*_N.vcf.gz); do echo -n "-V" $i ""; done)
${GATK} GenomicsDBImport \
        -R ${REF} \
        -L ${Intervals} \
        --genomicsdb-workspace-path ${OUTDIR_BASE}/PON  \
        --tmp-dir ${TMP} \
        $norms \
        1> ${OUTDIR_BASE}/PON.log \
        2> ${OUTDIR_BASE}/PON.err 

${GATK} CreateSomaticPanelOfNormals \
        -R ${REF} \
        --germline-resource ${GERM_ANNOT} \
        -V gendb://${OUTDIR_BASE}/PON \
        -O ${OUTDIR_BASE}/PON/PON.vcf.gz \
        1> ${OUTDIR_BASE}/PON/PON.vcf.gz.log \
        2> ${OUTDIR_BASE}/PON/PON.vcf.gz.err 


#(3-3) Mutect - calling
${GATK} Mutect2 \
        --reference ${REF} \
        --tmp-dir ${TMP} \
        -I $Tur_BAM \
        -I $Nor_BAM \
        -normal ${SM}_N \
        --panel-of-normals ${OUTDIR_BASE}/PON/PON.vcf.gz \
        --germline-resource ${GERM_ANNOT} \
        --f1r2-tar-gz ${OUTDIR}/4.Mutect2/${SM}.mutect.f1r2.tar.gz \
        -O ${OUTDIR}/4.Mutect2/${SM}.mutect.vcf.gz \
        1> ${OUTDIR}/4.Mutect2/${SM}.mutect.vcf.gz.log \
        2> ${OUTDIR}/4.Mutect2/${SM}.mutect.vcf.gz.err 

#(3-4) Mutect  - filtering
${GATK} LearnReadOrientationModel \
        -I ${OUTDIR}/4.Mutect2/${SM}.mutect.f1r2.tar.gz \
        -O ${OUTDIR}/4.Mutect2/${SM}.mutect.f1r2.orient.tar.gz \
        1> ${OUTDIR}/4.Mutect2/${SM}.mutect.f1r2.orient.tar.gz.log \
        2> ${OUTDIR}/4.Mutect2/${SM}.mutect.f1r2.orient.tar.gz.err

${GATK} FilterMutectCalls \
        --tmp-dir ${TMP} \
        --reference ${REF} \ 
        --false-discovery-rate 0.05 \
        --variant ${OUTDIR}/4.Mutect2/${SM}.mutect.vcf.gz \
        --stats ${OUTDIR}/4.Mutect2/${SM}.mutect.vcf.gz.stats 
        --orientation-bias-artifact-priors ${OUTDIR}/4.Mutect2/${SM}.mutect.f1r2.orient.tar.gz \ 
        --output ${OUTDIR}/4.Mutect2/${SM}.mutect.filter.vcf.gz \
        --filtering-stats ${OUTDIR}/4.Mutect2/${SM}.mutect.filter.vcf.stat \
        --verbosity INFO \
        1> ${OUTDIR}/4.Mutect2/${SM}.mutect.filter.vcf.gz.log \
        2> ${OUTDIR}/4.Mutect2/${SM}.mutect.filter.vcf.gz.err 

#(3-5) Mutect  -  final
${BCFTOOLS} view \
     -f 'PASS' \
     $${OUTDIR}/4.Mutect2/${SM}.mutect.filter.vcf.gz \
     -O z \
     -o ${OUTDIR}/4.Mutect2/${SM}.mutect.filter.pass.vcf.gz \
     1> ${OUTDIR}/4.Mutect2/${SM}.mutect.filter.pass.vcf.gz.log \
     2> ${OUTDIR}/4.Mutect2/${SM}.mutect.filter.pass.vcf.gz.err 


#####################################
#END#################################
#####################################

