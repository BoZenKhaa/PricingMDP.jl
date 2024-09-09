#!/usr/bin/env python3
import time
from pathlib import Path
import logging
import argparse
import re
import os
import yaml

import pricingmdprunner.exec

from pricingmdprunner.utils import load_yaml


def s2hhmmss(s: int):
    m, s = divmod(s, 60)
    h, m = divmod(m, 60)
    return f'{h:d}:{m:02d}:{s:02d}'


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        prog="RCI-MDPPricing_solver_runner",
        description="Script to schedule MDPPricing solver experiments on RCI cluster",
    )
    parser.add_argument("--dry_run", action="store_true",
                        help="Perform dry run: prepare and log configs but do not submit sbatch jobs to the cluster.")
    parser.add_argument("--experiments_path", default="/home/fiedlda1/data/ev_experiments",
                        help="Path to results/experiment configs.")
    # parser.add_argument("--instances_path", default="/home/fiedlda1/Experiment Data/DARP/final/Instances",
    #                     help="Path to instances.")
    parser.add_argument("--log", default="log.txt",
                        help='path to logfile. For logging into terminal, set to --log="". (Default: file)')
    parser.add_argument("--method_filter", default=".*",
                        help='Specify methods to run as regex, as read from config.yaml. For example, "ih" for ih or "('
                             'halns|vga)" for methods other than ih. (Default: .*). Note that the method in config is not equal to the '
                             'method folder name (e.g., halns-ih is just halns in config)!')
    parser.add_argument("--city_filter", default=".*",
                        help='Specify cities to run as regex, as read from config.yaml. For example, "DC" for DC or "('
                             'Chicago|Manhattan|NYC)" for cities other than DC. (Default: .*)')
    parser.add_argument("--path_filter", default=".*",
                        help='Specify parts of config path to run as regex. For example, ".*duration_005_min.*" for '
                             'duration_005_min or ".*(duration_005_min|duration_010_min|duration_030_min).*" for subsets '
                             'of durations. (Default: .*)')
    parser.add_argument("--config_paths_from_file", default="",
                        help="Read paths to experiment configs from file. Useful for re-running experiments that failed.")
    parser.add_argument("--log-level", default="INFO", help="Set log level. (Default: INFO)")

    args = parser.parse_args()

    if args.log:
        logging.basicConfig(filename=args.log, filemode='w', level=args.log_level.upper())
    else:
        logging.basicConfig(level=args.log_level.upper())

    method_filter = args.method_filter
    if method_filter:
        logging.info(f'using method filter: {method_filter}')

    experiments_path = Path(args.experiments_path)
    # instances_path = Path(args.instances_path)
    method_re = re.compile(str(args.method_filter))
    city_re = re.compile(str(args.city_filter))
    path_re = re.compile(str(args.path_filter))

    # get config files from path
    config_paths_filter = []
    if args.config_paths_from_file:
        logging.info(f'running only experiments specified in: {args.config_paths_from_file}')
        with open(args.config_paths_from_file, "rt", encoding="utf-8") as f:
            config_paths_filter = list(map(Path, f.read().splitlines()))
            logging.debug(config_paths_filter)
        assert len(
            config_paths_filter) > 0, f"No config paths loaded from --config_paths_from_file {args.config_paths_from_file}"
        logging.info(f"Loaded list of {len(config_paths_filter)} config paths from file {args.config_paths_from_file}")

    runned = []
    skipped = []

    os.chdir(Path(__file__).resolve().parent)

    sbatch_script_path = Path('/home/mrkosja1/MDPPricing/scripts/RCI/runner.bash').resolve()
    runner_path = Path('/home/mrkosja1/MDPPricing/scripts/RCI/runner.jl').resolve()

    assert experiments_path.exists(), f"Experiments path {experiments_path} does not exist!!"

    for config_path in experiments_path.rglob("**/config*.yaml"):
        logging.info(f"{config_path} - {config_path in config_paths_filter}")
        if config_paths_filter and config_path not in config_paths_filter:
            continue

        config = load_yaml(config_path)

        method = config['runner']
        city = config_path.parts[-6]

        skip_msg = ""
        if not bool(method_re.match(method)):
            # logging.error(f"{bool(method_re.match(method))} - {method_re.match(method)} - {method}")
            skip_msg += f"--method_filter {args.method_filter} "
        if not bool(city_re.match(city)):
            skip_msg += f"--city_filter {args.city_filter} "
        if not bool(path_re.match(str(config_path))):
            skip_msg += f"--path_filter {args.path_filter} "
        if skip_msg:
            skipped.append(f"Ignoring {config_path} due to filters: {skip_msg}")
            continue
        sol_path = config_path.parent / 'config.yaml-solution.json'
        if sol_path.is_file():
            skipped.append(f'Ignoring {config_path} because solution already exists')
            continue

        # timeout_s = int(config['timeout'])
        # timeout_str = s2hhmmss(timeout_s)

        mem = 16
        tmax = 1 if 'tmax' not in config else config['tmax']
        timeout = '24:00:00' if 'timeout' not in config else f'00:{int(config["timeout"] / 60)}:00'

        # logging.info(f"Processing {method} in {city} with {mem}GB, config: {config_path}")

        """ Selected sbatch parameters with RCI defaults:
            -n sets how many CPUs = threads should be allocated. Default is 1
            -N how many nodes should be used. Default is 1.
            –mem-per-cpu= sets how much memory per CPU should be allocated. Default value is 4GB per CPU.
            –mem= sets how much memory for job should be allocated. Default is 4GB * number_of_CPUs_requested
            –gres=gpu - how many GPUs should be allocated. Default is none.
            –exclusive - selected node will be whole allocated for job
            -t - how many minutes will should be resource allocated.
        """

        sbatch_vars = f"EXPERIMENT_CONFIG={config_path},OUTPUT=UNUSED.log,RUNNER={runner_path}"
        commands = [
            'sbatch',
            '-p',
            'amd',
            '-o',
            f'{config_path.parent}/{config_path.stem}_rci_job.log',
            '--job-name',
            f'MDPPricing_{city}_{method}_{"_".join(config_path.parts[-4:-1])}',
            f'--time={timeout}',
            f'--mem={mem}G',
            f'--ntasks={tmax}',
            f'--export={sbatch_vars}',
            # f'./run_experiment.batch',
            f'{sbatch_script_path}'
        ]

        runned.append(' '.join(commands))

        if not args.dry_run:
            # time.sleep(2)
            pricingmdprunner.exec.call_executable(commands)

    runned_join = '\n'.join(runned)
    if args.dry_run:
        logging.info(f"DRY RUN {len(runned)} configs")
    else:
        logging.info(f"Runned {len(runned)} configs")
    logging.debug(f"Used configs:\n {runned_join}")

    skipped_join = '\n'.join(skipped)
    logging.info(f"Skipped {len(skipped)} configs due to filters")
    logging.debug(f"Skipped:\n {skipped_join}")
