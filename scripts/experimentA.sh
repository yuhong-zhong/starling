#!/bin/sh

# Path to the summary log
SUMMARY_PATH=../indices/summary.log
GREEN='\033[0;32m'
NC='\033[0m'

# Clear summary file
rm -f $SUMMARY_PATH

# Parameter sets
MEM_USE_FREQ_VALUES=0
SAMPLING_RATES=0
FREQ_QUERY_CNT_VALUES=0

# Cache values to test
CACHE_VALUES=(10000000 1000000 100000 10000)

# Backup original config file
cp config_local.sh config_local.sh.bak

# Experiment without MEM_USE_FREQ and different cache values
for CACHE in "${CACHE_VALUES[@]}"; do
    # Update config_local.sh with different values
    sed -i "s/^MEM_RAND_SAMPLING_RATE=.*/MEM_RAND_SAMPLING_RATE=$SAMPLING_RATES/" config_local.sh
    sed -i "s/^FREQ_QUERY_CNT=.*/FREQ_QUERY_CNT=$FREQ_QUERY_CNT/" config_local.sh
    sed -i "s/^MEM_USE_FREQ=.*/MEM_USE_FREQ=$MEM_USE_FREQ/" config_local.sh
    sed -i "s/^CACHE=.*/CACHE=$CACHE/" config_local.sh

    # Output the current settings
    printf "${GREEN}Running with MEM_USE_FREQ=$MEM_USE_FREQ, FREQ_QUERY_CNT=$FREQ_QUERY_CNT, CACHE=$CACHE${NC}\n"

    # Run benchmark tests
    #./run_benchmark.sh release freq knn
    #./run_benchmark.sh release build_mem
    #./run_benchmark.sh release search knn
done

cat conflg_local.sh

# Restore the original config file
mv config_local.sh.bak config_local.sh

# Print summary
printf "${GREEN}Summary${NC}\n"
cat $SUMMARY_PATH

