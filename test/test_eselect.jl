include("samplet3.jl")

module mt4topo1e1
using StaticArrays
using MeshCore: P1, T3, ShapeColl,  manifdim, nvertices, nshapes, indextype
using MeshCore: ir_skeleton, VecAttrib, nrelations
using MeshCore: IncRel, ir_transpose, nrelations, nentities, ir_boundary
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
    bir = ir_boundary(ir)
    bir.right.attributes["geom"] = locs
    el = eselect(bir; box = [0.0, 1.0, 1.0, 1.0], inflate = 0.01)
    for i in el
        vl = bir[i]
        for j in vl
            @test isapprox(locs[j][2], 1.0)
        end
    end
    el = eselect(bir; box = [0.0, 0.0, 0.0, 1.0], inflate = 0.01)
    for i in el
        vl = bir[i]
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
using MeshCore: ir_skeleton,  VecAttrib, nrelations
using MeshCore: IncRel, transpose, nrelations, nentities, ir_boundary
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
    bir = ir_boundary(ir)
    bir.right.attributes["geom"] = locs
    bir.left.attributes["label"] = VecAttrib([1 for i in 1:nshapes(bir.left)])

    el = eselect(bir; box = [0.0, 1.0, 1.0, 1.0], inflate = 0.01)
    for i in el
        vl = bir[i]
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
        vl = bir[i]
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

module mmeses1
using StaticArrays
using MeshCore: nshapes
using MeshCore: attribute, nrelations, ir_skeleton, ir_boundary, ir_subset
using MeshSteward: import_NASTRAN, vtkwrite, eselect
using Test
function test()
    connectivities = import_NASTRAN(joinpath("data", "trunc_cyl_shell_0.nas"))
    @test length(connectivities) == 1
    connectivity = connectivities[1]
    @test (nshapes(connectivity.right), nshapes(connectivity.left)) == (376, 996)
    vertices = connectivity.right
    geom = attribute(vertices, "geom")
    vtkwrite("trunc_cyl_shell_0-search", connectivity)
    try rm("trunc_cyl_shell_0-search.vtu"); catch end
    
    bir = ir_boundary(connectivity)
    el = eselect(bir; facing = true, direction = x -> [0.0, 0.0, 1.0], dotmin = 0.99)
    @test length(el) == 44
    vtkwrite("trunc_cyl_shell_0-search-z=top", ir_subset(bir, el))
    try rm("trunc_cyl_shell_0-search-z=top.vtu"); catch end
    el = eselect(bir; facing = true, direction = x -> [-x[1], -x[2], 0.0], dotmin = 0.99)
    @test length(el) == 304
    vtkwrite("trunc_cyl_shell_0-search-interior", ir_subset(bir, el))
    try rm("trunc_cyl_shell_0-search-interior.vtu"); catch end
    true
end
end
using .mmeses1
mmeses1.test()


module mmeses2
using StaticArrays
using MeshCore: P1, T3, ShapeColl,  manifdim, nvertices, nshapes, indextype, IncRel
using MeshCore: attribute, nrelations, ir_skeleton, ir_boundary, ir_subset, VecAttrib
using MeshSteward: import_NASTRAN, vtkwrite, eselect, connectedv
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
    bir = ir_boundary(ir)
    bir.right.attributes["geom"] = locs
    
    el = eselect(bir; facing = true, direction = x -> [-1.0, 0.0], dotmin = 0.99)
    @test length(el) == 3
    vtkwrite("samplet3mesh-search", ir)
    vtkwrite("samplet3mesh-search-x=0_0", ir_subset(bir, el))
    try rm("samplet3mesh-search" * ".vtu"); catch end
    try rm("samplet3mesh-search-x=0_0" * ".vtu"); catch end
    true
end
end
using .mmeses2
mmeses2.test()

