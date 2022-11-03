module M
    using StaticArrays
    using POMDPs

    Action=Float64

    struct State{N} 
        c::SVector{N, Int64}
        t::Int64
    end

    struct Product{N} <: AbstractVector{Bool}
        res::SVector{N, Bool}
    end

    
    abstract type PMDP{State, Action} <: MDP{State, Action} end

    struct PMDPg{State, Action, P}  <: PMDP{State, Action} 
        p::P
    end


    # @show typeof(MDP{State{N}, Action} where N)

    # println()

    # @show isconcretetype(MDP{State, Action})   
    # @show isabstracttype(PMDP{State, Action})
    # @show Base.issingletontype(PMDP{State, Action})
    # @show typeof(PMDP{State, Action})

    # println()

    # @show isconcretetype(MDP{State{3}, Action})   
    # @show isabstracttype(PMDP{State{3}, Action})
    # @show Base.issingletontype(PMDP{State{3}, Action})
    # @show typeof(PMDP{State{3}, Action})

    # @show typeof(State)

    # PMDP{State{3}, Action} <: PMDP{State, Action}


    @show supertype(PMDP{State, Action})
    
    # @show supertype(PMDPg{Product{3}})

end