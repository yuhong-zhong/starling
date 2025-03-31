#!/bin/bash

# Path to the summary log
SUMMARY_PATH=../indices/summary.log
GREEN='\033[0;32m'
NC='\033[0m'

# Clear summary file
rm -f $SUMMARY_PATH

# Parameter values to test
MEM_USE_FREQ=0
SAMPLING_RATE=0.01
FREQ_QUERY_CNT=0

# Cache values to test
CACHE_VALUES=(10000000 1000000 100000)


# Backup original config file
cp config_local.sh config_local.sh.bak

# Experiment with different cache values
for CACHE in "${CACHE_VALUES[@]}"; do
    # Update config_local.sh with different values
    sed -i "s/^MEM_RAND_SAMPLING_RATE=.*/MEM_RAND_SAMPLING_RATE=$SAMPLING_RATE/" config_local.sh
    sed -i "s/^FREQ_QUERY_CNT=.*/FREQ_QUERY_CNT=$FREQ_QUERY_CNT/" config_local.sh
    sed -i "s/^MEM_USE_FREQ=.*/MEM_USE_FREQ=$MEM_USE_FREQ/" config_local.sh
    sed -i "s/^CACHE=.*/CACHE=$CACHE/" config_local.sh

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
