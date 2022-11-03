# Benchmark Report for */home/mrkos/projects/MDPPricing/dev/MCTS*

## Job Properties
* Time of benchmarks:
    - Target: 20 Oct 2022 - 20:47
    - Baseline: 20 Oct 2022 - 20:47
* Package commits:
    - Target: 464428
    - Baseline: 5bf31d
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
| `["vanilla", "action_large"]` | 1.01 (5%)  |   1.00 (1%)  |
| `["vanilla", "action_small"]` | 1.00 (5%)  |   1.00 (1%)  |

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
       #1-12  2301 MHz     337622 s       3782 s      72114 s  294792153 s          0 s
  Memory: 62.89322280883789 GB (58559.2890625 MB free)
  Uptime: 2.46076875e6 sec
  Load Avg:  0.96  0.68  0.47
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
       #1-12  2415 MHz     338116 s       3782 s      72136 s  294797544 s          0 s
  Memory: 62.89322280883789 GB (58600.75 MB free)
  Uptime: 2.46081799e6 sec
  Load Avg:  1.04  0.74  0.5
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-13.0.1 (ORCJIT, sandybridge)
  Threads: 1 on 12 virtual cores
```