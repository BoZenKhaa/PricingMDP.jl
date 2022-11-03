# Benchmark Report for */home/mrkos/projects/MDPPricing/PMDPs.jl*

## Job Properties
* Time of benchmarks:
    - Target: 11 Oct 2022 - 22:48
    - Baseline: 11 Oct 2022 - 22:49
* Package commits:
    - Target: 9796df
    - Baseline: b06cd4
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

| ID                                       | time ratio                   | memory ratio |
|------------------------------------------|------------------------------|--------------|
| `["generative_ev-mcts", "action_large"]` |                   1.02 (5%)  |   1.00 (1%)  |
| `["generative_ev-mcts", "action_tiny"]`  | 0.80 (5%) :white_check_mark: |   1.00 (1%)  |

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
       #1-12  2167 MHz     213463 s       3349 s      39467 s  202541794 s          0 s
  Memory: 62.89322280883789 GB (57729.0 MB free)
  Uptime: 1.69044879e6 sec
  Load Avg:  0.85  0.65  0.46
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
       #1-12  2255 MHz     214219 s       3349 s      39503 s  202550063 s          0 s
  Memory: 62.89322280883789 GB (57685.70703125 MB free)
  Uptime: 1.69052433e6 sec
  Load Avg:  0.96  0.73  0.5
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-13.0.1 (ORCJIT, sandybridge)
  Threads: 1 on 12 virtual cores
```