# Benchmark Report for */home/mrkos/projects/MDPPricing/PMDPs.jl*

## Job Properties
* Time of benchmarks:
    - Target: 11 Oct 2022 - 16:02
    - Baseline: 11 Oct 2022 - 16:03
* Package commits:
    - Target: b06cd4
    - Baseline: 933b78
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

| ID                                       | time ratio                   | memory ratio                 |
|------------------------------------------|------------------------------|------------------------------|
| `["generative_ev-mcts", "action_large"]` | 0.56 (5%) :white_check_mark: |                1.31 (1%) :x: |
| `["generative_ev-mcts", "action_tiny"]`  | 0.69 (5%) :white_check_mark: | 0.91 (1%) :white_check_mark: |

## Benchmark Group List
Here's a list of all the benchmark groups executed by this job:

- `["generative_ev-mcts"]`

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
       #1-12  1392 MHz     190503 s       2064 s      36582 s  199645178 s          0 s
  Memory: 62.89322280883789 GB (57434.15234375 MB free)
  Uptime: 1.66607098e6 sec
  Load Avg:  0.69  0.28  0.15
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
       #1-12  1229 MHz     191268 s       2064 s      36604 s  199653655 s          0 s
  Memory: 62.89322280883789 GB (57307.7890625 MB free)
  Uptime: 1.6661482e6 sec
  Load Avg:  0.92  0.45  0.23
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-13.0.1 (ORCJIT, sandybridge)
  Threads: 1 on 12 virtual cores
```