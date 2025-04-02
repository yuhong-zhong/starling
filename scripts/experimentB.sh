#!/bin/bash

# Path to the summary log
SUMMARY_PATH=../indices/summary.log
GREEN='\033[0;32m'
NC='\033[0m'

# Clear summary file
rm -f $SUMMARY_PATH

# Parameter values to test
MEM_USE_FREQ=1
CACHE=0
SAMPLING_RATE=0.01
FREQ_QUERY_CNT=20000
QUERY_FILE="~/new_partitions/SPTAG/datasets/query_partitions/query_part_1.bin"
MEM_FREQ_USE_RATES=(0.1 0.01 0.001 0.0001)
# Cache values to test
# (10000000 1000000 100000 10000)


# Backup original config file
cp config_local.sh config_local.sh.bak

# Experiment with different cache values
for MEM_FREQ_USE_RATE in "${MEM_FREQ_USE_RATES[@]}"; do
    # Update config_local.sh with different values
    sed -i "s/^MEM_RAND_SAMPLING_RATE=.*/MEM_RAND_SAMPLING_RATE=$SAMPLING_RATE/" config_local.sh
    sed -i "s/^FREQ_QUERY_CNT=.*/FREQ_QUERY_CNT=$FREQ_QUERY_CNT/" config_local.sh
    sed -i "s/^MEM_USE_FREQ=.*/MEM_USE_FREQ=$MEM_USE_FREQ/" config_local.sh
    sed -i "s/^MEM_FREQ_USE_RATE=.*/MEM_FREQ_USE_RATE=$MEM_FREQ_USE_RATE/" config_local.sh
    sed -i "s/^CACHE=.*/CACHE=$CACHE/" config_local.sh
    cat config_dataset.sh | sed "s|QUERY_FILE=.*|QUERY_FILE=${FREQ_QUERY_FILE}|g" > $EXPERIMENT_DIR/config_dataset.sh

    # Output the current settings
    printf "${GREEN}Running with MEM_USE_FREQ=$MEM_USE_FREQ, FREQ_QUERY_CNT=$FREQ_QUERY_CNT, CACHE=$CACHE${NC}\n"

    # Run benchmark tests (uncomment to run)
    ./run_benchmark.sh release freq knn
    ./run_benchmark.sh release build_mem
    ./run_benchmark.sh release search knn
    cat config_local.sh
done

# Display the updated configuration


# Restore the original config file
mv config_local.sh.bak config_local.sh

# Print summary
printf "${GREEN}Summary${NC}\n"
cat $SUMMARY_PATH
