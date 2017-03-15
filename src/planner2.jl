type POMCPPlanner2{P,C,NA,SE,SolverType} <: Policy
    solver::SolverType
    problem::P
    criterion::C
    next_action::NA
    solved_estimate::SE
    tree::Nullable{Any} # this is just so you can look at the tree later
end

function POMCPPlanner2(solver, problem::POMDP)
    POMCPPlanner2(solver,
                  problem,
                  solver.criterion,
                  solver.next_action,
                  convert_estimator(solver.estimate_value, solver, problem),
                  Nullable{Any}())
end

function action{P}(pomcp::POMCPPlanner2{P}, b)
    S = state_type(P)
    A = action_type(P)
    O = obs_type(P)
    tree = POMCPOWTree{POWNodeBelief{S,A,O,P},A,O,typeof(b)}(b, 2*pomcp.solver.tree_queries)
    pomcp.tree = tree
    return search(pomcp, tree)
end

function search(pomcp::POMCPPlanner2, tree::POMCPOWTree)
    all_terminal = true
    # gc_enable(false)
    for i in 1:pomcp.solver.tree_queries
        s = rand(pomcp.solver.rng, tree.root_belief)
        if !POMDPs.isterminal(pomcp.problem, s)
            simulate(pomcp, POWTreeObsNode(tree, 1), s, 0)
            all_terminal = false
        end
    end
    # gc_enable(true)

    if all_terminal
        throw(AllSamplesTerminal(tree.root_belief))
    end

    best_node = select_best(pomcp.solver.final_criterion, POWTreeObsNode(tree,1))

    return tree.a_labels[best_node]
end
