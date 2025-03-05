#!/bin/bash

CONFIG_FILE="config_local.sh"
LOG_FILE="benchmark_results.log"
INDEX_DIR="../indices/spacev1b_100m_M10000_R64_L128_B3.25/FREQ/NQ_10000_BM_4_L_100_T_16"

MEM_USE_FREQ_VALUES=(0 1)
SAMPLING_RATES=(0.01 0.02 0.05 0.1)
FREQ_QUERY_CNT_VALUES=(0 1000 5000 10000)

# Backup original config file
cp "$CONFIG_FILE" "${CONFIG_FILE}.bak"

for MEM_USE_FREQ in "${MEM_USE_FREQ_VALUES[@]}"; do
    for FREQ_QUERY_CNT in "${FREQ_QUERY_CNT_VALUES[@]}"; do
        # Delete the index directory if it exists
        if [ -d "$INDEX_DIR" ]; then
            rm -rf "$INDEX_DIR"
        fi

        if [[ "$MEM_USE_FREQ" -eq 0 ]]; then
            # MEM_USE_FREQ = 0, set MEM_RAND_SAMPLING_RATE and MEM_FREQ_USE_RATE to default
            sed -i "s/^MEM_USE_FREQ=.*/MEM_USE_FREQ=0/" "$CONFIG_FILE"
            sed -i "s/^FREQ_QUERY_CNT=.*/FREQ_QUERY_CNT=$FREQ_QUERY_CNT/" "$CONFIG_FILE"
            echo "Running benchmark with MEM_USE_FREQ=0, FREQ_QUERY_CNT=$FREQ_QUERY_CNT" | tee -a "$LOG_FILE"
            ./run_benchmark.sh release build_mem knn
            ./run_benchmark.sh release freq knn 2>&1 | tee -a "$LOG_FILE"
            ./run_benchmark.sh release search knn 2>&1 | tee -a "$LOG_FILE"
        else
            for RATE in "${SAMPLING_RATES[@]}"; do
                # MEM_USE_FREQ = 1, try different sampling rates
                sed -i "s/^MEM_USE_FREQ=.*/MEM_USE_FREQ=1/" "$CONFIG_FILE"
                sed -i "s/^MEM_RAND_SAMPLING_RATE=.*/MEM_RAND_SAMPLING_RATE=$RATE/" "$CONFIG_FILE"
                sed -i "s/^MEM_FREQ_USE_RATE=.*/MEM_FREQ_USE_RATE=$RATE/" "$CONFIG_FILE"
                sed -i "s/^FREQ_QUERY_CNT=.*/FREQ_QUERY_CNT=$FREQ_QUERY_CNT/" "$CONFIG_FILE"
                echo "Running benchmark with MEM_USE_FREQ=1, MEM_RAND_SAMPLING_RATE=$RATE, MEM_FREQ_USE_RATE=$RATE, FREQ_QUERY_CNT=$FREQ_QUERY_CNT" | tee -a "$LOG_FILE"
                ./run_benchmark.sh release build_mem knn
                ./run_benchmark.sh release freq knn 2>&1 | tee -a "$LOG_FILE"
                ./run_benchmark.sh release search knn 2>&1 | tee -a "$LOG_FILE"
            done
        fi
    done
done

# Restore the original config file
mv "${CONFIG_FILE}.bak" "$CONFIG_FILE"

echo "All experiments completed. Results logged in $LOG_FILE"
