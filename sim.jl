function sim(p::Int=0, cross_interactions::Bool=false; bounded_confidence::Bool=false, Q::Integer=3, N::Integer=4, T::Integer=20)
    opinions = zeros(Int, N*2)
    updated_opinions = zeros(Int, N*2)
    majority = Int(floor((Q)/2 + 1))
    trajectory = zeros(3, T+1)
    factionA = [i for i in 1:N]
    factionB = [i for i in N+1:2N]
    anticonformists = sample(1:N, p, replace=false)
    anticonformists = vcat(anticonformists, anticonformists .+ N)
    opinions[factionA] .= 1
    opinions[factionB] .= -1
    trajectory[1, 1] = sum(opinions .== -1)
    trajectory[2, 1] = sum(opinions .== 0)
    trajectory[3, 1] = sum(opinions .== 1)
    composition = zeros(Int, Q)
    for t in 1:T
        updated_opinions .= opinions
        for i in 1:2N
            composition .= 0
            if cross_interactions
                for i in 1:Q
                    composition[i] = rand() < 0.5 ? 1 : 0
                end
            end
            influence_group = nothing
            if i in factionA
                influence_group = sample(setdiff(factionA, [i]), Q - sum(composition), replace=false)
                influence_group = vcat(influence_group, sample(factionB, sum(composition), replace=false))
            else
                influence_group = sample(setdiff(factionB, [i]), Q - sum(composition), replace=false)
                influence_group = vcat(influence_group, sample(factionA, sum(composition), replace=false))
            end
            counts = countmap(opinions[influence_group])
            majority_opinion = argmax(counts)
  
            if counts[majority_opinion] >= majority    
                if i in anticonformists 
                    if opinions[i] == majority_opinion
                        if majority_opinion == 0
                            updated_opinions[i] = rand([-1, 1])
                        elseif majority_opinion == 1
                            updated_opinions[i] = rand([-1, 0])
                        elseif majority_opinion == -1
                            updated_opinions[i] = rand([0, 1])
                        else
                            error("majority opinion is out of bounds: $majority_opinion")
                        end
                    end
                else
                    if bounded_confidence
                        if abs(majority_opinion - opinions[i]) <= 1
                            updated_opinions[i] = majority_opinion
                        end
                    else
                        updated_opinions[i] = majority_opinion
                    end
                end
            end
        end
        opinions .= updated_opinions
        trajectory[1, t+1] = sum(opinions .== -1)
        trajectory[2, t+1] = sum(opinions .== 0)
        trajectory[3, t+1] = sum(opinions .== 1)
    end
    return trajectory
end
