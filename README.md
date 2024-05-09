# Whole genome data of normal-blood pairs of 99 Korean colorectal cancer individuals 

Variant Calling pipeline was based on GATK software developed by Van der Auwera, and constructed by Jae-Yoon Kim.

This pipeline uses FastQ files of samples and finally presents VCF files for SNP and INDEL.

Source code was written in bash, sh-compatible command language, and supported only on linux platform.


# 1. Abstract

- Colorectal cancer (CRC) is the third most common cancer type worldwide. While screening has led to a decrease in its incidence globally, early-onset CRC (EOCRC) in patients under 50 years of age has been on the rise. Korean has been reported to have the highest incidence of EOCRC worldwide; however, research on the EOCRC has not been studied in more depth than late on-set CRC (LOCRC), and the related data has been little available in public database. From this perspec-tive, we provide a comprehensive dataset of Korean EOCRC and LOCRC with clinical information. We generated whole-genome data of 49 EOCRC and 50 LOCRC Korea patients from a pair of tis-sue and blood. Sequence platform was DNBSeq T7, and read length was 150 bp. The total number of reads was 1,049 million reads, and at least 5.3 million reads were produced per sample. Our dataset presents a valuable resource to researchers studying EOCRC, and is expected to be contribute to the diagnosis and therapy studies of CRC. 


# 2. Work-flow

 - The work-flow of somatics calling procees is as follows:

![work_flow1](https://github.com/JaeYoonKim72/CRC_Korean/assets/49300659/6eed189b-bb5d-42eb-9046-df1131ac6afe)


# 3. Usage

## 3-1. STEP01: Mapping

 - Only paired-end reading is available, and the file name rules are as follows: [sample name]_[T or N ("T" for a tumor sample, "N" for a normal sample)]_[R1 or R2 (“R1” for forward files, “R2” for reverse files)].fastq.gz 

 - The usage of the step01 script is as follows:

    Usage : sh step01.Mapping_to_BQSR.sh  [ Sample_T_R1.fastq.gz(=Forward read) ]    [ Sample_T_R2.fastq.gz(=Reverse read)]


![use1](https://github.com/JaeYoonKim72/CRC_Korean/assets/49300659/29469768-4bcb-4099-9094-b2cc343446b8)

    Example: sh step01.Mapping_to_BQSR.sh \
    
                         TEST1_N_R1.fastq.gz   \       # Forward reads

                         TEST2_N_R2.fastq.gz           # Reverse reads


## 3-2. Somatic calling

Usage : sh step02_Reference_Indexing.sh  [Reference Fasta file]

![s2](https://user-images.githubusercontent.com/49300659/67938042-11d08580-fc12-11e9-83c0-3fed0265f698.png)


    Example: sh step02_Reference_Indexing.sh \
    
                         Reference/hg38_example.fa.gz                    # Reference fasta file compressed by gzip
        
        
## 3-3. Filtering

Usage : sh step03_Variant_Calling.sh  [Sample_directory]  [Sample_suffix: fastq.gz or fq.gz]  [# of Jobs]  [Threads]

![s3_re](https://user-images.githubusercontent.com/49300659/67938735-6cb6ac80-fc13-11e9-9670-42202f3b98c3.png)

                         
    Example: sh step03_Variant_Calling.sh \
    
                         ExampleData/ \                                  # Directory fo samples
                         
                         fastq.gz \                                      # Suffix of Samples
                         
                         3 \                                             # Number of jobs to run
                         
                         5 \                                             # Number of threads to use
                         
                         15g                                             # Memory size to use
                         
                         
## 3-4. Combine samples and Filtering

Usage : sh step04_Combine_gVCFs_and_Filtering.sh  [gVCF directory]  [Threads]  [Output name]

![s4](https://user-images.githubusercontent.com/49300659/67938513-fade6300-fc12-11e9-8fca-5caf24a7ceba.png)
                        

    Example: sh step04_Combine_gVCFs_and_Filtering.sh \
    
                         Results/ \                                      # Directory of gVCF samples
                         
                         5 \                                             # Number of threads to use
                         
                         sample123                                       # Name of output file
                         
                         
# 4. Results

Result files for each calculation step are stored in the "Results" directory, and finally vcf files for INDELs, SNPs, and bi-allelic SNPs are presented.


# 5. Requirement

The required programs are BWA, SAMTOOLS, VCFTOOLS, BGZIP, and GATK, and all the programs are provided in the "src" directory.


# 6. Contact

jaeyoonkim72@gmail.com


# 7. Reference

Danecek, P., Auton, A., Abecasis, G., Albers, C. A., Banks, E., DePristo, M. A., ... & McVean, G. (2011). The variant call format and VCFtools. Bioinformatics, 27(15), 2156-2158.

Li, H., Handsaker, B., Wysoker, A., Fennell, T., Ruan, J., Homer, N., ... & Durbin, R. (2009). The sequence alignment/map format and SAMtools. Bioinformatics, 25(16), 2078-2079.

Li, H., & Durbin, R. (2010). Fast and accurate long-read alignment with Burrows–Wheeler transform. Bioinformatics, 26(5), 589-595.

Van der Auwera, G. A., Carneiro, M. O., Hartl, C., Poplin, R., Del Angel, G., Levy‐Moonshine, A., ... & Banks, E. (2013). From FastQ data to high‐confidence variant calls: the genome analysis toolkit best practices pipeline. Current protocols in bioinformatics, 43(1), 11-10.
