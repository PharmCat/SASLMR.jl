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
end


