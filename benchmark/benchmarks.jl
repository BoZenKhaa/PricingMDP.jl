using PkgBenchmark
using PMDPs
using MCTS

# for package in [PMDPs]  
    package=MCTS
    folder = mkpath("benchmark/results/$(package)")
    result = benchmarkpkg(package)   
    if  result.commit != "dirty"
        writeresults("$folder/$(result.commit[1:8]).json", result)
    else
        @info "$package - git directory dirty!\n$result"
    end
# end