using JuMP
using GLPK
using SDDP

"""
Function to identify the type of policy graph

If the recovery of the policy graph is not implemented, the function will raise an error.

# Arguments
- `graph::SDDP.PolicyGraph`: Policy graph to be identified

# Returns
- `String`: Type of policy graph
"""
function identify_policy_graph(graph::SDDP.PolicyGraph)
    nodes = graph.nodes
    node_idx = graph.root_node
    children = graph.root_children
    if typeof(children[1].term) == Tuple{Int, Int}
        error("MarkovianPolicyGraph not implemented")
    end

    list_nodes = []
    while length(children) > 0

        if node_idx in list_nodes
            return "cycle"
        else
            list_nodes = push!(list_nodes, node_idx)
        end

        if length(children) > 1
            error("Non-linear policy graph")
        end

        node_idx = children[1].term
        prob = children[1].probability

        children = nodes[node_idx].children
    end
    return "linear"
end

function get_linear_graph(policy_graph::SDDP.PolicyGraph)
    root_node = policy_graph.root_node
    nodes = policy_graph.nodes

    belief_partition = policy_graph.belief_partition
    # Converta Set{Int64} para Vector{Int64}
    belief_partition_vec = [collect(partition) for partition in belief_partition]
    belief_lipschitz = [fill(1.0, length(partition)) for partition in belief_partition_vec]  # Preenche com valores padrão
    
    
    edges = Vector{Tuple{Pair{Int64, Int64}, Float64}}()
    for node in nodes
        # print node pair separated by a space
        node_idx = node.first
        for child in node.second.children
            children = child.term
            probability = child.probability
            push!(edges, ((node_idx => children), probability))
        end
    end
    graph = SDDP.Graph(
        root_node,
        collect(keys(nodes)),
        edges;
        belief_partition = belief_partition_vec,  # Certifique-se de usar a estrutura correta
        belief_lipschitz = belief_lipschitz
    )
    return graph
    
end

function get_cycle_linear_graph(graph::SDDP.PolicyGraph)
    println(identify_policy_graph(graph))
end


function get_graph(graph::SDDP.PolicyGraph)
    type = identify_policy_graph(graph)

    if type == "linear"
        get_linear_graph(graph)

    elseif type == "cycle"
        get_cycle_linear_graph(graph)
    end

end
