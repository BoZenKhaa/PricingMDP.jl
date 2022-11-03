# Benchmark Report for */home/mrkos/projects/MDPPricing/dev/MCTS*

## Job Properties
* Time of benchmarks:
    - Target: 11 Oct 2022 - 22:42
    - Baseline: 11 Oct 2022 - 22:42
* Package commits:
    - Target: 5bf31d
    - Baseline: fa4b51
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

| ID                            | time ratio    | memory ratio  |
|-------------------------------|---------------|---------------|
| `["vanilla", "action_large"]` | 1.13 (5%) :x: |    1.00 (1%)  |
| `["vanilla", "action_small"]` | 1.06 (5%) :x: | 1.05 (1%) :x: |

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
       #1-12  2995 MHz     210997 s       3349 s      39336 s  202498372 s          0 s
  Memory: 62.89322280883789 GB (58000.43359375 MB free)
  Uptime: 1.69006514e6 sec
  Load Avg:  0.54  0.4  0.32
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
       #1-12  2991 MHz     211485 s       3349 s      39365 s  202503752 s          0 s
  Memory: 62.89322280883789 GB (58042.72265625 MB free)
  Uptime: 1.69011429e6 sec
  Load Avg:  0.8  0.49  0.36
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-13.0.1 (ORCJIT, sandybridge)
  Threads: 1 on 12 virtual cores
```