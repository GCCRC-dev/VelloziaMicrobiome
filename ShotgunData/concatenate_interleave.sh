#!/bin/bash

BBMAP_PATH="/home/user/bbmap/"

for file in *_R1*.fastq.gz; do
    # Detect corresponding R1 and R2 files
    file_R1="$file"
    file_R2="${file_R1/_R1/_R2}"

    # Check if _L001_ and _L002_ identifiers exist in the file name
    if [[ "$file_R1" == *"_L001_"* ]]; then
        # File has lane-specific identifiers
        file_L001_R1="$file_R1"
        file_L001_R2="${file_L001_R1/R1_/R2_}"
        file_L002_R1="${file_L001_R1/L001_/L002_}"
        file_L002_R2="${file_L001_R2/L001_/L002_}"

        # Check if _L002_ files exist
        if [[ -f "$file_L002_R1" && -f "$file_L002_R2" ]]; then
            # Remove lane tags (_L001_/_L002_) and retain the sample name
            sample_name=$(echo "$file_L001_R1" | sed 's/_L001_R1_.*//')

            # Concatenate samples from different lanes for R1 and R2
            cat "$file_L001_R1" "$file_L002_R1" > "${sample_name}_R1.fastq.gz"
            cat "$file_L001_R2" "$file_L002_R2" > "${sample_name}_R2.fastq.gz"

            # Update files for interleaving
            file_R1="${sample_name}_R1.fastq.gz"
            file_R2="${sample_name}_R2.fastq.gz"
        else
            echo "Warning: Missing L002 files for $file_L001_R1. Skipping concatenation."
        fi
    else
        # File does not have lane-specific identifiers
        echo "No lane identifiers (_L001_/_L002_) detected. Proceeding with $file_R1 and $file_R2."
    fi

    # Interleave the files
    if [[ -f "$file_R1" && -f "$file_R2" ]]; then
        sample_name=$(echo "$file_R1" | sed 's/_R1.*//')
        interleaved_file="interleaved_${sample_name}.fastq.gz"
        echo "Interleaving $file_R1 and $file_R2 into $interleaved_file"
        ${BBMAP_PATH}./reformat.sh in1="$file_R1" in2="$file_R2" out="$interleaved_file"
    else
        echo "Warning: Corresponding R2 file for $file_R1 not found. Skipping."
    fi
done
