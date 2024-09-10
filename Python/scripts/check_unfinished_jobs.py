import argparse
import logging
from pathlib import Path

if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        prog="RCI-MDPPricing_jobs_checker",
        description="Script to check which jobs are unfinished on RCI cluster",
    )
    parser.add_argument("--experiments_path", default="/mnt/data/mobility/MDPPricing/data",
                        help="Path to results/experiment configs.")
    # parser.add_argument("--instances_path", default="/home/fiedlda1/Experiment Data/DARP/final/Instances",
    #                     help="Path to instances.")
    parser.add_argument("--output", default="unfinished_runs.txt",
                        help='path to the output file. If empty, log into console only. (Default: "unfinished_runs.txt")')
    args = parser.parse_args()

    experiments_path = Path(args.experiments_path)
    output = args.output

    logging.basicConfig(level=logging.DEBUG)

    # for instance_config_path in instances_path.rglob("*/config.yaml"):
    #     logging.info(instance_config_path)

    unfinished_runs = []
    for result_config_path in experiments_path.rglob("**/config*.yaml"):
        if (result_config_path.parent / f"{result_config_path.stem}_result.csv").is_file():
            # logging.info(f"\t-SOLUTION- \t{result_config_path}")
            pass
        else:
            logging.info(f"\tXXX-NOT-XXX\t{result_config_path}")
            unfinished_runs.append(result_config_path)

    logging.info(f"Found {len(unfinished_runs)} unfinished jobs.")

    if output:
        with open(output, "wt", encoding="utf-8") as f:
            f.write("\n".join(map(str, unfinished_runs)))
