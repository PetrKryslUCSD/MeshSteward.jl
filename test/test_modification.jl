
module mmodt6gen4
using StaticArrays
using MeshCore: nshapes
using MeshSteward: vtkwrite
using MeshSteward: T3block, T6block, T3toT6, T6toT3
using MeshSteward: vconnected, vnewnumbering, compactify
using Test
function test()
    connectivity = T6block(2.0, 0.75*pi, 6, 5, :b)
    locs = connectivity.right.attributes["geom"]
    for i in 1:length(locs)
        r, a = locs[i][1]+2.7, locs[i][2]
        locs[i] = (cos(a)*r, sin(a)*r)
    end
    @test nshapes(connectivity.left) == 60
    connectivity3 = T6toT3(connectivity)
    @test nshapes(connectivity3.left) == nshapes(connectivity.left)
    @test nshapes(connectivity3.right) == 42

    vtkwrite("mmodt6gen4", connectivity3)
    try rm("mmodt6gen4.vtu"); catch end
    true
end
end
using .mmodt6gen4
mmodt6gen4.test()

module mmodt6gen5
using StaticArrays
using MeshCore: nshapes
using MeshSteward: vtkwrite, summary
using MeshSteward: Q4block, transform, fusevertices, cat, renumbered, withvertices
using MeshSteward: vconnected, vnewnumbering, compactify
using Test
function test()
    conn1 = Q4block(2.0, 0.75*pi, 13, 12)
    conn2 = Q4block(3.0, 0.75*pi, 7, 12)
    transform(conn2, x -> [x[1]+2, x[2]])
    # vtkwrite("mmodt6gen5-1", conn1)
    # vtkwrite("mmodt6gen5-2", conn2)
    locs1 = conn1.right.attributes["geom"]
    locs2 = conn2.right.attributes["geom"]
    tolerance = 1.0e-3
    nlocs1, ni1 = fusevertices(locs1, locs2, tolerance)
    conn1 = withvertices(conn1, nlocs1)
    conn2 = withvertices(conn2, nlocs1)
    conn1 = renumbered(conn1, ni1)
    @test summary(conn1) == "(elements, vertices): elements = 156 x Q4, vertices = 273 x P1 {geom,}"
    @test summary(conn2) == "(elements, vertices): elements = 84 x Q4, vertices = 273 x P1 {geom,}" 
    # vtkwrite("mmodt6gen5-1", conn1)
    # vtkwrite("mmodt6gen5-2", conn2)
    
    connectivity = cat(conn1, conn2)
    locs = connectivity.right.attributes["geom"]
    for i in 1:length(locs)
        r, a = locs[i][1]+2.7, locs[i][2]
        locs[i] = (cos(a)*r, sin(a)*r)
    end

    # vtkwrite("mmodt6gen5", connectivity)
    # try rm("mmodt6gen5.vtu"); catch end
    true
end
end
using .mmodt6gen5
mmodt6gen5.test()

module mmodt6gen6
using StaticArrays
using MeshCore: nshapes
using MeshSteward: vtkwrite, summary
using MeshSteward: Q4block, transform, fusevertices, cat, renumbered, withvertices
using MeshSteward: vconnected, vnewnumbering, compactify
using Test
function test()
    conn1 = Q4block(2.0, 0.75*pi, 13, 12)
    conn2 = Q4block(3.0, 0.75*pi, 7, 12)
    transform(conn2, x -> [x[1]+2, x[2]])
    # vtkwrite("mmodt6gen6-1", conn1)
    # vtkwrite("mmodt6gen6-2", conn2)
    locs1 = conn1.right.attributes["geom"]
    locs2 = conn2.right.attributes["geom"]
    tolerance = 1.0e-3
    nlocs1, ni1 = fusevertices(locs1, locs2, tolerance)
    conn1 = withvertices(conn1, nlocs1)
    conn2 = withvertices(conn2, nlocs1)
    conn1 = renumbered(conn1, ni1)
    @test summary(conn1) == "(elements, vertices): elements = 156 x Q4, vertices = 273 x P1 {geom,}"
    @test summary(conn2) == "(elements, vertices): elements = 84 x Q4, vertices = 273 x P1 {geom,}" 
    # vtkwrite("mmodt6gen6-1", conn1)
    # vtkwrite("mmodt6gen6-2", conn2)
    
    connectivity = cat(conn1, conn2)
    transform(connectivity, x -> begin
        r, a = x[1]+2.7, x[2]
        [cos(a)*r, sin(a)*r]
    end)
    # locs = connectivity.right.attributes["geom"]
    # for i in 1:length(locs)
    #     r, a = locs[i][1]+2.7, locs[i][2]
    #     locs[i] = (cos(a)*r, sin(a)*r)
    # end

    vtkwrite("mmodt6gen6", connectivity)
    try rm("mmodt6gen6.vtu"); catch end
    true
end
end
using .mmodt6gen6
mmodt6gen6.test()

module mmodt6gen7
using StaticArrays
using MeshCore: nshapes
using MeshSteward: vtkwrite, summary
using MeshSteward: Q4block, transform, fusevertices, cat, renumbered, withvertices
using MeshSteward: vconnected, vnewnumbering, compactify, mergeirs
using Test
function test()
    conn1 = Q4block(2.0, 0.75*pi, 13, 12)
    conn2 = Q4block(3.0, 0.75*pi, 7, 12)
    transform(conn2, x -> [x[1]+2, x[2]])
    connectivity  = mergeirs(conn1, conn2, 0.001)
    
    transform(connectivity, x -> begin
        r, a = x[1]+2.7, x[2]
        [cos(a)*r, sin(a)*r]
    end)

    vtkwrite("mmodt6gen7", connectivity)
    try rm("mmodt6gen7.vtu"); catch end
    true
end
end
using .mmodt6gen7
mmodt6gen7.test()

module mt4symrcm1a
using StaticArrays
using MeshCore.Exports
using MeshSteward.Exports 
using Test
function test()
    # connectivity = T4block(1.0, 2.0, 3.0, 1, 1, 1, :a)
    connectivity = T4block(1.0, 2.0, 3.0, 7, 9, 13, :a)
    # @show (nshapes(connectivity.right), nshapes(connectivity.left))
    # @test (nshapes(connectivity.right), nshapes(connectivity.left)) == (1120, 4914)
    
    connectivity = minimize_profile(connectivity)
    
    vtkwrite("mt4symrcm1a", connectivity)
    try rm("mt4symrcm1a.vtu"); catch end
    true
end
end
using .mt4symrcm1a
mt4symrcm1a.test()
