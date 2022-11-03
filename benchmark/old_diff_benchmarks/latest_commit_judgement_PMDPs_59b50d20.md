# Benchmark Report for */home/mrkos/projects/MDPPricing/PMDPs.jl*

## Job Properties
* Time of benchmarks:
    - Target: 27 Oct 2022 - 00:23
    - Baseline: 27 Oct 2022 - 00:25
* Package commits:
    - Target: 59b50d
    - Baseline: b0e250
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
| `["generative_ev-mcts", "action_large"]` |                   1.00 (5%)  |                   1.00 (1%)  |
| `["generative_ev-mcts", "action_tiny"]`  | 0.45 (5%) :white_check_mark: | 0.09 (1%) :white_check_mark: |

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
       #1-12  2228 MHz     385985 s       3934 s      86413 s  358479544 s          0 s
  Memory: 62.89322280883789 GB (57101.33203125 MB free)
  Uptime: 2.99218223e6 sec
  Load Avg:  0.75  0.34  0.28
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
       #1-12  1238 MHz     386769 s       3934 s      86443 s  358488179 s          0 s
  Memory: 62.89322280883789 GB (57106.171875 MB free)
  Uptime: 2.99226099e6 sec
  Load Avg:  0.94  0.5  0.35
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-13.0.1 (ORCJIT, sandybridge)
  Threads: 1 on 12 virtual cores
```