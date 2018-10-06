module DataMgmt

using CSV
using Dates
using DataFrames
using JuMP
using Lazy
using TimeSeries

# import
# export

@doc """
    getDataFrame(file::String)
    getDataFrame(file::Vector{String})
"""
function getDataFrame(file::String)::DataFrame
    rets = Lazy.@as x file CSV.File(x) DataFrame(x) x[:, 2:ncol(x)] # Base.getindex

    # PENDING FOR GENERATING A TIMEARRAY
    # core = @as x rets convert(Array, x[:, 2:ncol(x)]) # drop date
    # symbols = @as x rets names(x)[1:(ncol(x)-1)]
    # typeof(convert(Array, rets)) <: AbstractArray

    # ts = TimeArray(convert(AbstractVector{Date}, rets[:date]),
    #     @as x rets convert(Array, Base.getindex(x, :, 2:ncol(x))))
    # cannot set colnames # this time array is sooooo weird

    rets
end
getDataFrame(files::Vector{String})::Vector{DataFrame} = map(getDataFrame, files)


@doc """
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



@doc """
    getlogreturn(symbols::Vector{String})

Get a DataFrame of log returns using QuoteMedia.com, colnames
are date + names of symbols

Example:
getlogreturn(["SPY", "EFA"])
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



end
