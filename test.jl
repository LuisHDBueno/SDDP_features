include("get_graph.jl")
using Ipopt

# teste policy graph
function test_linear_policy_graph()
    model = SDDP.LinearPolicyGraph(
        stages = 3,  # Número de estágios
        optimizer = GLPK.Optimizer,  # Solver
        lower_bound = 0.0  # Limite inferior para o valor objetivo
    ) do sp, t
        @variable(sp, x >= 0)  # Quantidade produzida
        @variable(sp, u >= 0)  # Quantidade estocada
        @constraint(sp, u >= 10 - x)  # Demanda a ser atendida
        
        @stageobjective(sp, 2*x + u)  # Função objetivo para minimizar custos
        
        if t < 3  # Se não for o último estágio
            SDDP.parameterize(sp, 0.8:0.1:1.2) do demand  # Incerteza na demanda
                @constraint(sp, u >= demand - x)
            end
        end
    end
    
    println("\n Linear Policy Graph: \n")
    show(get_graph(model))
    println("\n")
end

function test_cycle_policy_graph()
    #Create cycle graph
    graph = SDDP.UnicyclicGraph(0.9, num_nodes = 3)

    # Define the stage problem
    function stage_problem(stage, node)
        model = SDDP.Model(() -> Ipopt.Optimizer())  # Passa o otimizador sem o bloco do modelo

        # Defina o problema de otimização para o nó do grafo
        @variable(model, x >= 0)  # Exemplo de variável
        @objective(model, Min, x)  # Exemplo de função objetivo

        return model
    end

    # Create the policy graph
    model = SDDP.PolicyGraph(stage_problem, graph, lower_bound = 0.0)
    println("\n Cycle Policy Graph: \n")
    show(get_graph(model))
    println("\n")
end

function test_markovian_policy_graph()
    model = SDDP.MarkovianPolicyGraph(;
           transition_matrices = [ones(1, 1), [0.5 0.5], [0.8 0.2; 0.2 0.8]],
           lower_bound = 0.0,
       ) do sp, node
        @variable(sp, x >= 0)  # Quantidade produzida
        @variable(sp, u >= 0)  # Quantidade est
        @constraint(sp, u >= 10 - x)  # Demanda a ser atendida

        @stageobjective(sp, 2*x + u)  # Função objetivo para minimizar custos
    end
    println("\n MarkovianPolicyGraph: \n")
    show(get_graph(model))
    println("\n")
end

test_linear_policy_graph()
test_cycle_policy_graph()
test_markovian_policy_graph()