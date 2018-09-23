VERSION < v"1.0.0" && __precompile__()

module Pop

using Dates

# import
# export
# macros and support functions
# includes ahead

# Module Type Map
abstract type Expression end
abstract type BaseCost          <: Expression end # gamma para
abstract type BasePolicy        <: Expression end
abstract type BaseConstraint    <: Expression end
abstract type BaseRisk          <: Expression end
abstract type BaseReturns       <: Expression end
abstract type SimulatorResult end


# Constraint Family
# bmk weight put outside
# common method called _weight_expr
struct MaxTrade         <: BaseConstraint
    # w_bench::Union{Vector{Number}, Missing} # benchmark weight
    ADVs
    max_fraction # default value?
    # member fun: weight_expr
end
struct LongOnly         <: BaseConstraint end
struct LeverageLimit    <: BaseConstraint
    limit::Vector{Number}
end
struct LongCash         <: BaseConstraint end
struct DollarNeutral    <: BaseConstraint end
struct MaxWeights       <: BaseConstraint
    limit::Vector{Number}
end
struct MinWeights       <: BaseConstraint
    limit::Vector{Number}
end
struct FactorMaxLimit   <: BaseConstraint
    factor_exposure::Matrix{Number}
    limit::Vector{Number}
end
struct FactorMinLimit   <: BaseConstraint
    factor_exposure::Matrix{Number}
    limit::Vector{Number}
end
struct FixedAlpha       <: BaseConstraint
    return_forecast::Vector{Number} # forecast on each assets
    alpha_targe::Union{Vector{Number}, Number} # target portfolio ret
end


# Cost Family
struct HcostModel <: BaseCost end
struct TcostModel <: BaseCost end

struct Hold                 <: BasePolicy end
struct RankAndLongShort     <: BasePolicy end
struct ProportionalTrade    <: BasePolicy end
struct SellAll              <: BasePolicy end
struct FixedTrade           <: BasePolicy end

struct BaseRebalance        <: BasePolicy end
struct PeriodicRebalance    <: BaseRebalance end
struct AdaptiveRebalance    <: BaseRebalance end

struct SinglePeriodOpt      <: BasePolicy end
struct MultiPeriodOpt       <: BasePolicy end # in python, sub of SinglePeriodOpt

struct FullSigma                <: BaseRisk end
struct EmpSigma                 <: BaseRisk end
struct SqrtSigma                <: BaseRisk end
struct FactorModelSigma         <: BaseRisk end
struct RobustSigma              <: BaseRisk end
struct RobustFactorModelSigma   <: BaseRisk end
struct WorstCaseRisk            <: BaseRisk end

struct ReturnsForecast          <: BaseReturns end
struct MPOReturnsForecast       <: BaseReturns end
struct MultipleReturnsForecasts <: BaseReturns end


"""
    weight_expr(expr::Expression, t::Number, w_plut::Vector{Number},
        z::Vector{Number}, value::Number)

General case for all expressions (subtypes)
Returns a list of trade constraints
Args:
    t: time index
    w_plus: post trade weights
    z: trade weights
    v: portfolio dollar value
"""
function weight_expr(expr::T, t::Number,
    w_bench::Union{Vector{Number}, Missing},
    w_plus::Union{Vector{Number}, Missing},
    z::Vector{Number}, value::Number
    ) where {T <: Expression}
end # weight_expr_ahead not implemented


"""
    value_expr(expr::Expression, t::Number, h_plus::Vector{Number},
        u::Vector{Number})
"""
function value_expr(expr::Expression, t::Number,
    h_plus::Vector{Number}, u::Vector{Number})
    sum(h_plus) * weight_expr(expr, t, h_plus/sum(h_plus), u/sum(u), sum(h_plus))
end


"""
    locator(obj::DataFrame, t::Date)

Utils: Pick last element before t, NOT IMPLEMENTED
In python, pick the last row from a pandas dataframe
"""
function locator(obj::DataFrame, t::Date) end



"""
    getfisquarter(df::Date)

Convert a Date to a fiscal quarter string
"""
getfisquarter(df::Date) =  string("Q", Int64(floor((month(t) - 1) / 3) + 1), " ", year(t))


# other includes

end
