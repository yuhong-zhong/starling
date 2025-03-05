#!/bin/sh

# Switch dataset in the config_local.sh file by calling the desired function

dataset_spacev1b_100m() {
  BASE_PATH=~/new_partition/SPTAG/datasets/SPACEV1B/vectors.bin/vectors_merged.bin
  QUERY_FILE=~/new_partition/SPTAG/datasets/SPACEV1B/query.bin
  GT_FILE=~/new_partition/SPTAG/datasets/SPACEV1B/truth_100m.bin
  PREFIX=spacev1b_100m
  DATA_TYPE=int8
  DIST_FN=l2
  B=3.25  # 32B PQ compression
  K=10
  DATA_DIM=100
  DATA_N=100000000
}

#################
#   BIGANN10M   #
#################
dataset_bigann10M() {
  BASE_PATH=/data/datasets/BIGANN/base.10M.u8bin
  QUERY_FILE=/data/datasets/BIGANN/query.public.10K.128.u8bin
  GT_FILE=/data/datasets/BIGANN/bigann-10M-gt.bin 
  PREFIX=bigann_10m
  DATA_TYPE=uint8
  DIST_FN=l2
  B=0.3
  K=10
  DATA_DIM=128
  DATA_N=10000000
}
