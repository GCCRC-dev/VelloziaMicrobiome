#!/bin/bash

# Set the path to the bbmap scripts
BBMAP_PATH="/home/user/bbmap/"
RQCFilter_PATH="/home/user/bbtools/RQCFilterData/"
Quast_PATH="/home/user/quast/"

# Set paths to HUMAnN databases
HUMANN_N_PATH="/home/user/humann_dbs/full_chocophlan/"
HUMANN_P_PATH="/home/user/humann_dbs/uniref/"

# Loop through each file in the directory
for file in *.fastq.gz; do
    # Set the input and output file names
    input_file="$file"
    clumpify_output="TEMP_CLUMP_${file}"
    trim_output="TEMP_TRIM_${file}"
    filter1_output="TEMP_FILTER1_${file}"
    filter2_output="TEMP_FILTER2_${file}"
    microbe_output="TEMP_MICROBE_${file}"
    ready_output="READY_${file}"
    
    # Remove .fastq.gz from assembly output name
    base_name=$(basename "${file}" .fastq.gz)
    assembly_output="ASSEMBLY_${base_name}"
    HUMANN_OUT="humann_${base_name}"

    # Run clumpify
    ${BBMAP_PATH}./clumpify.sh -Xmx500g pigz=t unpigz=t zl=4 reorder in=${input_file} out=${clumpify_output} passes=1

    # Run bbduk for trimming
    ${BBMAP_PATH}./bbduk.sh -Xmx500g ktrim=r ordered minlen=51 minlenfraction=0.33 mink=11 tbo tpe rcomp=f overwrite=true k=23 hdist=1 hdist2=1 ftm=5 pigz=t unpigz=t zl=4 ow=true in=${clumpify_output} out=${trim_output} rqc=hashmap outduk=ktrim_kmerStats1.txt stats=ktrim_scaffoldStats1.txt loglog ref=${RQCFilter_PATH}adapters2.fa

    # Run bbduk for filtering
    ${BBMAP_PATH}./bbduk.sh -Xmx500g maq=3 trimq=0 qtrim=r ordered overwrite=true maxns=3 minlen=51 minlenfraction=0.33 k=25 hdist=1 pigz=t unpigz=t zl=6 cf=t barcodefilter=crash ow=true in=${trim_output} out=${filter1_output} outm=synth1.fq.gz rqc=hashmap outduk=kmerStats1.txt stats=scaffoldStats1.txt loglog ref=${RQCFilter_PATH}pJET1.2.fa -barcodefilter=f

    # Run bbduk for additional filtering
    ${BBMAP_PATH}./bbduk.sh -Xmx500g ordered overwrite=true k=20 hdist=1 pigz=t unpigz=t zl=6 ow=true in=${filter1_output} out=${filter2_output} outm=synth2.fq.gz outduk=kmerStats2.txt stats=scaffoldStats2.txt loglog ref=${RQCFilter_PATH}short.fa

    # Run bbmap for microbial contamination removal
    ${BBMAP_PATH}./bbmap.sh -Xmx500g ordered quickmatch k=13 idtag=t printunmappedcount ow=true qtrim=rl trimq=10 untrim build=1 null path=${RQCFilter_PATH}commonMicrobes/ pigz=t unpigz=t zl=6 minid=.95 idfilter=.95 maxindel=3 minhits=2 bw=12 bwr=0.16 null maxsites2=10 tipsearch=0 in=${filter2_output} outu=${microbe_output} outm=microbes.fq.gz scafstats=commonMicrobes.txt

    # Run bbmap for human contamination removal
    ${BBMAP_PATH}./bbmap.sh -Xmx500g ordered k=14 idtag=t usemodulo printunmappedcount ow=true qtrim=rl trimq=10 untrim kfilter=25 maxsites=1 tipsearch=0 minratio=.9 maxindel=3 minhits=2 bw=12 bwr=0.16 fast=true maxsites2=10 outm=human.fq.gz path=${RQCFilter_PATH}human_genome/ refstats=refStats.txt pigz=t unpigz=t zl=8 in=${microbe_output} outu=${ready_output}

    # Run bbmerge for merging reads
    ${BBMAP_PATH}./bbmerge.sh -Xmx500g loose overwrite=true in=${ready_output} ihist=ihist_merge.txt outc=cardinality.txt pigz=t unpigz=t zl=8 adapters=${RQCFilter_PATH}adapters2.fa

    # Run kmercountexact
    ${BBMAP_PATH}./kmercountexact.sh overwrite=true in=${ready_output} khist=khist.txt peaks=peaks.txt unpigz=t

    # Run Megahit for assembly
    megahit -m 0.9 -t 40 --12 ${ready_output} --k-list 23,43,63,83,103,123 -o ${assembly_output} --min-contig-len 1000

    # Quast Analysis
    if [[ -d "${assembly_output}" ]]; then
        final_contigs="${assembly_output}/final.contigs.fa"
        renamed_contigs="${assembly_output}/${base_name}.final.contigs.fa"
        quast_output="${assembly_output}/${base_name}.final_contigs_quast"

        if [[ -f "${final_contigs}" ]]; then
            mv "${final_contigs}" "${renamed_contigs}"
            python ${Quast_PATH}quast.py -t 30 -f --mgm --min-identity 90.0 "${renamed_contigs}" -o "${quast_output}" --labels final.contigs.out
        else
            echo "Error: Final contigs file not found at ${final_contigs}"
        fi
    else
        echo "Error: Directory ${assembly_output} does not exist."
    fi

    # Run HUMAnN analysis
    humann --input "${ready_output}" \
           --output "${HUMANN_OUT}" \
           --threads 60 \
           --nucleotide-database "${HUMANN_N_PATH}" \
           --protein-database "${HUMANN_P_PATH}"
done

# Create the metacyc directory (if it doesn't already exist)
mkdir -p metacyc 

# Move pathabundance.tsv files to metacyc
if ls */*pathabundance.tsv &>/dev/null; then
    mv */*pathabundance.tsv metacyc
fi

# Combine and process the HUMAnN output tables
humann_join_tables --input metacyc --output humann_combined_pathabundance.tsv
humann_renorm_table --input humann_combined_pathabundance.tsv --units "cpm" --output humann_combined_pathabundance_cpm.tsv
humann_split_stratified_table --input humann_combined_pathabundance_cpm.tsv --output humann_combined_pathabundance_cpm_split
