

module mtest2
using StaticArrays
using MeshCore: VecAttrib
import MeshSteward: vselect, initbox, updatebox!
using Test
function test()
    xyz = [0.0 0.0; 633.3333333333334 0.0; 1266.6666666666667 0.0; 1900.0 0.0; 0.0 400.0; 633.3333333333334 400.0; 1266.6666666666667 400.0; 1900.0 400.0; 0.0 800.0; 633.3333333333334 800.0; 1266.6666666666667 800.0; 1900.0 800.0]
    N, T = size(xyz, 2), eltype(xyz)
    locs =  VecAttrib([SVector{N, T}(xyz[i, :]) for i in 1:size(xyz, 1)])
    @test length(locs) == 12
    x = locs[SVector{2}([2, 4])]
    @test x[1] == SVector{2}([633.3333333333334 0.0])
    @test length(locs[1]) == 2
    @test eltype(locs[1]) == Float64

    box = [0.0 0.0 0.0 0.0]
    inflate = 0.01
    outputlist = vselect(locs; box = box, inflate = inflate)
    @test isapprox(outputlist, [1])

    box = initbox(xyz)
    outputlist = vselect(locs; box = box, inflate = inflate)
    @test isapprox(outputlist, collect(1:size(xyz, 1)))

    box = initbox(xyz[2, :])
    updatebox!(box, xyz[6, :])
    outputlist = vselect(locs; box = box, inflate = inflate)
    @test isapprox(outputlist, [2, 6])

    box = initbox(xyz[5, :])
    updatebox!(box, xyz[6, :])
    outputlist = vselect(locs; box = box, inflate = inflate)
    @test isapprox(outputlist, [5, 6])
    true
end
end
using .mtest2
mtest2.test()

include("samplet4.jl")

module mt4topo1
using StaticArrays
using MeshCore: P1, T4, ShapeColl,  manifdim, nvertices, nshapes, indextype
using MeshCore: skeleton, retrieve, VecAttrib
using MeshCore: IncRel, transpose, nrelations, nentities, boundary
using MeshSteward: connectedv
using ..samplet4: samplet4mesh
using Test
function test()
    xyz, cc = samplet4mesh()
    # Construct the initial incidence relation
    N, T = size(xyz, 2), eltype(xyz)
    locs =  VecAttrib([SVector{N, T}(xyz[i, :]) for i in 1:size(xyz, 1)])
    vrts = ShapeColl(P1, length(locs))
    tets = ShapeColl(T4, size(cc, 1))
    ir30 = IncRel(tets, vrts, cc)
    vl = connectedv(ir30)
    @test length(vl) == size(xyz, 1)
    ir20 = boundary(ir30)
    vl = connectedv(ir20)
    @test length(vl) == 54
    true
end
end
using .mt4topo1
mt4topo1.test()
