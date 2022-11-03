using PkgBenchmark
using PMDPs
using MCTS

function judge_commit_difference(package; target="HEAD", baseline="HEAD~")
    bench_judgement = PkgBenchmark.judge(package, target, baseline)
    export_markdown("benchmark/latest_commit_judgement_$(package)_$(bench_judgement.target_results.commit[1:8]).md", 
                    bench_judgement; export_invariants=true)
end

# Judgment between commits
# judge_commit_difference(MCTS)
judge_commit_difference(PMDPs, baseline="HEAD~")