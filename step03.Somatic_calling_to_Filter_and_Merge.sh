#!/bin/bash
########################################
#contact: jaeyoonkim@kribb.re.kr########
########################################

if [ $# -ne 3 ]
then
    echo ""
    echo "    Usage :   [ Strelka2.out.vcf ]     [ Mutect2.out.vcf ]    [ Varscan2.out.vcf ]   "
    echo ""
    exit
fi


########################################
###Configure############################
OUTDIR_BASE=/path/to/Results

Strelka_vcf=$1 
Mutect_vcf=$2
Varscan_vcf=$3
outfile_basename=$(basename $Strelka_vcf .vcf)
SM=$(echo $outfile_basename | cut -d '.' -f 1)  ##Sample.etc.vcf -> TEST1_N -> TEST1
outfile_basename=${SM}


#########################################
########(1)Fine filtering################
#########################################
#(1-1) Strelka2
mkdir -p ${OUTDIR_BASE}/${SM}
OUTDIR=${OUTDIR_BASE}/${SM}

Strelka_vcf_filter=$(basename $Strelka_vcf .vcf)
python ./Src/strelka_vcf_to_filtering.py --min-var-count 3 --min-depth 8 --min-var-frac 0.1 --min-depth-normal 8 $Strelka_vcf \
       1> ${OUTDIR}/${Strelka_vcf_filter}.filter.txt \
       2> ${OUTDIR}/${Strelka_vcf_filter}.filter.err


#(1-2) Mutect2
Mutect_vcf_filter=$(basename $Mutect_vcf .vcf)
python ./Src/mutect_vcf_to_filtering.py --min-var-count 3 --min-depth 8 --min-var-frac 0.1 --min-depth-normal 8 $Mutect_vcf \
       1> ${OUTDIR}/${Mutect_vcf_filter}.filter.txt \
       2> ${OUTDIR}/${Mutect_vcf_filter}.filter.err


#(1-3) Varscan2
Varscan_vcf_filter=$(basename $Varscan_vcf .vcf)
python ./Src/varscan_vcf_to_filtering.py --min-var-count 3 --min-depth 8 --min-var-frac 0.1 --min-depth-normal 8 $Varscan_vcf \
       1> ${OUTDIR}/${Varscan_vcf_filter}.filter.txt \
       2> ${OUTDIR}/${Varscan_vcf_filter}.filter.err



#########################################
########(2)Final mutation################
#########################################
#(2) Final mutation detectd in >= two callers

Strelka_vcf_filter_out=${OUTDIR}/${Strelka_vcf_filter}.filter.txt 
Mutect_vcf_filter_out=${OUTDIR}/${Mutect_vcf_filter}.filter.txt
Varscan_vcf_filter_out=${OUTDIR}/${Varscan_vcf_filter}.filter.txt
python ./Src/Final_mutation_detected_in_two_more.py ${Strelka_vcf_filter_out}  ${Varscan_vcf_filter_out}   ${Mutect_vcf_filter_out} \
      1> ${OUTDIR}/${SM}.Strelka.Varscan.Mutect.Two-More.txt \
      2> ${OUTDIR}/${SM}.Strelka.Varscan.Mutect.Two-More.err 



#####################################
#END#################################
#####################################

