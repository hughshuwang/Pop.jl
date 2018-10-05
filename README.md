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
  
```



## TODOs

- [ ] 5 Primary Factor ETFs to start with: 
  - [ ] Quality
  - [ ] Value
  - [ ] Momentum
  - [ ] Size
  - [ ] Volatility
- [ ] Data format: `.csv` file with prices, log returns, volumes, spreads































