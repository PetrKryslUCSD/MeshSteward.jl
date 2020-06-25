
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

module mq4gen4
using StaticArrays
using MeshCore: nshapes
using MeshSteward: vtkwrite
using MeshSteward: export_MESH
using MeshSteward: Q4quadrilateral
using Test
function test()
    connectivity = Q4quadrilateral([1.0 0.0; 1.5 1.7; -0.5 0.9; -0.1 -0.1], 3, 4)
    # @show (nshapes(connectivity.right), nshapes(connectivity.left))
    @test (nshapes(connectivity.right), nshapes(connectivity.left)) == (20, 12)
    vtkwrite("mq4gen4", connectivity)
    try rm("mq4gen4.vtu"); catch end
    export_MESH("mq4gen4", connectivity)
    try rm("mq4gen4.mesh"); catch end
    try rm("mq4gen4-xyz.dat"); catch end
    try rm("mq4gen4-conn.dat"); catch end
    true
end
end
using .mq4gen4
mq4gen4.test()


module mq4gen5
using StaticArrays
using MeshCore: nshapes
using MeshSteward: vtkwrite
using MeshSteward: export_MESH
using MeshSteward: Q4quadrilateral
using Test
function test()
    connectivity = Q4quadrilateral([1.0 0.0; 1.5 1.7], 6, 4)
    # @show (nshapes(connectivity.right), nshapes(connectivity.left))
    @test (nshapes(connectivity.right), nshapes(connectivity.left)) == (35, 24)
    vtkwrite("mq4gen5", connectivity)
    try rm("mq4gen5.vtu"); catch end
    export_MESH("mq4gen5", connectivity)
    try rm("mq4gen5.mesh"); catch end
    try rm("mq4gen5-xyz.dat"); catch end
    try rm("mq4gen5-conn.dat"); catch end
    true
end
end
using .mq4gen5
mq4gen5.test()

module mq4gen6
using StaticArrays
using MeshCore: nshapes
using MeshSteward: vtkwrite
using MeshSteward: export_MESH
using MeshSteward: Q4quadrilateral
using Test
function test()
    connectivity = Q4quadrilateral([1.0 0.0 0.0; 1.5 1.7 -0.1; 2.1 1.7 0.5; -1.0 1.0 0.3], 6, 4)
    # @show (nshapes(connectivity.right), nshapes(connectivity.left))
    @test (nshapes(connectivity.right), nshapes(connectivity.left)) == (35, 24)
    vtkwrite("mq4gen6", connectivity)
    try rm("mq4gen6.vtu"); catch end
    export_MESH("mq4gen6", connectivity)
    try rm("mq4gen6.mesh"); catch end
    try rm("mq4gen6-xyz.dat"); catch end
    try rm("mq4gen6-conn.dat"); catch end
    true
end
end
using .mq4gen6
mq4gen6.test()

module mq4gen7
using StaticArrays
using MeshCore: nshapes
using MeshSteward: vtkwrite
using MeshSteward: export_MESH
using MeshSteward: Q4quadrilateral, mergeirs
using Test
function test()
    N = 2
    c1 = Q4quadrilateral([-1 -1; -0.2 -1; -0.1 -0.2; -1 0.8], N, N)
    c2 = Q4quadrilateral([-0.2 -1; 1 -1; 1 -0.5; -0.1 -0.2], N, N)
    c3 = Q4quadrilateral([1 -0.5; 1 1; 0.3 1; -0.1 -0.2], N, N)
    c4 = Q4quadrilateral([0.3 1; -1 1; -1 0.8; -0.1 -0.2], N, N)
    c  = mergeirs(c1, c2, 0.001)
    c  = mergeirs(c, c3, 0.001)
    c  = mergeirs(c, c4, 0.001)
    @test nshapes(c.left) == 4 * N ^ 2
    
    vtkwrite("mq4gen7", c)
    # try rm("mq4gen7.vtu"); catch end
    # export_MESH("mq4gen7", connectivity)
    # try rm("mq4gen7.mesh"); catch end
    # try rm("mq4gen7-xyz.dat"); catch end
    # try rm("mq4gen7-conn.dat"); catch end
    true
end
end
using .mq4gen7
mq4gen7.test()

module mq4gen8
using StaticArrays
using MeshCore: nshapes
using MeshSteward: vtkwrite
using MeshSteward: export_MESH
using MeshSteward: Q4blockwdistortion
using Test
function test()
    c1 = Q4blockwdistortion(3.0, 1.0, 15, 6)
    
    vtkwrite("mq4gen8", c1)
    # try rm("mq4gen8.vtu"); catch end
    # export_MESH("mq4gen8", connectivity)
    # try rm("mq4gen8.mesh"); catch end
    # try rm("mq4gen8-xyz.dat"); catch end
    # try rm("mq4gen8-conn.dat"); catch end
    true
end
end
using .mq4gen8
mq4gen8.test()


