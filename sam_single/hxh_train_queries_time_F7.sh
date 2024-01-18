#!/bin/bash

# 每次train前，需要清空上次train的结果pt文件
# rm -rf ./models/*
# rm -rf ./hxh_testResult/*

# F5 querySize VS trainTime
# workloadSizeList=(10 250 500 750 1000 25750 50500 75250 100000)
# F7 workloadSize VS MeanQ-error
# workloadSizeList=(20000 40000 60000 80000 100000)
workloadSizeList=(200 1000)

# Output directory
output_dir="./hxh_testResult"

# 训练uae
run_script_for_size() {
    local workload_size=$1
    # local q_bs=$(echo "$workload_size / 100" | bc)
    local q_bs=200
    local output_file="${output_dir}/workloadSize_${workload_size}_train_uae.txt"

    echo "Running... workload size is ${workload_size}, q-bs is ${q_bs}"

    start_time=$(date +%s.%3N)

    python train_uae.py --num-gpus=1 --dataset=census --epochs=50 --constant-lr=5e-4 --run-uaeq  --residual --layers=2 --fc-hiddens=128 --direct-io --column-masking --workload-size "$workload_size" --q-bs "$q_bs" > "$output_file" 2>&1

    end_time=$(date +%s.%3N)

    elapsed_time=$(echo "scale=3; $end_time - $start_time" | bc)
    echo "Total running time: ${elapsed_time} seconds"

    # Append running time information to the output file
    echo "Total running time: ${elapsed_time} seconds" >> "$output_file"
}

# 生成单表
run_gen_data() {
    local workload_size=$1
    local q_bs=200
    local output_file="${output_dir}/workloadSize_${workload_size}_gen_data.txt"
    echo "gen data workload size is ${workload_size}"
    python gen_data_model.py --dataset census --residual --layers=2 --fc-hiddens=128 --direct-io --column-masking --glob uaeq-census-q_bs-"$q_bs"-49epochs-psample-200-seed-0-tau-1.0-layers-2-lr-0.0005-queries-"$workload_size".pt --save-name census_"$workload_size" > "$output_file" 2>&1
}

# 在生成数据表上计算q-error
run_query_execute_single() {
    local workload_size=$1
    local output_file="${output_dir}/workloadSize_${workload_size}_qerror.txt"
    echo "query execute single, workload size is ${workload_size}"
    python query_execute_single.py --dataset census --data-file ./generated_data_tables/census_"$workload_size".csv --query-file ./queries/census_test.txt > "$output_file" 2>&1
}

for size in "${workloadSizeList[@]}"; do
    # 训练uae模型
    run_script_for_size "$size"
    # 生成单表
    run_gen_data "$size"
    # 在生成数据表上计算q-error
    run_query_execute_single "$size"
done
