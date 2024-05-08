# SASLMR.jl

This program comes with absolutely no warranty. No liability is accepted for any loss and risk to public health resulting from use of this software.


[![Latest docs](https://img.shields.io/badge/docs-latest-blue.svg)](https://pharmcat.github.io/SASLMR.jl/dev/)

[![Stable docs](https://img.shields.io/badge/docs-stable-blue.svg)](https://pharmcat.github.io/SASLMR.jl/stable/)|

SASLMR.jl is Julia package, it wrapp `sasLM` package for R project for ANOVA type I/II/III.

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

Also functions: `aov1`, `aov2`, `aov3` can be used in the same way:

```
beaov = SASLMR.aov3(@formula(CMAX ~  PRD + TRT + SEQ + SUBJ&SEQ), bedf; beta=true, resid=true)
```

`AOVSumm` fields:

* heading

* ct

* parameters

* fitted

* residual

For more details see: 

https://cran.r-project.org/web/packages/sasLM/sasLM.pdf

https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7781810/

SASLMR.jl not cover all `sasLM` functionality... so... wellcome any PR for extending.
