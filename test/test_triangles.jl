
module mt3gen1
using StaticArrays
using MeshCore: nshapes
using MeshSteward: vtkwrite
using MeshSteward: T3blockx
using Test
function test()
    connectivity = T3blockx([0.0, 1.0, 3.0], [0.0, 1.0, 3.0], :a)
    @test (nshapes(connectivity.right), nshapes(connectivity.left)) == (9, 8)
    vtkwrite("mt3gen1a", connectivity)
    try rm("mt3gen1a.vtu"); catch end
    true
end
end
using .mt3gen1
mt3gen1.test()

module mt3gen1b
using StaticArrays
using MeshCore: nshapes
using MeshSteward: vtkwrite
using MeshSteward: T3blockx
using Test
function test()
    connectivity = T3blockx([0.0, 1.0, 3.0], [0.0, 1.0, 3.0], :b)
    @test (nshapes(connectivity.right), nshapes(connectivity.left)) == (9, 8)
    vtkwrite("mt3gen1b", connectivity)
    try rm("mt3gen1b.vtu"); catch end
    true
end
end
using .mt3gen1b
mt3gen1b.test()

module mt3gen2
using StaticArrays
using MeshCore: nshapes
using MeshSteward: vtkwrite
using MeshSteward: T3block
using Test
function test()
    connectivity = T3block(1.0, 2.0, 7, 9, :a)
    # @show (nshapes(connectivity.right), nshapes(connectivity.left))
    @test (nshapes(connectivity.right), nshapes(connectivity.left)) == (80, 63*2)
    vtkwrite("mt3gen2", connectivity)
    try rm("mt3gen2.vtu"); catch end
    true
end
end
using .mt3gen2
mt3gen2.test()

module mt3gen3
using StaticArrays
using MeshCore: nshapes
using MeshSteward: vtkwrite
using MeshSteward: export_MESH
using MeshSteward: T3blockx, gradedspace
using Test
function test()
    connectivity = T3blockx([1.0, 2.0, 3.0], gradedspace(0.0, 5.0, 7, 2), :a)
    # @show (nshapes(connectivity.right), nshapes(connectivity.left))
    @test (nshapes(connectivity.right), nshapes(connectivity.left)) == (21, 24)
    vtkwrite("mt3gen3", connectivity)
    try rm("mt3gen3.vtu"); catch end
    export_MESH("mt3gen3", connectivity)
    try rm("mt3gen3.mesh"); catch end
    try rm("mt3gen3-xyz.dat"); catch end
    try rm("mt3gen3-conn.dat"); catch end
    true
end
end
using .mt3gen3
mt3gen3.test()


module mt3gen5
using StaticArrays
using MeshCore: nshapes
using MeshSteward: vtkwrite
using MeshSteward: T3blockx
using Test
function test()
    connectivity = T3blockx([0.0, 1.0, 3.0], [0.0, 1.0, 3.0], :a)
    @test (nshapes(connectivity.right), nshapes(connectivity.left)) == (9, 8)
    vtkwrite("mt3gen5a", connectivity)
    try rm("mt3gen5a.vtu"); catch end
    true
end
end
using .mt3gen5
mt3gen5.test()

module mt6gen1
using StaticArrays
using MeshCore: nshapes
using MeshSteward: vtkwrite
using MeshSteward: T6blockx
using Test
function test()
    connectivity = T6blockx([0.0, 1.0, 3.0], [0.0, 1.0, 3.0], :b)
    @test (nshapes(connectivity.right), nshapes(connectivity.left)) == (9, 8)
    vtkwrite("mt6gen1", connectivity)
    try rm("mt6gen1.vtu"); catch end
    true
end
end
using .mt6gen1
mt6gen1.test()
