using JuMP, HiGHS

modLP = Model( )
@variable(modLP, x1 ≥ 0)
@variable(modLP, x2 ≥ 0)
@objective(modLP, Max, x1 + 3x2)
@constraint(modLP, cst1, x1 + x2 ≤ 14)
@constraint(modLP, cst2, -2x1 + 3x2 ≤ 12)
@constraint(modLP, cst3, 2x1 - x2 ≤ 12)
print(modLP)

set_optimizer(modLP, HiGHS.Optimizer)
set_silent(modLP)
optimize!(modLP)

@show is_solved_and_feasible(modLP)
@show objective_value(modLP)
@show value(x1), value(x2)