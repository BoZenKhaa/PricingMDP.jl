import logging
from pathlib import Path

data = Path("/mnt/data/mobility/MDPPricing/data/ev_variable_resources")

results_path = data

logging.basicConfig(level=logging.DEBUG)

# for instance_config_path in instances_path.rglob("*/config.yaml"):
#     logging.info(instance_config_path)

unfinished_runs = []
for result_config_path in results_path.rglob("**/config*.yaml"):
    if (result_config_path.parent / f"{result_config_path.stem}_result.csv").is_file():
        # logging.info(f"\t-SOLUTION- \t{result_config_path}")
        pass
    else:
        logging.info(f"\tXXX-NOT-XXX\t{result_config_path}")
        unfinished_runs.append(result_config_path)

logging.info(f"Found {len(unfinished_runs)} unfinished jobs.")

with open("unfinished_runs_8GB.txt", "wt", encoding="utf-8") as f:
    f.write("\n".join(map(str, unfinished_runs)))
