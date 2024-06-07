#!/bin/bash

#SBATCH --nodes=1

module load Julia/1.10.2-linux-x86_64 Gurobi/10.0.1-GCCcore-11.3.0

echo Output: "$OUTPUT"
echo Config: "$EXPERIMENT_CONFIG"
# echo Runner: "$RUNNER"

julia /home/mrkosja1/MDPPricing/scripts/RCI/runner.jl $EXPERIMENT_CONFIG