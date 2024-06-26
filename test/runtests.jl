using SASLMR
using Test, StatsModels, StatsBase, DataFrames

f = @formula(a ~ b)
d = DataFrame(a = [1,2,3,4,5,6,7,8], b = ["A", "A", "A", "A", "B", "B", "B", "B"])

io = IOBuffer();
@testset "SASLMR.jl" begin
    @test_nowarn SASLMR.aov1(f, d; beta=true, resid=true)
    @test_nowarn SASLMR.aov1(f, d; beta=false, resid=false)
    @test_nowarn SASLMR.aov1(f, d; beta=true, resid=false)
    @test_nowarn SASLMR.aov1(f, d; beta=false, resid=true)

    @test_nowarn SASLMR.aov2(f, d; beta=true, resid=true)
    @test_nowarn SASLMR.aov2(f, d; beta=false, resid=false)
    @test_nowarn SASLMR.aov2(f, d; beta=true, resid=false)
    @test_nowarn SASLMR.aov2(f, d; beta=false, resid=true)

    @test_nowarn SASLMR.aov3(f, d; beta=true, resid=true)
    @test_nowarn SASLMR.aov3(f, d; beta=false, resid=false)
    @test_nowarn SASLMR.aov3(f, d; beta=true, resid=false)
    @test_nowarn SASLMR.aov3(f, d; beta=false, resid=true)

    aovres = SASLMR.aov(f, d; beta=false, resid=true, type = "III")

    @test_nowarn show(io, aovres)


    bedf = SASLMR.bedata()

    beaov = SASLMR.aov(@formula(CMAX ~  PRD + TRT + SEQ + SUBJ&SEQ), bedf; beta=true, resid=true, type = "I")
    beaovdf = DataFrame(beaov.ct)

    @test beaovdf.Df == [48,1,1,1,45,42,90]
    @test beaovdf[!, "Sum Sq"] ≈ [6256819.0,770,1047,331262,5923740 ,1151444,7408263 ] atol=1

    beaov = SASLMR.aov(@formula(CMAX ~  PRD + TRT + SEQ + SUBJ&SEQ), bedf; beta=true, resid=true, type = "II")
    beaovdf = DataFrame(beaov.ct)

    @test beaovdf.Df == [48,1,1,1,45,42,90]
    @test beaovdf[!, "Sum Sq"] ≈ [6256819.0,11108,2181,331262,5923740,1151444,7408263 ] atol=1

    beaov = SASLMR.aov(@formula(CMAX ~  PRD + TRT + SEQ + SUBJ&SEQ), bedf; beta=true, resid=true, type = "III")
    beaovdf = DataFrame(beaov.ct)

    @test beaovdf.Df == [48,1,1,1,45,42,90]
    @test beaovdf[!, "Sum Sq"] ≈ [6256819.0,11108,2181,219450,5923740,1151444,7408263 ] atol=1


    @test_nowarn res = SASLMR.rantest(@formula(CMAX ~  PRD + TRT + SEQ + SUBJ&SEQ), bedf, "SUBJ"; type = 1)
    @test_nowarn res = SASLMR.rantest(@formula(CMAX ~  PRD + TRT + SEQ + SUBJ), bedf, "SUBJ"; type = 1)

    res = SASLMR.ciest(@formula(CMAX ~  PRD + TRT + SEQ + SUBJ&SEQ), bedf, "TRT", [-1, 1]; level = 0.9)
    @test collect(res) ≈ collect((-49.46976557121776, 69.40185666852565)) atol=1e-6
    res = DataFrame(SASLMR.ciest(@formula(CMAX ~  PRD + TRT + SEQ + SUBJ&SEQ), bedf, "TRT", [-1, 1]; level = 0.9, est = true))
    @test  res[1, "Lower CL"] ≈ -49.46976557121776 atol=1e-6
    @test  res[1, "Upper CL"] ≈  69.40185666852565 atol=1e-6
end
