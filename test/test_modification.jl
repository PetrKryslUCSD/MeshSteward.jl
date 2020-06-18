
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
