__precompile__()

module Pop

using CSV
using Clp
using Dates
using DataFrames
using JuMP
using Lazy
using TimeSeries

# import
export
    getDataFrame, getquotemedia, getlogreturn

# macros and support functions
# includes ahead

## Module Type Map ##
abstract type Policy end
abstract type Constraint end
abstract type CostModel end
abstract type RiskModel end
abstract type ReturnModel end
abstract type SimulatorResult end

# Constraint Family
# TODO: macro req: expression
# TODO: param req: bmk weight put outside
# TODO: method req: common method called _weight_expr (DEPRECATED)
struct MaxTrade         <: Constraint
    # w_bench::Union{Vector{Number}, Missing} # benchmark weight
    ADVs
    max_fraction # default value?
    # member fun: weight_expr
end
struct LongOnly         <: Constraint end
struct LeverageLimit    <: Constraint limit::Vector{Number} end
struct LongCash         <: Constraint end
struct DollarNeutral    <: Constraint end
struct MaxWeights       <: Constraint limit::Vector{Number} end
struct MinWeights       <: Constraint limit::Vector{Number} end
struct FactorMaxLimit   <: Constraint
    factor_exposure::Matrix{Number}
    limit::Vector{Number}
end
struct FactorMinLimit   <: Constraint
    factor_exposure::Matrix{Number}
    limit::Vector{Number}
end
struct FixedAlpha       <: Constraint
    return_forecast::Vector{Number} # forecast on each assets
    alpha_targe::Union{Vector{Number}, Number} # target portfolio ret
end


# Cost Family <: CostModel
# main mem func: estimate, time, trades, value, returns an expr for the tcosts
# call expression from cvx
mutable struct HCostModel <: CostModel
    borrowfee::Float64 # s
    mgmtfee::Float64 # f

    function HCostModel(;s::Float64, f::Float64)
        x = new()
        x.borrowfee, x.mgmtfee = [s, f]
        x
    end
end

mutable struct TCostModel <: CostModel # immutable
    halfspread::Float64 # a

    nlcoeff::Float64 # b = 1
    sigma::Float64 # realized volatility in the period
    volume::Int # total market dollar volume traded in the period
    gamma::Number # power of non-linear term

    asymcoeff::Float64 # c = 0, used for asymmetry

    # example: TCostModel(a = 1.0, b = 1.0, c = 1.0, sigma = 1.0, v = 1, gamma = 1)
    function TCostModel(;a::Float64, b::Float64 = 0.0, c::Float64 = 0.0,
                        sigma::Float64 = 0.0, v::Int = 1, gamma::Number = 1/2)
        x = new() # can only be defined in the struct
        x.halfspread, x.nlcoeff, x.asymcoeff = [a, b, c]
        x.sigma, x.volume, x.gamma = [sigma, v, gamma]
        x
    end
end

function Expr(m::HCostModel, weight_rep::Bool = true)
    if weight_rep
        expr = :($m.s * max(-(w + z), 0) - $m.f * (w + z))
    else
        expr = :(v * ($m.s * max(-(w + z), 0) - $m.f * (w + z)))
    end
end

function Expr(m::TCostModel, weight_rep::Bool = true)
    if weight_rep
        expr = :($(m.halfspread) * abs(z) +
            $(m.nlcoeff) * $(m.sigma) * (abs(z)/($(m.volume)/v))^$(m.gamma) * abs(x) +
            $(m.asymcoeff) * x)
    else
        expr = :($(m.halfspread) * abs(x) +
            $(m.nlcoeff) * $(m.sigma) * (abs(x)/$(m.volume)) ^ $(m.gamma) * abs(x) +
            $(m.asymcoeff) * x)
    end
    # TODO: assemble expressions to make the code easier to read and arrange
end

# function estimate(;costmodel::T, t::U, tau::U = t, w_plus::Vector{Number},
#     z::Vector{Number}, value::Vector{Number}
#     ) where {T<:CostModel, U<:TimeType}
# end

# Policy Family
struct Hold                 <: Policy end
struct RankAndLongShort     <: Policy end
struct ProportionalTrade    <: Policy end
struct SellAll              <: Policy end
struct FixedTrade           <: Policy end

abstract type Rebalance            <: Policy end
struct PeriodicRebalance    <: Rebalance end
struct AdaptiveRebalance    <: Rebalance end

struct SinglePeriodOpt      <: Policy end
struct MultiPeriodOpt       <: Policy end # in python, sub of SinglePeriodOpt

# Risk Family <: RiskModel
# w_bench, gamma_half_life
struct FullSigma                <: RiskModel end
struct EmpSigma                 <: RiskModel end
struct SqrtSigma                <: RiskModel end
struct FactorModelSigma         <: RiskModel end
struct RobustSigma              <: RiskModel end
struct RobustFactorModelSigma   <: RiskModel end
struct WorstCaseRisk            <: RiskModel end
gamma(m::M) where {M<:RiskModel} = 1
# wbench(m::M) where {M<:RiskModel} = getfield(m, :wbench)

# Returns Family
# struct ReturnsForecast          <: ReturnModel end
# struct MPOReturnsForecast       <: ReturnModel end
# struct MultipleReturnsForecasts <: ReturnModel end


###############################################################################
## Original API from cvxportfolio.py
###############################################################################

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
# function weight_expr(expr::T, t::Number,
#     w_bench::Union{Vector{Number}, Missing},
#     w_plus::Union{Vector{Number}, Missing},
#     z::Vector{Number}, value::Number
#     ) where {T <: Expression}
# end # weight_expr_ahead not implemented


"""
    value_expr(expr::Expression, t::Number, h_plus::Vector{Number},
        u::Vector{Number})
"""
# function value_expr(expr::Expression, t::Number,
#     h_plus::Vector{Number}, u::Vector{Number})
#     sum(h_plus) * weight_expr(expr, t, h_plus/sum(h_plus), u/sum(u), sum(h_plus))
# end


"""
    locator(obj::DataFrame, t::Date)

Utils: Pick last element before t, NOT IMPLEMENTED
In python, pick the last row from a pandas dataframe
"""
# function locator(obj::DataFrame, t::Date) end


"""
    getfq(df::Date)

Convert a Date to a fiscal quarter string
"""
getfq(df::Date) = string("Q", Int(floor((month(t)-1)/3) + 1), " ", year(t))



###############################################################################
## Data Processors
## include("data_processors.jl")
###############################################################################

"""
    getDataFrame(file::String)
    getDataFrame(file::Vector{String})

# Examples
```julia
# PENDING FOR GENERATING A TIMEARRAY
core = @as x rets convert(Array, x[:, 2:ncol(x)]) # drop date
symbols = @as x rets names(x)[1:(ncol(x)-1)]
typeof(convert(Array, rets)) <: AbstractArray

ts = TimeArray(convert(AbstractVector{Date}, rets[:date]),
    @as x rets convert(Array, Base.getindex(x, :, 2:ncol(x))))
cannot set colnames # this time array is sooooo weird

# GETTING VARIABLES FROM ./data
var_names = ["adjclose", "changep", "rollmean", "rollvcov", "volume"]
adjclose, rets, mean, vcov, vol =
    @>> var_names map(name -> string("../data/SF_", name, ".csv")) getDataFrame
```
"""
getDataFrame(file::String)::DataFrame = Lazy.@as x file CSV.File(x) DataFrame(x)
getDataFrame(files::Vector{String})::Vector{DataFrame} = map(getDataFrame, files)


"""
    getquotemedia(;start_date::Date, end_date::Date, symbol::String)

Get a raw DataFrame from QuoteMedia.com, dates are not the same as inputs.
TODO: having a bug when entering "EEM" on CSV.read(buffer)
"""
function getquotemedia(;start_date::Date = Date("2013-01-01"),
                        end_date::Date = Date("2018-01-01"),
                        symbol::String = "SPY"
                        )::DataFrame
    base_string1 = "http://app.quotemedia.com/quotetools/"
    base_string2 = "getHistoryDownload.csv?&webmasterId=501"
    url = string(base_string1, base_string2,
        "&startYear=", Dates.year(start_date),
        "&startMonth=", Dates.month(start_date),
        "&startDay=", Dates.day(start_date),
        "&endYear=", Dates.year(end_date),
        "&endMonth=", Dates.month(end_date),
        "&endDay=", Dates.day(end_date),
        "&isRanged=true&symbol=", symbol)

    res = HTTP.get(url) # HTTP responce
    buffer = IOBuffer(res.body)
    table = CSV.read(buffer)

    table[:changep] = map(table[:changep]) do ret
        parse(Float64, ret[1:length(ret)-1]) / 100
    end  # reformat the percentage signs

    DataFrames.rename(table, :changep => :ret)
end

"""
    getlogreturn(symbols::Vector{String})

Get a DataFrame of log returns using QuoteMedia.com, colnames
are date + names of symbols

Example: getlogreturn(["SPY", "EFA"])
"""
function getlogreturn(symbols::Vector{String})::DataFrame
    date_range = Date(2014, 1, 1):Dates.Day(1):Date(2017, 12, 31)

    returns = getquotemedia(symbol = symbols[1])[[:date, :ret]]
    # returns = DataFrames.DataFrame(Float64, length(symbols), length(date_range))s

    period_bool = map(x -> x in date_range, returns[:date])
    returns = returns[period_bool, :]

    DataFrames.rename!(returns, :ret => Symbol(symbols[1]))

    map(symbols[2:length(symbols)]) do symbol # drop the first one
        table = getquotemedia(symbol = symbol)[[:date, :ret]]
        returns[Symbol(symbol)] = table[period_bool, :ret]
    end
    returns
end

# other includes

end
