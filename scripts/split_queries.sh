#!/usr/bin/env bash


# Input file

cd ~/new_partition/SPTAG/datasets/SPACEV1B/
input="query.bin"


# Output directory
output_dir="query_partitions"
mkdir -p "$output_dir"


# Check if input file exists
if [ ! -f "$input" ]; then
 echo "Error: '$input' does not exist."
 exit 1
fi


# Read first 8 bytes to get query count and dimensionality
query_count=$(xxd -p -l 4 "$input" | xxd -r -p | od -An -td4)
query_dim=$(xxd -p -l 4 -s 4 "$input" | xxd -r -p | od -An -td4)


# Define number of partitions and their weights (modify as needed)
num_partitions=2
weights=(0.5 0.5)  # Must sum to 1


# Calculate queries per partition
partition_sizes=()
offset=0


for weight in "${weights[@]}"; do
 part_queries=$(printf "%.0f" "$(echo "$query_count * $weight" | bc)")
 partition_sizes+=("$part_queries")
done


# Adjust last partition to ensure sum matches total query count
sum_queries=0
for size in "${partition_sizes[@]}"; do
 sum_queries=$((sum_queries + size))
done
if [ "$sum_queries" -ne "$query_count" ]; then
 last_index=$((num_partitions - 1))
 partition_sizes[$last_index]=$((partition_sizes[$last_index] + (query_count - sum_queries)))
fi


# Process partitions
offset=8  # Start after the header
for i in "${!partition_sizes[@]}"; do
 part_queries=${partition_sizes[$i]}
 output_file="$output_dir/query_part_$((i+1)).bin"


 # Write the new query count and original dimension size
 (echo -ne "$(printf '\\x%08x' "$part_queries" | tac -rs ..)" | xxd -r -p) > "$output_file"
 (echo -ne "$(printf '\\x%08x' "$query_dim" | tac -rs ..)" | xxd -r -p) >> "$output_file"


 # Extract the corresponding query vectors
 query_data_size=$((part_queries * query_dim))
 dd if="$input" of="$output_file" bs=1 skip="$offset" count="$query_data_size" status=none >> "$output_file"


 offset=$((offset + query_data_size))


 echo "Created $output_file with $part_queries queries."
done


echo "Partitioning complete."
