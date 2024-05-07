module SASLMR

using RCall, StatsModels, StatsBase, DataFrames

import Base: show

import StatsBase: coeftable

export aov1, aov2, aov3, aov, coeftable

function __init__()
    if !rcopy(R"'sasLM' %in% installed.packages()")
        @error "sasLM not found..."
    else
        R"library(sasLM)"
    end
    return nothing
end

struct AOVSumm
    heading::String
    ct::CoefTable
    parameters::AbstractArray
    fitted::AbstractArray
    residual::AbstractArray
end


function _aov1(f, d, beta, resid)
    @rput f
    @rput d
    @rput beta
    @rput resid
    R"result <- aov1(f, d, BETA=beta, Resid=resid)"
end

function _aov2(f, d, beta, resid)
    @rput f
    @rput d
    @rput beta
    @rput resid
    R"result <- aov2(f, d, BETA=beta, Resid=resid)"
end

function _aov3(f, d, beta, resid)
    @rput f
    @rput d
    @rput beta
    @rput resid
    R"result <- aov3(f, d, BETA=beta, Resid=resid)"
end
"""
    aov1(f, d; beta=true, resid=true)

Function:

aov1(Formula, Data, BETA=FALSE, Resid=FALSE)

ANOVA with Type I SS.

Arguments:

Formula a conventional formula for a linear model.

Data a data.frame to be analyzed

BETA if TRUE, coefficients (parameters) of REG will be returned. This is equivalent to SOLUTION option of SAS PROC GLM

Resid if TRUE, fitted values (y hat) and residuals will be returned

Details

It performs the core function of SAS PROC GLM, and returns Type I SS. This accepts continuous independent variables also.

Value

The result table is comparable to that of SAS PROC ANOVA.

Df degree of freedom

Sum Sq sum of square for the set of contrasts

Mean Sq mean square

F value F value for the F distribution

Pr(>F) proability of larger than F value

Next returns are optional.

Parameter Parameter table with standard error, t value, p value. TRUE is 1, and FALSE is 0 in the Estimable column. This is returned only with BETA=TRUE option.

Fitted Fitted value or y hat. This is returned only with Resid=TRUE option.

Residual Weigthed residuals. This is returned only with Resid=TRUE option.
"""
function aov1(f, d; beta=true, resid=true)
    aov(f, d; beta=beta, resid=resid, type = "I")
end

"""
    aov2(f, d; beta=true, resid=true)

Function:

aov2(Formula, Data, BETA=FALSE, Resid=FALSE)

ANOVA with Type II SS.

Description see `aov1`.
"""
function aov2(f, d; beta=true, resid=true)
    aov(f, d; beta=beta, resid=resid, type = "II")
end

"""
    aov3(f, d; beta=true, resid=true)

Function:

aov3(Formula, Data, BETA=FALSE, Resid=FALSE)

ANOVA with Type III SS.

Description see `aov1`.
"""
function aov3(f, d; beta=true, resid=true)
    aov(f, d; beta=beta, resid=resid, type = "III")
end

function checktype(type::Int)
    type
end
function checktype(type::String)
    type == "I" && return 1
    type == "II" && return 2
    type == "III" && return 3
    @error "Unknown ANOVA type..."
end

"""
    aov(f, d; beta=true, resid=true, type = "III")

Same as `aov1`, `aov2`, `aov3`.

Keyword `type`: ANOVA SS Type I/II/III (III by default).
"""
function aov(f, d; beta=true, resid=true, type = "III")

    type_ = checktype(type)
    if type_ == 1
        robj = _aov1(f, d, beta, resid)
    elseif type_ == 2
        robj = _aov2(f, d, beta, resid)
    elseif type_ == 3
        robj = _aov3(f, d, beta, resid)
    else
        @error "Unknown ANOVA type..."
    end

    if beta || resid
        R"ar <- result$ANOVA"
        heading = rcopy(R"attr(x = ar, which = 'heading')")
        arm = @rget ar
    else
        heading = rcopy(R"attr(x = result, which = 'heading')")
        arm = @rget result
    end
    replace!(arm, missing => NaN)
    ct = CoefTable(Matrix(arm), rcopy(R"colnames(ar)"), rcopy(R"rownames(ar)"), 5, 4)
    if beta
        p = rcopy(R"result[2]")[:Parameter]
    else
        p = Float64[]
    end
    if beta && resid
        r = rcopy(R"result[4]")[:Residual]
        y = rcopy(R"result[3]")[:Fitted]
    else
        r = Float64[]
        y = Float64[]
    end
    RCall.release(robj)
    AOVSumm(string(heading), ct, p, y, r)
end

struct RTT
    heading::String
    ct::CoefTable
end

struct RTRes
    tables::Vector{RTT}
    ems::DataFrame
end

# CIest(CMAX~PRD + TRT + SEQ + SUBJ:SEQ, BEdata, "TRT",c(-1, 1), 0.1)

# rt = RanTest(CMAX~PRD + TRT + SEQ + SUBJ:SEQ, BEdata, Random="SUBJ", Type=3, eps=1e-8)
"""
    rantest(f, d, random; type = "III", eps::Float64 = 1e-8)

 Hypothesis test of with specified type SS using random effects as error terms. This corresponds to
SAS PROC GLM’s RANDOM /TEST clause

Same as:

```
RanTest(f, d, Random = "", Type=3, eps=1e-8)
```

Type can be from 1 to 3. All interaction terms with random factor are regarded as random effects.
Here the error term should not be MSE

Returns ANOVA and E(MS) tables with specified type SS.
"""
function rantest(f, d, random; type = "III", eps::Float64 = 1e-8)

    type_ = checktype(type)

    random = string.(random)
    @rput f
    @rput d
    @rput random
    @rput type_
    @rput eps

    robj = R"result <- RanTest(f, d, Random = random, Type = type_, eps = eps)"
    
    robjl = rcopy(R"length(result)")

    df = rcopy(R"result$EMS")

    if robjl == 2
        arm = rcopy(R"result[[1]]")
        replace!(arm, missing => NaN)
        ct = CoefTable(Matrix(arm), rcopy(R"colnames(result[[1]])"), rcopy(R"rownames(result[[1]])"), 5, 4)
        rtt = [RTT("",ct)]
    else
        rtt = Vector{RTT}(undef, 0)
        for i = 1:robjl - 1
            @rput i
            arm = rcopy(R"result[[i]]")
            replace!(arm, missing => NaN)
            ct = CoefTable(Matrix(arm), rcopy(R"colnames(result[[i]])"), rcopy(R"rownames(result[[i]])"), 5, 4)
            heading = rcopy(R"attr(x = result[[i]], which = 'heading')")
            if isnothing(heading) heading = "" end
            push!(rtt, RTT(string(heading), ct))
        end
    end
    RCall.release(robj)
    return RTRes(rtt, df)
end


"""
    StatsBase.coeftable(obj::AOVSumm)
"""
function StatsBase.coeftable(obj::AOVSumm)
    obj.ct
end


function Base.show(io::IO, obj::AOVSumm)
    println(io, obj.heading)
    println(io, obj.ct)
end

function Base.show(io::IO, obj::RTRes)
    for t in obj.tables
        println(io, t.heading)
        println(io, t.ct)
    end
end


"""
    bedata()

Return BEdata (Contains Cmax data from a real bioequivalence study).
"""
function bedata()
    rcopy(R"BEdata")
end

end # end module SASLMR


#R"T3MS(CMAX ~  PRD + TRT + SEQ + SUBJ:SEQ, BEdata)"


