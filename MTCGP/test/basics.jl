using Test
using MTCGP
import YAML

@testset "MTCGPInd construction" begin
    cfg = get_config("../cfg/test.yaml")
    ind = MTCGPInd(cfg)

    @test length(ind.nodes) == 3 * 10 + 4
    for node in ind.nodes
        if node.active
            @test node.x >= 1
            @test node.x <= length(ind.nodes)
            @test node.y >= 1
            @test node.y <= length(ind.nodes)
        end
    end
end

@testset "Processing" begin
    cfg = YAML.load_file("../cfg/test.yaml")
    cfg["functions"] = ["f_abs", "f_add", "f_mult"]
    cfg = get_config(cfg)
    ind = MTCGPInd(cfg)

    inputs = zeros(4)
    set_inputs(ind, inputs)
    for i in 1:4
        @test ind.buffer[i] == 0.0
    end
    output = process(ind)
    @test output[1] == 0.0
    for i in eachindex(ind.nodes)
        if ind.nodes[i].active
            @test ind.buffer[i] == 0.0
        end
    end

    output = process(ind, ones(4))
    @test output[1] == 1.0
    for i in eachindex(ind.nodes)
        if ind.nodes[i].active
            @test ind.buffer[i] == 1.0
        end
    end

    output = process(ind, Array{MType}([ones(3) for i in 1:4]))
    @test all(output[1] .== ones(3))
    for i in eachindex(ind.nodes)
        if ind.nodes[i].active
            @test all(ind.buffer[i] == ones(3))
        end
    end
end
