include("samplet3.jl")

module mt4topo1e1
using StaticArrays
using MeshCore: P1, T3, ShapeColl,  manifdim, nvertices, nshapes, indextype
using MeshCore: skeleton, retrieve, VecAttrib, nrelations
using MeshCore: IncRel, transpose, nrelations, nentities, boundary
using MeshSteward: connectedv, eselect
using ..samplet3: samplet3mesh
using Test
function test()
    xyz, cc = samplet3mesh()
    # Construct the initial incidence relation
    N, T = size(xyz, 2), eltype(xyz)
    locs =  VecAttrib([SVector{N, T}(xyz[i, :]) for i in 1:size(xyz, 1)])
    vrts = ShapeColl(P1, length(locs))
    tris = ShapeColl(T3, size(cc, 1))
    ir = IncRel(tris, vrts, cc)
    vl = connectedv(ir)
    @test length(vl) == size(xyz, 1)
    bir = boundary(ir)
    bir.right.attributes["geom"] = locs
    el = eselect(bir; box = [0.0, 1.0, 1.0, 1.0], inflate = 0.01)
    for i in el
        vl = retrieve(bir, i)
        for j in vl
            @test isapprox(locs[j][2], 1.0)
        end
    end
    el = eselect(bir; box = [0.0, 0.0, 0.0, 1.0], inflate = 0.01)
    for i in el
        vl = retrieve(bir, i)
        for j in vl
            @test isapprox(locs[j][1], 0.0)
        end
    end
    true
end
end
using .mt4topo1e1
mt4topo1e1.test()

module mt4topo1e2
using StaticArrays
using MeshCore: P1, T3, ShapeColl,  manifdim, nvertices, nshapes, indextype
using MeshCore: skeleton, retrieve, VecAttrib, nrelations
using MeshCore: IncRel, transpose, nrelations, nentities, boundary
using MeshSteward: connectedv, eselect
using ..samplet3: samplet3mesh
using Test
function test()
    xyz, cc = samplet3mesh()
    # Construct the initial incidence relation
    N, T = size(xyz, 2), eltype(xyz)
    locs =  VecAttrib([SVector{N, T}(xyz[i, :]) for i in 1:size(xyz, 1)])
    vrts = ShapeColl(P1, length(locs))
    tris = ShapeColl(T3, size(cc, 1))
    ir = IncRel(tris, vrts, cc)
    vl = connectedv(ir)
    @test length(vl) == size(xyz, 1)
    bir = boundary(ir)
    bir.right.attributes["geom"] = locs
    bir.left.attributes["label"] = VecAttrib([1 for i in 1:nshapes(bir.left)])

    el = eselect(bir; box = [0.0, 1.0, 1.0, 1.0], inflate = 0.01)
    for i in el
        vl = retrieve(bir, i)
        for j in vl
            @test isapprox(locs[j][2], 1.0)
        end
    end
    for i in 1:length(el)
        bir.left.attributes["label"][el[i]]  = 2
    end
    el2 = eselect(bir; label = 2)
    @test isapprox(el, el2)

    el = eselect(bir; box = [0.0, 0.0, 0.0, 1.0], inflate = 0.01)
    for i in el
        vl = retrieve(bir, i)
        for j in vl
            @test isapprox(locs[j][1], 0.0)
        end
    end
    for i in 1:length(el)
        bir.left.attributes["label"][el[i]]  = 3
    end
    el2 = eselect(bir; label = 3)
    @test isapprox(el, el2)
    
    true
end
end
using .mt4topo1e2
mt4topo1e2.test()

# module mt4topo1e1
# using StaticArrays
# using MeshCore: P1, T4, ShapeColl,  manifdim, nvertices, nshapes, indextype
# using MeshCore: skeleton, retrieve, VecAttrib, nrelations
# using MeshCore: IncRel, transpose, nrelations, nentities, boundary
# using MeshFinder: connectedv, eselect
# using ..samplet4: samplet4mesh
# using Test
# function test()
#     xyz, cc = samplet4mesh()
#     # Construct the initial incidence relation
#     N, T = size(xyz, 2), eltype(xyz)
#     locs =  VecAttrib([SVector{N, T}(xyz[i, :]) for i in 1:size(xyz, 1)])
#     vrts = ShapeColl(P1, length(locs))
#     tets = ShapeColl(T4, size(cc, 1))
#     ir = IncRel(tets, vrts, cc)
#     vl = connectedv(ir)
#     @test length(vl) == size(xyz, 1)
#     bir = boundary(ir)
#     bir.right.attributes["geom"] = locs
#     # el = eselect(bir; box = [0.0, 1.0, 1.0, 1.0], inflate = 0.01)
#     # for i in el
#     #     vl = retrieve(bir, i)
#     #     for j in vl
#     #         @test isapprox(locs[j][2], 1.0)
#     #     end
#     # end
#     # el = eselect(bir; box = [0.0, 0.0, 0.0, 1.0], inflate = 0.01)
#     # for i in el
#     #     vl = retrieve(bir, i)
#     #     for j in vl
#     #         @test isapprox(locs[j][1], 0.0)
#     #     end
#     # end
    
#     true
# end
# end
# using .mt4topo1e1
# mt4topo1e1.test()

