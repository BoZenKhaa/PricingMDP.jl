# Benchmark Report for */home/mrkos/projects/MDPPricing/dev/MCTS*

## Job Properties
* Time of benchmarks:
    - Target: 7 Oct 2022 - 15:22
    - Baseline: 7 Oct 2022 - 15:22
* Package commits:
    - Target: d4ddc8
    - Baseline: 1dec0f
* Julia commits:
    - Target: 36034a
    - Baseline: 36034a
* Julia command flags:
    - Target: None
    - Baseline: None
* Environment variables:
    - Target: None
    - Baseline: None

## Results
A ratio greater than `1.0` denotes a possible regression (marked with :x:), while a ratio less
than `1.0` denotes a possible improvement (marked with :white_check_mark:). All results are shown below.

| ID                            | time ratio | memory ratio |
|-------------------------------|------------|--------------|
| `["vanilla", "action_large"]` | 1.00 (5%)  |   1.00 (1%)  |
| `["vanilla", "action_small"]` | 0.99 (5%)  |   1.00 (1%)  |

## Benchmark Group List
Here's a list of all the benchmark groups executed by this job:

- `["vanilla"]`

## Julia versioninfo

### Target
```
Julia Version 1.8.2
Commit 36034abf260 (2022-09-29 15:21 UTC)
Platform Info:
  OS: Linux (x86_64-linux-gnu)
      Debian GNU/Linux 10 (buster)
  uname: Linux 4.19.0-21-amd64 #1 SMP Debian 4.19.249-2 (2022-06-30) x86_64 unknown
  CPU: Intel(R) Core(TM) i7-3930K CPU @ 3.20GHz: 
                 speed         user         nice          sys         idle          irq
       #1-12  2101 MHz     147709 s       1839 s      28129 s  157948531 s          0 s
  Memory: 62.89322280883789 GB (54293.83984375 MB free)
  Uptime: 1.31807248e6 sec
  Load Avg:  0.6  0.19  0.1
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-13.0.1 (ORCJIT, sandybridge)
  Threads: 1 on 12 virtual cores
```

### Baseline
```
Julia Version 1.8.2
Commit 36034abf260 (2022-09-29 15:21 UTC)
Platform Info:
  OS: Linux (x86_64-linux-gnu)
      Debian GNU/Linux 10 (buster)
  uname: Linux 4.19.0-21-amd64 #1 SMP Debian 4.19.249-2 (2022-06-30) x86_64 unknown
  CPU: Intel(R) Core(TM) i7-3930K CPU @ 3.20GHz: 
                 speed         user         nice          sys         idle          irq
       #1-12  1784 MHz     148164 s       1839 s      28152 s  157953554 s          0 s
  Memory: 62.89322280883789 GB (54317.44921875 MB free)
  Uptime: 1.31811833e6 sec
  Load Avg:  0.89  0.32  0.15
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-13.0.1 (ORCJIT, sandybridge)
  Threads: 1 on 12 virtual cores
```