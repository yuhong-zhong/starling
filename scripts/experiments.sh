#!/bin/bash

# Create a new folder for each experiment run
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
EXPERIMENT_DIR="experiment_${TIMESTAMP}"
mkdir -p $EXPERIMENT_DIR

# Path to the summary log
SUMMARY_PATH=$EXPERIMENT_DIR/summary.log
GREEN='\033[0;32m'
NC='\033[0m'

# Parameter values to test
MEM_USE_FREQ=0
SAMPLING_RATE=0.01
FREQ_QUERY_CNT=1000
FREQ_QUERY_FILE="~/new_partitions/SPTAG/datasets/query_partitions/query_part_1.bin"

# Cache values to test
CACHE_VALUES=(10000)
#(10000000 1000000 100000 10000)
# Copy original config files
cp config_local.sh $EXPERIMENT_DIR/config_local.sh.original
cp config_dataset.sh $EXPERIMENT_DIR/config_dataset.sh.original

# Modify config_dataset.sh to update QUERY_FILE for all dataset functions
cat config_dataset.sh | sed "s|QUERY_FILE=.*|QUERY_FILE=${FREQ_QUERY_FILE}|g" > $EXPERIMENT_DIR/config_dataset.sh

# Log the changes
echo "Original config files backed up to $EXPERIMENT_DIR" > $EXPERIMENT_DIR/experiment.log
echo "Modified QUERY_FILE to: $FREQ_QUERY_FILE" >> $EXPERIMENT_DIR/experiment.log
echo "----------------------------------------" >> $EXPERIMENT_DIR/experiment.log

# Make a working copy of config_local.sh
cp config_local.sh $EXPERIMENT_DIR/config_local.sh

# Experiment with different cache values
for CACHE in "${CACHE_VALUES[@]}"; do
    # Create a version-specific config
    CONFIG_VERSION="config_local_cache${CACHE}.sh"
    
    # Update config_local.sh with different values
    cp $EXPERIMENT_DIR/config_local.sh $EXPERIMENT_DIR/$CONFIG_VERSION
    sed -i "s/^MEM_RAND_SAMPLING_RATE=.*/MEM_RAND_SAMPLING_RATE=$SAMPLING_RATE/" $EXPERIMENT_DIR/$CONFIG_VERSION
    sed -i "s/^FREQ_QUERY_CNT=.*/FREQ_QUERY_CNT=$FREQ_QUERY_CNT/" $EXPERIMENT_DIR/$CONFIG_VERSION
    sed -i "s/^MEM_USE_FREQ=.*/MEM_USE_FREQ=$MEM_USE_FREQ/" $EXPERIMENT_DIR/$CONFIG_VERSION
    sed -i "s/^CACHE=.*/CACHE=$CACHE/" $EXPERIMENT_DIR/$CONFIG_VERSION
    
    # Use this particular config for the experiment
    cp $EXPERIMENT_DIR/$CONFIG_VERSION config_local.sh
    
    # Output the current settings
    printf "${GREEN}Running with MEM_USE_FREQ=$MEM_USE_FREQ, FREQ_QUERY_CNT=$FREQ_QUERY_CNT, CACHE=$CACHE${NC}\n" | tee -a $EXPERIMENT_DIR/experiment.log
    
    # Run benchmark tests and capture output
    echo "Running freq knn..." >> $EXPERIMENT_DIR/experiment.log
    ./run_benchmark.sh release freq knn 2>&1 | tee -a $EXPERIMENT_DIR/run_log_cache${CACHE}_freq.log
    
    echo "Running build_mem..." >> $EXPERIMENT_DIR/experiment.log
    ./run_benchmark.sh release build_mem 2>&1 | tee -a $EXPERIMENT_DIR/run_log_cache${CACHE}_build_mem.log
    
    echo "Running search knn..." >> $EXPERIMENT_DIR/experiment.log
    ./run_benchmark.sh release search knn 2>&1 | tee -a $EXPERIMENT_DIR/run_log_cache${CACHE}_search_knn.log
    
    # Copy the current state of summary.log
    cp ../indices/summary.log $EXPERIMENT_DIR/summary_cache${CACHE}.log
    
    # Append to main summary
    echo "Results for CACHE=$CACHE" >> $SUMMARY_PATH
    cat ../indices/summary.log >> $SUMMARY_PATH
    echo "----------------------------------------" >> $SUMMARY_PATH
done

# Restore the original config file
cp $EXPERIMENT_DIR/config_local.sh.original config_local.sh
cp $EXPERIMENT_DIR/config_dataset.sh.original config_dataset.sh

# Print summary
printf "${GREEN}Experiment complete. Results in $EXPERIMENT_DIR${NC}\n"
printf "${GREEN}Summary available at $SUMMARY_PATH${NC}\n"
