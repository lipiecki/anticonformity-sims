using Pkg
Pkg.instantiate()

using Random, StatsBase, Statistics, Plots, DelimitedFiles
include("sim.jl")

let
    mkpath("figures")
    mkpath("outputs")
    T = 1_000
    R = 1_000
    N = 4
    Q = 3
    for bounded_confidence in [false, true]
        PLT = Matrix{Any}(undef, 3, 2)
        for (a, anticonformity) in enumerate([0, 2, 4])
            for cross_interactions in [false, true]
                trajectories = zeros(Int, 3, T+1, R)
                order = ones(Int, 3).*2
                for r in 1:R
                    trajectories[:, :, r] = sim(anticonformity, cross_interactions; bounded_confidence=bounded_confidence, Q=Q, N=N, T=T)
                    
                    if trajectories[1, end, r] > trajectories[3, end, r]
                        order[1] = 1
                        order[3] = 3
                    else
                        order[1] = 3
                        order[3] = 1
                    end
                    trajectories[:, :, r] = trajectories[order, :, r] 
                end

                trajectory = mean(trajectories, dims=3)[:, :]./(2*N) .* 100
                noise = std(trajectories, dims=3)[:, :]./(2*N) .* 100
                noise = noise

                plt = plot(0:20, trajectory[1, 1:21], lw = 3, color=colorant"#724AB4", ls=:dashdot)
                plot!(plt, 0:20, trajectory[2, 1:21], lw = 3, color=:black, ls=:solid)
                plot!(plt, 0:20, trajectory[3, 1:21], lw = 3, color=colorant"#76A164", ls=:dash)  
                plot!(plt, 0:20, trajectory[1, 1:21] + noise[1, 1:21], fillrange = trajectory[1, 1:21] - noise[1, 1:21], label="", color=colorant"#724AB4", alpha=0.25, lw = 0)
                plot!(plt, 0:20, trajectory[2, 1:21] + noise[2, 1:21], fillrange = trajectory[2, 1:21] - noise[2, 1:21], label="", color=:black, alpha=0.4, lw = 0)
                plot!(plt, 0:20, trajectory[3, 1:21] + noise[3, 1:21], fillrange = trajectory[3, 1:21] - noise[3, 1:21], label="", color=colorant"#76A164", alpha=0.25, lw = 0)
                plot!(plt, legend = false)
                plot!(plt, xlims=(-1, 21), ylims=(-5, 105), xticks = [0, 10, 20], yticks = [0, 25, 50, 75, 100], framestyle=:box)
                if anticonformity == 0
                    plot!(plt, ylabel="% Belief in the Neighbor")
                else
                    plot!(plt, ytickfontcolor = :transparent)
                end
                if cross_interactions
                    plot!(plt, xlabel="Round")
                else
                    plot!(plt, xtickfontcolor = :transparent)
                end
                PLT[a, cross_interactions+1] = plt
                writedlm(joinpath("outputs", "trajectory_anticonformity_$(anticonformity)_political_$(bounded_confidence)_crossfaction_$(cross_interactions).csv"), trajectory')
                writedlm(joinpath("outputs", "noise_anticonformity_$(anticonformity)_political_$(bounded_confidence)_crossfaction_$(cross_interactions).csv"), noise')
            end
        end
        inner = 0Plots.mm
        outer = 10Plots.mm
        top_m    = [outer outer outer inner inner inner]
        bottom_m = [inner inner inner outer outer outer]
        left_m   = [outer inner inner outer inner inner]
        right_m  = [inner inner outer inner inner outer]
        plot(PLT[1, 1], PLT[2, 1], PLT[3, 1], PLT[1, 2], PLT[2, 2], PLT[3, 2], layout=(2, 3), size=(1600, 800), dpi=300, top_margin = top_m, bottom_margin = bottom_m, left_margin = left_m, right_margin  = right_m)
        savefig(joinpath("figures", "trajectory_political_$(bounded_confidence).pdf"))
    end
end
