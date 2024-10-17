using JuMP
using GLPK
using SDDP

"""
Function to check the type of the term in the policy graph.

# Arguments
- `graph::SDDP.PolicyGraph`: Policy graph to be checked.

# Raises
- `error`: If the term type is not `Int64`.
"""
function check_type(graph::SDDP.PolicyGraph)
    term = graph.root_children[1].term
    type = typeof(term)
    if type != Int64
        error("Not implemented for term type: $type")
    end
end

"""
Function to get the graph from a policy graph.

# Arguments
- `policy_graph::SDDP.PolicyGraph`: Policy graph to be converted.

# Returns
- `graph::SDDP.Graph`: Graph converted from the policy graph.
"""
function get_graph(policy_graph::SDDP.PolicyGraph)
    root_node = policy_graph.root_node
    nodes = policy_graph.nodes
    
    check_type(policy_graph)

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
        edges
    )
    return graph
    
end