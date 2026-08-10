using JuMP, HiGHS
import MultiObjectiveAlgorithms as MOA
using Polyhedra


# data ------------------------------------------------------------------------

p1 = [ 13, 10,  3, 16, 12, 11,  1,  9, 19, 13 ] # profit 1
p2 = [  1, 10,  3, 13, 12, 19, 16, 13, 11,  9 ] # profit 2
p3 = [ 17, 19,  3,  6, 12, 17, 18,  6,  6, 14 ] # profit 3
w  = [  4,  4,  3,  5,  5,  3,  2,  3,  5,  4 ] # weight
c  = 19                                         # capacity
n  = length(p1)                                 # number of items


# model -----------------------------------------------------------------------

mo01UKP = Model( )
@variable( mo01UKP, x[1:n], Bin )
@expression( mo01UKP, objective1, sum( p1[i] * x[i] for i in 1:n ) )
@expression( mo01UKP, objective2, sum( p2[i] * x[i] for i in 1:n ) )
@expression( mo01UKP, objective3, sum( p3[i] * x[i] for i in 1:n ) )
@objective( mo01UKP, Max, [ objective1 , objective2 , objective3 ] )
@constraint( mo01UKP, capacity, sum( w[i] * x[i] for i in 1:n ) ≤ c )


# solver ----------------------------------------------------------------------

set_optimizer( mo01UKP, () -> MOA.Optimizer(HiGHS.Optimizer) )
set_attribute( mo01UKP, MOA.Algorithm(), MOA.KirlikSayin() )
set_silent(mo01UKP)
optimize!(mo01UKP)


# analyze ---------------------------------------------------------------------

for i in 1:result_count(mo01UKP)
       z_opt =round.(Int, objective_value(mo01UKP; result = i))
       x_opt = round.(Int, value.(x; result=i))
       println("$i:  x= $x_opt  ||  y=f(x)= $z_opt")
end

Y_N = [round.(Int, objective_value(mo01UKP; result = i)) for i in 1:result_count(mo01UKP)]

set_attribute(mo01UKP, MOA.Algorithm(), MOA.GeneralDichotomy())
optimize!(mo01UKP)

Y_SN = [round.(Int, objective_value(mo01UKP; result = i)) for i in 1:result_count(mo01UKP)]
Y_NN = setdiff(Y_N, Y_SN)

using PlotlyJS

trace_SN = PlotlyJS.scatter3d(
              x=[Y_SN[i][1] for i in 1:length(Y_SN)],
              y=[Y_SN[i][2] for i in 1:length(Y_SN)],
              z=[Y_SN[i][3] for i in 1:length(Y_SN)],
              mode = "markers",
              name = "Y_SN",
              marker = attr(size=5, color="darkblue")
)

trace_NN = PlotlyJS.scatter3d(
              x=[Y_NN[i][1] for i in 1:length(Y_NN)],
              y=[Y_NN[i][2] for i in 1:length(Y_NN)],
              z=[Y_NN[i][3] for i in 1:length(Y_NN)],
              mode = "markers",
              name = "Y_NN",
              marker = attr(size=5, color="dodgerblue")
)

layout = Layout(
                  title = "Objective space : obj1 vs obj2 vs obj3",
                  scene = attr(    xaxis = attr(title="Objective 1"),
                                   yaxis = attr(title="Objective 2"),
                                   zaxis = attr(title="Objective 3")
                  )
)

PlotlyJS.plot([trace_SN, trace_NN], layout)