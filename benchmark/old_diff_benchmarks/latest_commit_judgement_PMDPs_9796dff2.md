# Benchmark Report for */home/mrkos/projects/MDPPricing/PMDPs.jl*

## Job Properties
* Time of benchmarks:
    - Target: 11 Oct 2022 - 22:46
    - Baseline: 11 Oct 2022 - 22:47
* Package commits:
    - Target: 9796df
    - Baseline: 859044
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

| ID                                       | time ratio    | memory ratio |
|------------------------------------------|---------------|--------------|
| `["generative_ev-mcts", "action_large"]` |    0.99 (5%)  |   1.00 (1%)  |
| `["generative_ev-mcts", "action_tiny"]`  | 1.05 (5%) :x: |   1.00 (1%)  |

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
       #1-12  2193 MHz     212446 s       3349 s      39414 s  202527024 s          0 s
  Memory: 62.89322280883789 GB (57715.89453125 MB free)
  Uptime: 1.69031673e6 sec
  Load Avg:  0.87  0.55  0.4
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
       #1-12  1777 MHz     212947 s       3349 s      39432 s  202532533 s          0 s
  Memory: 62.89322280883789 GB (57746.0234375 MB free)
  Uptime: 1.69036697e6 sec
  Load Avg:  0.95  0.62  0.44
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-13.0.1 (ORCJIT, sandybridge)
  Threads: 1 on 12 virtual cores
```