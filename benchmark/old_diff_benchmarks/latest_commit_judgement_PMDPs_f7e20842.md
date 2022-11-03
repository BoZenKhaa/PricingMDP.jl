# Benchmark Report for */home/mrkos/projects/MDPPricing/PMDPs.jl*

## Job Properties
* Time of benchmarks:
    - Target: 6 Oct 2022 - 11:40
    - Baseline: 6 Oct 2022 - 11:41
* Package commits:
    - Target: f7e208
    - Baseline: 332b73
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
| `["generative_ev-mcts", "action_large"]` | 0.83 (5%) :white_check_mark: | 0.52 (1%) :white_check_mark: |
| `["generative_ev-mcts", "action_tiny"]`  | 0.78 (5%) :white_check_mark: | 0.81 (1%) :white_check_mark: |

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
       #1-12  2319 MHz     126632 s       1523 s      20329 s  146021826 s          0 s
  Memory: 62.89322280883789 GB (56905.22265625 MB free)
  Uptime: 1.21838406e6 sec
  Load Avg:  1.01  0.43  0.21
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
       #1-12  1319 MHz     127384 s       1523 s      20354 s  146030134 s          0 s
  Memory: 62.89322280883789 GB (56875.58203125 MB free)
  Uptime: 1.21845979e6 sec
  Load Avg:  1.0  0.56  0.28
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-13.0.1 (ORCJIT, sandybridge)
  Threads: 1 on 12 virtual cores
```