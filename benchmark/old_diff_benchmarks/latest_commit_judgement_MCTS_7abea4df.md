# Benchmark Report for */home/mrkos/projects/MDPPricing/dev/MCTS*

## Job Properties
* Time of benchmarks:
    - Target: 10 Oct 2022 - 15:12
    - Baseline: 10 Oct 2022 - 15:12
* Package commits:
    - Target: 7abea4
    - Baseline: 736cb5
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

| ID                            | time ratio                   | memory ratio                 |
|-------------------------------|------------------------------|------------------------------|
| `["vanilla", "action_large"]` |                   0.98 (5%)  |                   0.99 (1%)  |
| `["vanilla", "action_small"]` | 0.95 (5%) :white_check_mark: | 0.94 (1%) :white_check_mark: |

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
       #1-12  2093 MHz     170415 s       1937 s      32378 s  188944367 s          0 s
  Memory: 62.89322280883789 GB (57203.3359375 MB free)
  Uptime: 1.57666375e6 sec
  Load Avg:  0.6  0.56  0.37
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
       #1-12  1863 MHz     170900 s       1937 s      32398 s  188949759 s          0 s
  Memory: 62.89322280883789 GB (57214.12109375 MB free)
  Uptime: 1.57671291e6 sec
  Load Avg:  0.83  0.63  0.4
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-13.0.1 (ORCJIT, sandybridge)
  Threads: 1 on 12 virtual cores
```