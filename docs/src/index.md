```@meta
CurrentModule = SASLMR
```

# SASLMR

Documentation for [SASLMR](https://github.com/PharmCat/SASLMR.jl).

This program comes with absolutely no warranty. No liability is accepted for any loss and risk to public health resulting from use of this software.

SASLMR.jl is Julia package, it wrapp `sasLM` package for R project for ANOVA type I/II/III.

Exported functions: `aov1`, `aov2`, `aov3`, `aov`, `ciest`, `rantest`

Install:

```
import Pkg; Pkg.add(url="https://github.com/PharmCat/SASLMR.jl.git")
```

Note:

SASLMR.jl doesn't install `sasLM`. To use SASLMR.jl first install `sasLM` in your R project enviroment. 
Check that R project is included in `PATH`, and check that RCall.jl builded successfully.

Using:


```
using SASLMR
using StatsModels, StatsBase, DataFrames

# data (DataFrame)
bedf = SASLMR.bedata()

# run ANOVA
beaov = SASLMR.aov(@formula(CMAX ~  PRD + TRT + SEQ + SUBJ&SEQ), bedf; beta=true, resid=true, type = "III")

# get DF
beaovdf = DataFrame(beaov.ct)

# or get coeftable

ct = coeftable(beaov)
```

For more details see: 

https://cran.r-project.org/web/packages/sasLM/sasLM.pdf

https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7781810/

SASLMR.jl not cover all `sasLM` functionality... so... wellcome any PR for extending.


```@index
```

```@autodocs
Modules = [SASLMR]
```
