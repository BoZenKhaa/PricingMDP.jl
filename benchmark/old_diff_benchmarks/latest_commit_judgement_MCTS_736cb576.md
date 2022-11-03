# Benchmark Report for */home/mrkos/projects/MDPPricing/dev/MCTS*

## Job Properties
* Time of benchmarks:
    - Target: 7 Oct 2022 - 16:08
    - Baseline: 7 Oct 2022 - 16:09
* Package commits:
    - Target: 736cb5
    - Baseline: d4ddc8
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

| ID                            | time ratio                   | memory ratio |
|-------------------------------|------------------------------|--------------|
| `["vanilla", "action_large"]` | 0.89 (5%) :white_check_mark: |   1.00 (1%)  |
| `["vanilla", "action_small"]` |                   0.99 (5%)  |   1.00 (1%)  |

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
       #1-12  2103 MHz     152780 s       1839 s      28622 s  158276508 s          0 s
  Memory: 62.89322280883789 GB (53964.96875 MB free)
  Uptime: 1.32085358e6 sec
  Load Avg:  0.53  0.2  0.17
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
       #1-12  2395 MHz     153250 s       1839 s      28647 s  158281700 s          0 s
  Memory: 62.89322280883789 GB (53984.609375 MB free)
  Uptime: 1.32090098e6 sec
  Load Avg:  0.78  0.31  0.21
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-13.0.1 (ORCJIT, sandybridge)
  Threads: 1 on 12 virtual cores
```