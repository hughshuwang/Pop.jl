using CSV
using Dates
using DataFrames
using TimeSeries
using Lazy

include("Pop.jl") # core

tickers = ["MTUM", "QUAL", "VLUE", "SIZE", "USMV", "SPY"]
columns = ["open", "high", "low", "close", "adjclose", "changep", "volume",
  "tradeval", "tradevol"]
spread = [0.02, 0.03, 0.02, 0.11, 0.02, 0.00] # in percentage
  # obtained from monthly estimates in Fidelity's Screener

map(x -> string("./data/SF_", x, ".csv"), [columns..., "rollmean", "rollvcov"])

varlist = map(tickers) do ticker
  dropmissing(Pop.getquotemedia(symbol = ticker, end_date = today()))[:, 1:9]
end
  # TODO: some columns are changed to Union{missing, String} since "N/A"s exist
  # TODO: still some columns are Union{missing, Float64}

df = varlist[4]
strsym = names(df)[colwise(x -> String <: eltype(x), df)]
df = @as x strsym map(s -> df[:, s] .!= "N/A", x) broadcast(&, x...) getindex(df, x, :)
  # filter! can only apply on one column rowwise
map(strsym) do str df[str] = map(x -> parse(Float64, x), df[str]) end
