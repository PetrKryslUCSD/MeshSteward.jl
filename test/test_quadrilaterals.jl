
module mq4gen1
using StaticArrays
using MeshCore: nshapes
using MeshSteward: vtkwrite
using MeshSteward: Q4blockx
using Test
function test()
    connectivity = Q4blockx([0.0, 1.0, 3.0], [0.0, 1.0, 3.0])
    @test (nshapes(connectivity.right), nshapes(connectivity.left)) == (9, 4)
    vtkwrite("mq4gen1a", connectivity)
    try rm("mq4gen1a.vtu"); catch end
    true
end
end
using .mq4gen1
mq4gen1.test()

module mq4gen1b
using StaticArrays
using MeshCore: nshapes
using MeshSteward: vtkwrite
using MeshSteward: Q4blockx
using Test
function test()
    connectivity = Q4blockx([0.0, 1.0, 3.0], [0.0, 1.0, 3.0])
    @test (nshapes(connectivity.right), nshapes(connectivity.left)) == (9, 4)
    vtkwrite("mq4gen1b", connectivity)
    try rm("mq4gen1b.vtu"); catch end
    true
end
end
using .mq4gen1b
mq4gen1b.test()

module mq4gen2
using StaticArrays
using MeshCore: nshapes
using MeshSteward: vtkwrite
using MeshSteward: Q4block
using Test
function test()
    connectivity = Q4block(1.0, 2.0, 7, 9)
    # @show (nshapes(connectivity.right), nshapes(connectivity.left))
    @test (nshapes(connectivity.right), nshapes(connectivity.left)) == (80, 63)
    vtkwrite("mq4gen2", connectivity)
    try rm("mq4gen2.vtu"); catch end
    true
end
end
using .mq4gen2
mq4gen2.test()

module mq4gen3
using StaticArrays
using MeshCore: nshapes
using MeshSteward: vtkwrite
using MeshSteward: export_MESH
using MeshSteward: Q4blockx, gradedspace
using Test
function test()
    connectivity = Q4blockx([1.0, 2.0, 3.0], gradedspace(0.0, 5.0, 7, 2))
    # @show (nshapes(connectivity.right), nshapes(connectivity.left))
    @test (nshapes(connectivity.right), nshapes(connectivity.left)) == (21, 12)
    vtkwrite("mq4gen3", connectivity)
    try rm("mq4gen3.vtu"); catch end
    export_MESH("mq4gen3", connectivity)
    try rm("mq4gen3.mesh"); catch end
    try rm("mq4gen3-xyz.dat"); catch end
    try rm("mq4gen3-conn.dat"); catch end
    true
end
end
using .mq4gen3
mq4gen3.test()
