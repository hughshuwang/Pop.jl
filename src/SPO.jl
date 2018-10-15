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

## local toy functions ##
slice(df::DataFrame, t::Date) = @as x df x[x[:date] .== t, :] convert(Array, x) Vector{Float64}(x[2:length(x)])
flip(c::Tuple{Int64, Int64}) = c[1] <= c[2] ? (c[1], c[2]) : (c[2], c[1])
sequpper(c::Tuple{Int64, Int64}, n::Int64) = (sum((n-(c[1]-2)):n) + (c[2]-c[1]+1))

## data prep ##
varnames = ["adjclose", "changep", "rollmean", "rollvcov", "volume"]
adjclose, rets, mean, vcov, vol =
    @>> varnames map(x -> string("./data/SF_", x, ".csv")) Pop.getDataFrame()

timeidx = convert(Vector{Date}, adjclose[:date])
n = ncol(adjclose) - 1 # number of assets, minus date, cash exluded
wt = ones(Float64, n) ./ n # initial weights known at the beginning, t-

tm1 = Date(2018, 1, 3) # t minus 1, get realized rolling mean and std
t = @as x timeidx x[(1:length(x))[x .== tm1][1] + 1]

# Estimates for time t
μt = slice(mean, tm1)
Σ = slice(vcov, tm1) # vectorized vcov realized at t-1
Σt = @. Σ[sequpper(flip([(i, j) for i in 1:n, j in 1:n]), n)]
σt = [Σt[i, i] for i in 1:n]

    # output a set of parameters
    # optimization process build should be finished in compile time
    # in script apply the optimizer in a rolling window

# prepare riskmodels
# HcostModel(...) # use params to initialize # past models to the function
# TODO: weekly average volume required for this estimate, for now just use realized
basictcost = TCostModel(a = 0.5/100, b = 0.0, c = 0.0, sigma = 0.0, v = 1, gamma = 1/2)
tcostmodels = repeat([basictcost], n) # assume that no transaction costs for cash account
# prepare additional constraints just control excluding cash
basichcost = HCostModel(s = 1.0, f = 1.0)
hcostmodels = repeat([basichcost], n)

## Model Init ##
# TODO: make 4.4 work first as the benchmark

# function input: n, wt, μt, Σ, riskmodel, a vector of tcostmodel,
#   a vector of hcostmodel, (initialized)
#   additional constraints, (self-financing constraints are fixed inside)

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

@expression(m, ret, AffExpr(wt+zt, μt))
@expression(m, risk, QuadExpr(wt, Σt)) # TODO: other risk metrics

@expression(m, tcost[1:n], @. Expr(tcostmodels) # n cost models for assets
    # TODO: should eval members when generating the expressions
@expression(m, hcost, Expr(hcostmodel))

# @expression(m, ) # affine return function
# @objective(m, )

@constraint(m, 1x + 5y <= 3.0) # self-financing constraints using cost models
@objective(m, min, 5x + 3y)

status = solve(m)

    # inspect outputs
    # print(m)
    # status = solve(m)
    # println("Objective value: ", getobjectivevalue(m))
    # println("x = ", getvalue(x))
