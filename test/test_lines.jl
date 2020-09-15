
module ml2gen1
using StaticArrays
using MeshCore: nshapes
using MeshSteward: vtkwrite
using MeshSteward: L2blockx
using Test
function test()
    connectivity = L2blockx([0.0, 1.0, 3.0])
    @test (nshapes(connectivity.right), nshapes(connectivity.left)) == (3, 2)
    vtkwrite("ml2gen1a", connectivity)
    try rm("ml2gen1a.vtu"); catch end
    true
end
end
using .ml2gen1
ml2gen1.test()

module ml2gen1b
using StaticArrays
using MeshCore: nshapes
using MeshSteward: vtkwrite
using MeshSteward: L2blockx
using Test
function test()
    connectivity = L2blockx([0.0, 1.0, 3.0])
    @test (nshapes(connectivity.right), nshapes(connectivity.left)) == (3, 2)
    vtkwrite("ml2gen1b", connectivity)
    try rm("ml2gen1b.vtu"); catch end
    true
end
end
using .ml2gen1b
ml2gen1b.test()

module ml2gen2
using StaticArrays
using MeshCore: nshapes
using MeshSteward: vtkwrite
using MeshSteward: L2block
using Test
function test()
    connectivity = L2block(1.0, 7)
    # @show (nshapes(connectivity.right), nshapes(connectivity.left))
    @test (nshapes(connectivity.right), nshapes(connectivity.left)) == (8, 7)
    vtkwrite("ml2gen2", connectivity)
    try rm("ml2gen2.vtu"); catch end
    true
end
end
using .ml2gen2
ml2gen2.test()

module ml2gen3
using StaticArrays
using MeshCore: nshapes
using MeshSteward: vtkwrite
using MeshSteward: export_MESH
using MeshSteward: L2blockx, gradedspace
using Test
function test()
    connectivity = L2blockx(gradedspace(0.0, 5.0, 7, 2))
    @show (nshapes(connectivity.right), nshapes(connectivity.left))
    @test (nshapes(connectivity.right), nshapes(connectivity.left)) == (7, 6)
    vtkwrite("ml2gen3", connectivity)
    try rm("ml2gen3.vtu"); catch end
    export_MESH("ml2gen3", connectivity)
    try rm("ml2gen3.mesh"); catch end
    try rm("ml2gen3-xyz.dat"); catch end
    try rm("ml2gen3-conn.dat"); catch end
    true
end
end
using .ml2gen3
ml2gen3.test()
