include("get_graph.jl")

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
    
    get_graph(model)
end

test_linear_policy_graph()