
module mt4gen1
using StaticArrays
using MeshCore: nshapes
using MeshSteward: vtkwrite
using MeshSteward: T4blockx
using Test
function test()
    connectivity = T4blockx([0.0, 1.0, 3.0], [0.0, 1.0, 3.0], [0.0, 1.0, 3.0], :a)
    @test (nshapes(connectivity.right), nshapes(connectivity.left)) == (27, 48)
    vtkwrite("mt4gen1", connectivity)
    try rm("mt4gen1.vtu"); catch end
    true
end
end
using .mt4gen1
mt4gen1.test()

module mt4gen2
using StaticArrays
using MeshCore: nshapes
using MeshSteward: vtkwrite
using MeshSteward: T4block
using Test
function test()
    connectivity = T4block(1.0, 2.0, 3.0, 7, 9, 13, :a)
    # @show (nshapes(connectivity.right), nshapes(connectivity.left))
    @test (nshapes(connectivity.right), nshapes(connectivity.left)) == (1120, 4914)
    vtkwrite("mt4gen2", connectivity)
    try rm("mt4gen2.vtu"); catch end
    true
end
end
using .mt4gen2
mt4gen2.test()

module mt4gen3
using StaticArrays
using MeshCore: nshapes
using MeshSteward: vtkwrite
using MeshSteward: T4blockx, gradedspace
using Test
function test()
    connectivity = T4blockx([1.0, 2.0, 3.0], [1.0, 2.0, 3.0], gradedspace(0.0, 5.0, 7, 2), :a)
    # @show (nshapes(connectivity.right), nshapes(connectivity.left))
    @test (nshapes(connectivity.right), nshapes(connectivity.left)) == (63, 144)
    vtkwrite("mt4gen3", connectivity)
    try rm("mt4gen3.vtu"); catch end
    true
end
end
using .mt4gen3
mt4gen3.test()

module mt4gen4
using StaticArrays
using MeshCore: nshapes
using MeshSteward: vtkwrite
using MeshSteward: T4blockx, linearspace
using Test
function test()
    connectivity = T4blockx([1.0, 2.0, 3.0], [1.0, 2.0, 3.0], linearspace(0.0, 5.0, 7), :a)
    # @show (nshapes(connectivity.right), nshapes(connectivity.left))
    @test (nshapes(connectivity.right), nshapes(connectivity.left)) == (63, 144)
    vtkwrite("mt4gen4", connectivity)
    try rm("mt4gen4.vtu"); catch end
    true
end
end
using .mt4gen4
mt4gen4.test()
