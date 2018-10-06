# THIS SCRIPT IS UNDER CONSTRUCTION

###############################################################################
## Optimization Playground Script, Single Period Optimization
###############################################################################

using Clp
using JuMP
using Lazy
using DataFrames

include("Pop.jl") # core

## data prep ##
var_names = ["adjclose", "changep", "rollmean", "rollvcov", "volume"]
adjclose, rets, mean, vcov, vol =
    @>> var_names map(name -> string("./data/SF_", name, ".csv")) Pop.getDataFrame()
n = ncol(adjclose) # number of assets, plus cash, minus date
w = ones(Float64, n) ./ n # initial weights known

    # output a set of parameters
    # snapshot(dataframes, date), get a struct of dataset
    # optimization process build should be finished in compile time
    # in script apply the optimizer in a rolling window


## Model Init ##
m = Model(solver = ClpSolver())
    # cannot run immediately, must compile the whole problem set once


## Building model ##

    # params are globally set: (n, models, w)
    # var naming:
    #    w: original weights, wp: weights after trading, z: rading weights
    #   rp: return_portfolio, rh: return_head (estimated)
    # sections:
    #   variables
    #   expressions
    #   constraints
    #   objectives

@variable(m, z[1:n]) # control vars: weights
# TODO: set of trading constraints and holding constraints

ret = AffExpr(wp, rh) # portfolio return fixed affine
# TODO: riskp = QuadExpr() # build Omega
# TODO: other risk metrics in Expr

@expression(m, ret)
@expression(m, risk)
@expression(m, Expr(tcostmodel)) # add method for Expr
@expression(m, Expr(hcostmodel))

# @expression(m, ) # affine return function
# @objective(m, )

@constraint(m, 1x + 5y <= 3.0)

@objective(m, Max, 5x + 3y)

status = solve(m)

    # inspect outputs
    # print(m)
    # status = solve(m)
    # println("Objective value: ", getobjectivevalue(m))
    # println("x = ", getvalue(x))
