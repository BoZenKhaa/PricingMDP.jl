using PkgBenchmark
using PMDPs
using MCTS

# Judgment between commits
package=MCTS
bench_judgement = PkgBenchmark.judge(package, "HEAD", "HEAD~")
export_markdown("benchmark/latest_commit_judgement_$(package)_$(bench_judgement.target_results.commit[1:8]).md", bench_judgement, export_invariants=true)