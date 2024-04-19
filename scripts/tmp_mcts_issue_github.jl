using POMDPs, QuickPOMDPs, MCTS, DiscreteValueIteration, POMDPTools
using Distributions, Combinatorics, StaticArrays, POMDPTools
using TickTock

NumberUnits = 5;
Number_level = 4;
Transition_matrix = [0.86 0.14 0.0 0.0; 0.0 0.83 0.17 0.0;0.0 0.0 0.89 0.11;
1.0 0.0 0.0 0.0];
failure_penalty = -800.0;
maintenance_penalty = -200.0;
setup_cost = -200.0;
normal_operation = 50.0;

function get_state_index(sp)
    n = sum([(sp[k]-1)*Number_level^(k-1) for k=1:NumberUnits])+1
    return n
end

function get_state_vec(s)
    temp = digits(s-1, base=Number_level, pad=16)
    local_s = temp[1:NumberUnits].+1
    return local_s
end

function get_action_vec(a)
    temp = digits(a-1, base=2, pad=16)  #convert index to binary bits
    local_a = temp[1:NumberUnits];
    return local_a
end

function set_action_value(a)
    n = sum([(a[k])*2^(k-1) for k=1:NumberUnits])+1
    return n
end


multiunit1 = QuickMDP(
    gen = function (s, a, rng)
        #convert an action index to a unit number vector
        local_a = get_action_vec(a);
        local_s = get_state_vec(s);
        sp = repeat(1:1,NumberUnits);
        has_repair = false;
        r = 0.0;
        for i in 1:NumberUnits # for each units
            if local_a[i] == 0       # do nothing
                crd = Categorical(Transition_matrix[local_s[i],:]);
                sp[i] = rand(crd);
                if local_s[i]==Number_level
                    r = r + failure_penalty;
                    if has_repair==false
                        r = r+setup_cost;
                        has_repair = true;
                    end
                else
                    r = r + normal_operation;
                end
            end

            if local_a[i]==1
                sp[i] == 1; # bring it to new condition
                if local_s[i]==Number_level
                    r = r+failure_penalty;
                    if has_repair==false
                        r = r+setup_cost;
                        has_repair = true;
                    end
                else
                    r = r+maintenance_penalty;
                    if has_repair==false
                        r = r+setup_cost;
                        has_repair = true;
                    end
                end
            end
        end
        #convert sp to state index
        #println(sp)
        n = get_state_index(sp)
        return (sp=n, r=r)
    end,
    actions = 1:(2^NumberUnits), #largest 63 units
    states = 1:(Number_level^NumberUnits),
    initialstate = function()
            ImplicitDistribution() do rng
            return (1)
        end
    end, #all units start fresh
    discount = 0.95,
    isterminal = false              # no ending
)



repetition = 12;
simsteps = 20;
rewards = zeros(repetition,1)
# for i in 1:repetition
i=1
    println("Start MCTS simulation...", i)
    mcts = MCTSSolver(n_iterations=5, depth=5, exploration_constant=10.0);
    policy = MCTSPlanner(mcts, multiunit1);
    hr = HistoryRecorder(max_steps=simsteps);
    history = simulate(hr, multiunit1, policy);
    rewards[i,1] = discounted_reward(history);
# end

mean(rewards)

fieldnames(typeof(multiunit1))

states = 1:(Number_level^NumberUnits)

gen = function (s, a, rng)
    #convert an action index to a unit number vector
    local_a = get_action_vec(a);
    local_s = get_state_vec(s);
    sp = repeat(1:1,NumberUnits);
    has_repair = false;
    r = 0.0;
    for i in 1:NumberUnits # for each units
        if local_a[i] == 0       # do nothing
            crd = Categorical(Transition_matrix[local_s[i],:]);
            sp[i] = rand(crd);
            if local_s[i]==Number_level
                r = r + failure_penalty;
                if has_repair==false
                    r = r+setup_cost;
                    has_repair = true;
                end
            else
                r = r + normal_operation;
            end
        end

        if local_a[i]==1
            sp[i] == 1; # bring it to new condition
            if local_s[i]==Number_level
                r = r+failure_penalty;
                if has_repair==false
                    r = r+setup_cost;
                    has_repair = true;
                end
            else
                r = r+maintenance_penalty;
                if has_repair==false
                    r = r+setup_cost;
                    has_repair = true;
                end
            end
        end
    end
    #convert sp to state index
    #println(sp)
    n = get_state_index(sp)
    return (sp=n, r=r)
end