## Whole genome data of normal-blood pairs of 99 Korean colorectal cancer individuals 

This somatic calling process for whole genome data of cancer patients was constructed by Jae-Yoon Kim (jaeyoonkim@kribb.re.kr), and it is based on GATK4, BWA-mem2, and samtools softwares.

This pipeline starts with paired-end fastq files and does not cover quality check and control steps (e.g. fastqc or cutadapter).

Specifically, this pipeline uses a total of three somatic callers (Strelka2, Mutect2, and Varscan2), and ultimately provides somatic mutations with minimal false-positives.

Source code was written in bash and python, and only supported on linux platform.


## 1. Abstract

- Colorectal cancer (CRC) is the third most common cancer type worldwide. While screening has led to a decrease in its incidence globally, early-onset CRC (EOCRC) in patients under 50 years of age has been on the rise. Korean has been reported to have the highest incidence of EOCRC worldwide; however, research on the EOCRC has not been studied in more depth than late on-set CRC (LOCRC), and the related data has been little available in public database. From this perspec-tive, we provide a comprehensive dataset of Korean EOCRC and LOCRC with clinical information. We generated whole-genome data of 49 EOCRC and 50 LOCRC Korea patients from a pair of tis-sue and blood. Sequence platform was DNBSeq T7, and read length was 150 bp. The total number of reads was 1,049 million reads, and at least 5.3 million reads were produced per sample. Our dataset presents a valuable resource to researchers studying EOCRC, and is expected to be contribute to the diagnosis and therapy studies of CRC. 


## 2. Work-flow

 - The work-flow of somatics calling procees is as follows:

![work_flow1](https://github.com/JaeYoonKim72/CRC_Korean/assets/49300659/6eed189b-bb5d-42eb-9046-df1131ac6afe)


## 3. Usage

## 3-1. STEP01: Mapping

 - Only paired-end reading is available, and the file name rules are as follows: [sample name]__[T or N ("T" for a tumor sample, "N" for a normal sample)]__[R1 or R2 (“R1” for a forward file, “R2” for a reverse file)].fastq.gz

 - The important thing is that before executing the script, you must open the script (e.g. vi or nano) and type each software path and environment variable appropriately.

 - The usage of the step01 script is as follows:

    Usage : sh step01.Mapping_to_BQSR.sh  [ Sample_T_R1.fastq.gz(=Forward read) ]    [ Sample_T_R2.fastq.gz(=Reverse read)]


![use1](https://github.com/JaeYoonKim72/CRC_Korean/assets/49300659/29469768-4bcb-4099-9094-b2cc343446b8)

    Example: sh step01.Mapping_to_BQSR.sh \
    
                         TEST1_N_R1.fastq.gz   \       # Forward reads

                         TEST2_N_R2.fastq.gz           # Reverse reads


## 3-2. STEP02: Somatic calling

 - BAM files for Normal and Tumor of each sample are required. The file name rules are as follows: [sample name]__[T or N ("T" for a tumor sample, "N" for a normal sample)].otehr.strings.bam

 - The important thing is that before executing the script, you must open the script (e.g. vi or nano) and type each software path and environment variable appropriately.

 - The usage of the step01 script is as follows:

    Usage : sh step02.BAM_to_Somatic_calling.sh   [ Sample_N.mapping.bam(=Normal bam)]     [ Sample_T.mapping.bam(=Tumor bam)]

![use2](https://github.com/JaeYoonKim72/CRC_Korean/assets/49300659/45bf62ef-d787-433b-ac53-c6269fe4da30)

    Example: sh step02.BAM_to_Somatic_calling.sh \
    
                         TEST1_N.markdup.BQSR.bam  \  # Normal bam
                          
                         TEST1_T.markdup.BQSR.bam  \  # Tumor bam
        
        
## 3-3. STEP03: Filtering

 - The usage of the step01 script is as follows:
   
    Usage : sh step03_Variant_Calling.sh  [Sample_directory]  [Sample_suffix: fastq.gz or fq.gz]  [# of Jobs]  [Threads]

![s3_re](https://user-images.githubusercontent.com/49300659/67938735-6cb6ac80-fc13-11e9-9670-42202f3b98c3.png)

                         
    Example: sh step03_Variant_Calling.sh \
    
                         ExampleData/ \                                  # Directory fo samples
                         
                         fastq.gz \                                      # Suffix of Samples
                         
                         3 \                                             # Number of jobs to run
                         
                         5 \                                             # Number of threads to use
                         
                         15g                                             # Memory size to use
                         

## 4. Contact

jaeyoonkim@kribb.re.kr


## 5. Citation

- Paper is under review.


## 6. Reference

 - GATK4: Van der Auwera, G. A., & O'Connor, B. D. (2020). Genomics in the cloud: using Docker, GATK, and WDL in Terra. O'Reilly Media.

 - SAMTOOLS: Li, H., Handsaker, B., Wysoker, A., Fennell, T., Ruan, J., Homer, N., ... & Durbin, R. (2009). The sequence alignment/map format and SAMtools. Bioinformatics, 25(16), 2078-2079.
 
 - BWA-MEM2: Vasimuddin, M., Misra, S., Li, H., & Aluru, S. (2019, May). Efficient architecture-aware acceleration of BWA-MEM for multicore systems. In 2019 IEEE international parallel and distributed processing symposium (IPDPS) (pp. 314-324). IEEE.
