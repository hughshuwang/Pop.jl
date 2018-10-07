# THIS SCRIPT IS UNDER CONSTRUCTION

###############################################################################
## Optimization Playground Script, Single Period Optimization
###############################################################################

using Clp
using Dates
using JuMP
using Lazy
using DataFrames

include("Pop.jl") # core

## data prep ##
var_names = ["adjclose", "changep", "rollmean", "rollvcov", "volume"]
adjclose, rets, mean, vcov, vol =
    @>> var_names map(x -> string("./data/SF_", x, ".csv")) Pop.getDataFrame()

timeidx = convert(Vector{Date}, adjclose[:date])
n = ncol(adjclose) - 1 # number of assets, minus date, cash exluded
wt = ones(Float64, n) ./ n # initial weights known at the beginning, t-

tm1 = Date(2018, 1, 3) # t minus 1, get realized rolling mean and std
t = @as x timeidx x[(1:length(x))[x .== tm1][1] + 1]
    # not used in the optimization, not forward looking, saved for use

μt = mean[mean[:date] .== tm1, :] # used as estimate for time t

# toy functions for manipulating Matrix{Tuple{Int 64, Int 64}}
flip(c::Tuple{Int64, Int64}) = c[1] <= c[2] ? (c[1], c[2]) : (c[2], c[1])
sequpper(c::Tuple{Int64, Int64}, n::Int64) = (sum((n-(c[1]-2)):n) + (c[2]-c[1]+1))

tuples = [(i, j) for i in 1:n, j in 1:n] # raw tuples
Σ = @as x vcov x[x[:date] .== tm1, :] convert(Array, x) Vector{Float64}(x[2:length(x)])
Σt = @. Σ[sequpper(flip(tuples), n)] # estimate of vcov at time t

    # output a set of parameters
    # snapshot(dataframes, date), get a struct of dataset
    # optimization process build should be finished in compile time
    # in script apply the optimizer in a rolling window

# prepare riskmodels
# prepare costmodels
# prepare additional constraints just control excluding cash



## Model Init ##

# function input: n, wt, μt, Σ, riskmodel, tcostmodel, hcostmodel, (initialized)
# additional constraints, (self-financing constraints are fixed inside)

m = Model(solver = ClpSolver()) # cannot run immediately, compile the problem once

## Building model ##

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
