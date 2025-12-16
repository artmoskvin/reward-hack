#!/bin/bash

# Default values
CONCURRENCY=2
N=1
EVAL_PATH=""
MODEL=""
EXTRA_ARGS=()

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --eval-path)
            EVAL_PATH="$2"
            shift 2
            ;;
        --model)
            MODEL="$2"
            shift 2
            ;;
        -n|--num-runs)
            N="$2"
            shift 2
            ;;
        -c|--concurrency)
            CONCURRENCY="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 --eval-path <path> --model <model> [-n <num_runs>] [-c <concurrency>] [-- extra args...]"
            echo ""
            echo "Options:"
            echo "  --eval-path     Path to the eval (required)"
            echo "  --model         Model to use (required)"
            echo "  -n, --num-runs  Number of times to run the command (default: 1)"
            echo "  -c, --concurrency  Maximum concurrent runs (default: 2)"
            echo "  -h, --help      Show this help message"
            echo "  --              Additional arguments passed to inspect eval"
            exit 0
            ;;
        --)
            shift
            EXTRA_ARGS=("$@")
            break
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Validate required arguments
if [[ -z "$EVAL_PATH" ]]; then
    echo "Error: --eval-path is required"
    exit 1
fi

if [[ -z "$MODEL" ]]; then
    echo "Error: --model is required"
    exit 1
fi

echo "Running $N evaluations with concurrency $CONCURRENCY"
echo "Eval path: $EVAL_PATH"
echo "Model: $MODEL"
echo ""

# Track running jobs
running=0
completed=0

for ((i=1; i<=N; i++)); do
    # Wait if we've hit the concurrency limit
    while [[ $running -ge $CONCURRENCY ]]; do
        wait -n
        ((running--))
        ((completed++))
        echo "Completed $completed/$N runs"
    done

    echo "Starting run $i/$N"
    uv run inspect eval "$EVAL_PATH" --model "$MODEL" "${EXTRA_ARGS[@]}" &
    ((running++))
done

# Wait for remaining jobs
wait
echo "All $N runs completed"
