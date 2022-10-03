
using PMDPs
using POMDPs
using Colors
using AbstractTrees
using Printf
using D3Trees


struct Node
    s::PMDPs.State
    me::PMDPs.PMDPe
    policy::Policy
    parent::PMDPs.State
    prob::Float64
    cmapₚ::Vector{RGB{Float64}}
end

struct ProductChanceNode
    children::Vector{Node}
    product_sold::Bool
    parent_node::Node
end



# Action Colormap
# first action is 0., last is reject (-1)
# first color is too white, ignore it (2:end)
actions_cmap(me) = colormap("Purples",length(actions(me))-1; logscale=false)[2:end] # 1 - 0.0 action
# display(CMAPₐ);

# Products Colormap
product_cmap(me) = colormap("Greens",length(me.pp.c₀)+1; logscale=false)[2:end] # 1 - empty product
# display(CMAPₚ);

function is_product_requested(o::Node)
    p = PMDPs.product(o.me, o.s)
    return p != PMDPs.empty_product(o.me)
end

parent_action(n::ProductChanceNode) = action(n.parent_node.policy, n.parent_node.s)

parent(n::ProductChanceNode) = n.parent_node

# D3Trees.jl API

function AbstractTrees.children(o::Node)
    a = action(o.policy, o.s)
    trans_distribution = transition(o.me, o.s, a)
    children = [Node(s, o.me, o.policy, o.s, prob, o.cmapₚ) for (s, prob) in trans_distribution]
    chance_nodes = [ProductChanceNode(filter(o->op(o.s.c, o.parent.c), children), item_sold, o) 
        for (op, item_sold) in ((!=, true), (==, false))]
    [n for n in chance_nodes if length(n.children)>0]
end

function AbstractTrees.children(o::ProductChanceNode)
    return o.children
end

# Link color <-> Product size 
# Link width <-> probability
function D3Trees.link_style(o::Node)
    style=""
    if o.s.iₚ==PMDPs.empty_product_id(o.me)
        style="stroke-dasharray:3,3; stroke-width:5px"
    else
#         product_size = sum(PMDPs.product(o.me, o.s))
#         style= "stroke:#$(hex(CMAPₚ[product_size]))"
        
        width = o.prob ==0. ? "0" : @sprintf("%.0f", maximum(o.prob*50))
        style*=";stroke-width:$(width)px"
    end
    
    return style
end

function D3Trees.link_style(n::ProductChanceNode)
    width=maximum([1, 20*(parent_action(n)/(actions(n.parent_node.me)[end-1]))])
    style="stroke-width:$(width)px"
    
    return style
end

function D3Trees.style(o::Node)
#     a =  action(o.policy, o.s)
#     if a == 0.
#         style="fill:#$(hex(colorant"lightgreen"))"
#     elseif a == PMDPs.REJECT_ACTION
#         style= "fill:#$(hex(colorant"red"))"
#     else
#         iₐ = findfirst(x->x==a, actions(me))
#         style = "fill:#$(hex(CMAPₐ[iₐ-1]))"
#     end
    if o.s.iₚ==PMDPs.empty_product_id(o.me)
        style=""
    else    
        product_size = sum(PMDPs.product(o.me, o.s))
        style="stroke:#$(hex(o.cmapₚ[product_size])); fill:#$(hex(o.cmapₚ[product_size]))"
    end
    return style
end

function D3Trees.style(n::ProductChanceNode)
    if n.product_sold
        style="fill:#$(hex(colorant"green"))"
    else
        if is_product_requested(parent(n))
            style="fill:#$(hex(colorant"red"))"
        else
            style=""
        end
    end
    return style
end

function D3Trees.shape(o::Node)
    return D3Trees.SVG_CIRCLE
end

function D3Trees.shape(o::ProductChanceNode)
    return D3Trees.SVG_SQUARE
end

## Things that make printing prettier
function D3Trees.tooltip(o::Node)
    s = o.s
    p = PMDPs.product(o.me, s)
    a = action(o.policy, s)
    if !is_product_requested(o)
        ps = "∅"
    else
        ps = "$(p)"[5:end]
    end
    prob = o.prob==0. ? "∅" : @sprintf("%.2f", o.prob)
    "P:$(prob), t:$(s.t), iₚ:$(s.iₚ), A:$(a)\nc:$(s.c)\np:$(ps)"
end

function D3Trees.text(o::Node)
    a = action(o.policy, o.s)
    return a > 0. ? "$(@sprintf("%i", round(a)))" : ""
end

function D3Trees.text(o::ProductChanceNode)
    ""
end