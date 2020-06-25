
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
    # try rm("mmodt6gen4.vtu"); catch end
    true
end
end
using .mmodt6gen4
mmodt6gen4.test()

module mmodt6gen5
using StaticArrays
using MeshCore: nshapes
using MeshSteward: vtkwrite, summary
using MeshSteward: Q4block, transform, fusevertices, cat, renumberconn!
using MeshSteward: vconnected, vnewnumbering, compactify
using Test
function test()
    conn1 = Q4block(2.0, 0.75*pi, 6, 5)
    conn2 = Q4block(3.0, 0.75*pi, 9, 5)
    transform(conn2, x -> [x[1]+2, x[2]])
    # vtkwrite("mmodt6gen5-1", conn1)
    # vtkwrite("mmodt6gen5-2", conn2)
    locs1 = conn1.right.attributes["geom"]
    locs2 = conn2.right.attributes["geom"]
    tolerance = 1.0e-3
    nlocs1, new_indexes_of_set1_nodes = fusevertices(locs1, locs2, tolerance)
    conn1.right.attributes["geom"] = nlocs1
    renumberconn!(conn1, new_indexes_of_set1_nodes)
    conn2.right.attributes["geom"] = nlocs1
    connectivity = cat(conn1, conn2)
    @show summary(conn1)
    @show summary(conn2)
    @show summary(connectivity)
    locs = connectivity.right.attributes["geom"]
    for i in 1:length(locs)
        r, a = locs[i][1]+2.7, locs[i][2]
        locs[i] = (cos(a)*r, sin(a)*r)
    end

    vtkwrite("mmodt6gen5", connectivity)
    # try rm("mmodt6gen5.vtu"); catch end
    true
end
end
using .mmodt6gen5
mmodt6gen5.test()
