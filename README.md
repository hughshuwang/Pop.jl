# Pop.jl

**Portfolio Optimization and Simulation in Julia**  
**Author:** Shu Wang (hugh.shu.wang@gmail.com)  
**Created:** September 8th, 2018 (one month after the release of Julia v1.0)



[TOC]

## Conventions

- Following [Official Style Guide in Julia 1.0.0 Documentation](https://docs.julialang.org/en/v1/manual/style-guide/index.html).
- Following [AngularJS Git Commit Message Rules](https://gist.github.com/stephenparish/9941e89d80e2bc58a153).

## Versions

```julia
julia> versioninfo()
Julia Version 1.0.1
Commit 0d713926f8 (2018-09-29 19:05 UTC)
Platform Info:
  OS: macOS (x86_64-apple-darwin14.5.0)
  CPU: Intel(R) Core(TM) i5-5257U CPU @ 2.70GHz
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-6.0.0 (ORCJIT, broadwell)

julia> Pkg.status()
    Status `~/.julia/environments/v1.0/Project.toml`
  [c52e3926] Atom v0.7.8
  [336ed68f] CSV v0.4.1
  [e2554f3b] Clp v0.5.0
  [a93c6f00] DataFrames v0.14.1
  [4076af6c] JuMP v0.18.3
  [e5e0dc1b] Juno v0.5.3
  [50d2b5c4] Lazy v0.13.1
  [1d978283] TensorFlow v0.10.2
  [9e3dc215] TimeSeries v0.13.0

```



## Guidelines

- Optimizing Global Equity Factor Tilting (iShares Core ETFs)
- **Starting point**: `SF`, allocating across Six Primary US Equity Factors:
  - `MTUM`: [iShares Edge MSCI USA Momentum Factor ETF](https://www.ishares.com/us/products/251614/ishares-msci-usa-momentum-factor-etf), Inception: Apr 16, 2013
  - `QUAL`: [iShares Edge MSCI USA Quality Factor ETF](https://www.ishares.com/us/products/256101/ishares-msci-usa-quality-factor-etf), Inception: Jul 16, 2013
  - `VLUE`: [iShares Edge MSCI USA Value Factor ETF](https://www.ishares.com/us/products/251616/ishares-msci-usa-value-factor-etf), Inception: Apr 16, 2013
  - `SIZE`: [iShares Edge MSCI USA Size Factor ETF](https://www.ishares.com/us/products/251465/ishares-msci-usa-size-factor-etf), Inception: Apr 16, 2013
  - `USMV`: [iShares Edge MSCI Min Vol USA ETF](https://www.ishares.com/us/products/239695/ishares-msci-usa-minimum-volatility-etf), Inception: Oct 18, 2011
  - `SPY`: SPDR S&P 500 Trust ETF, Inception: Jan 22, 1993
  - Datasets: take common sub-index without NA and zero value across 6 ETFs and 9 core variables. 9 separate files are stored in `./data` (1019 * 9). Files named as `<SF_variablename.csv>`. Columns named as `<variablename.TICKER>` and `date` with format `%Y-%m-%d`. Data prep implemented in `R`, will be done in `Julia` soon. 
  - Process stored in `./src/0-Pop.R`.
- **Global Control:** time series and data frames of key variables, manage time index, forward and backward looking, rolling apply, estimates. Key variables saved as data frames or time series before entering the optimization system. Once start optimization, won't be able to dynamically change the data frames.
- **Optimization:** portfolio optimization framework connecting JuMP API using macros.

































