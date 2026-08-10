using JuMP, GLPK
import MultiObjectiveAlgorithms as MOA

model = Model( )
@variable(model, x1≥0, Int)
@variable(model, x2≥0, Int)
@expression(model, fct1, x1 + x2)
@expression(model, fct2, x1 + 3 * x2)
@expression(model, fct3, 6*x1 + 2 * x2)
@objective(model, Max, [fct1, fct2, fct3])
@constraint(model, 2*x1 + 3*x2 ≤ 30)
@constraint(model, 3*x1 + 2*x2 ≤ 30)
@constraint(model, x1 - x2 ≤ 5.5)

set_optimizer(model,()->MOA.Optimizer(GLPK.Optimizer))
set_attribute(model, MOA.Algorithm(), MOA.KirlikSayin())
#set_attribute(model, MOA.Algorithm(), MOA.DominguezRios())
#set_attribute(model, MOA.Algorithm(), MOA.TambyVanderpooten())

optimize!(model)

for i in 1:result_count(model)
       z1_opt = objective_value(model; result = i)[1]
       z2_opt = objective_value(model; result = i)[2]
       z3_opt = objective_value(model; result = i)[3]
       x1_opt = value(x1; result = i)
       x2_opt = value(x2; result = i)
       println("$i: x=($x1_opt, $x2_opt) || y=f(x)=( $z1_opt , $z2_opt , $z3_opt)")
end


using PlotlyJS

scatter3d = PlotlyJS.scatter3d(
              x=[objective_value(model; result = i)[1] for i in 1:result_count(model)],
              y=[objective_value(model; result = i)[2] for i in 1:result_count(model)],
              z=[objective_value(model; result = i)[3] for i in 1:result_count(model)],
              mode = "markers",
              marker = attr(       size=5, 
                                   color="red", 
                                   colorscale="Viridis"
              )
)

layout = Layout(
                  title = "Objective space : obj1 vs obj2 vs obj3",
                  scene = attr(    xaxis = attr(title="Objective 1"),
                                   yaxis = attr(title="Objective 2"),
                                   zaxis = attr(title="Objective 3")
                  )
)
              
plot(scatter3d, layout)


#=       
1: x=(6.0, 6.0) || y=f(x)=( 12.0 , 24.0 , 48.0)
2: x=(4.0, 7.0) || y=f(x)=( 11.0 , 25.0 , 38.0)
3: x=(3.0, 8.0) || y=f(x)=( 11.0 , 27.0 , 34.0)
4: x=(8.0, 3.0) || y=f(x)=( 11.0 , 17.0 , 54.0)
5: x=(1.0, 9.0) || y=f(x)=( 10.0 , 28.0 , 24.0)
6: x=(7.0, 4.0) || y=f(x)=( 11.0 , 19.0 , 50.0)
7: x=(0.0, 10.0) || y=f(x)=( 10.0 , 30.0 , 20.0)
=#

#=
5: x=(1.0, 9.0) || y=f(x)=( 10.0 , 28.0 , 24.0)
7: x=(0.0, 10.0) || y=f(x)=( 10.0 , 30.0 , 20.0)
4: x=(8.0, 3.0) || y=f(x)=( 11.0 , 17.0 , 54.0)
6: x=(7.0, 4.0) || y=f(x)=( 11.0 , 19.0 , 50.0)
2: x=(4.0, 7.0) || y=f(x)=( 11.0 , 25.0 , 38.0)
3: x=(3.0, 8.0) || y=f(x)=( 11.0 , 27.0 , 34.0)
1: x=(6.0, 6.0) || y=f(x)=( 12.0 , 24.0 , 48.0)

7: x=(1.0, 9.0) || y=f(x)=( 10.0 , 28.0 , 24.0)
4: x=(0.0, 10.0) || y=f(x)=( 10.0 , 30.0 , 20.0)
3: x=(8.0, 3.0) || y=f(x)=( 11.0 , 17.0 , 54.0)
6: x=(7.0, 4.0) || y=f(x)=( 11.0 , 19.0 , 50.0)
5: x=(4.0, 7.0) || y=f(x)=( 11.0 , 25.0 , 38.0)
2: x=(3.0, 8.0) || y=f(x)=( 11.0 , 27.0 , 34.0)
1: x=(6.0, 6.0) || y=f(x)=( 12.0 , 24.0 , 48.0)


2: x=(1.0, 9.0) || y=f(x)=( 10.0 , 28.0 , 24.0)
4: x=(0.0, 10.0) || y=f(x)=( 10.0 , 30.0 , 20.0)
7: x=(8.0, 3.0) || y=f(x)=( 11.0 , 17.0 , 54.0)
5: x=(7.0, 4.0) || y=f(x)=( 11.0 , 19.0 , 50.0)
3: x=(4.0, 7.0) || y=f(x)=( 11.0 , 25.0 , 38.0)
1: x=(3.0, 8.0) || y=f(x)=( 11.0 , 27.0 , 34.0)
6: x=(6.0, 6.0) || y=f(x)=( 12.0 , 24.0 , 48.0)
=#
