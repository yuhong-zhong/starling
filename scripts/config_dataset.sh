dataset_spacev1b_100m() {
  BASE_PATH=/mnt/sdb/vectors_merged.bin
  QUERY_FILE=/mnt/sdb/query.bin
  GT_FILE=/users/yuhong/nvme1n1/SPTAG/datasets/SPACEV1B/truth_100m.bin
  PREFIX=spacev1b_100m
  DATA_TYPE=int8
  DIST_FN=l2
  B=3.25  # 32B PQ compression
  K=10
  DATA_DIM=100
  DATA_N=100000000
}

dataset_chunked_linux() {
  BASE_PATH=/mnt/sdb/dynamic_index/linux_datasets/float32_dataset_SFR-Embedding-Code-400M_chunked_linux.bin
  QUERY_FILE=/mnt/sdb/dynamic_index/linux_datasets/float32_query_SFR-Embedding-Code-400M_chunked_linux.bin
  GT_FILE=/mnt/sdb/dynamic_index/linux_datasets/float32_gt100_SFR-Embedding-Code-400M_chunked_linux.bin
  PREFIX=chunked_linux
  DATA_TYPE=float
  DIST_FN=cosine
  B=0.193  # 256B PQ compression
  K=10
  DATA_DIM=1024
  DATA_N=808908
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