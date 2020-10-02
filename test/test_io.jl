
module mmeshio1
using StaticArrays
using MeshCore: nshapes
using MeshSteward: import_NASTRAN
using Test
function test()
    connectivities = import_NASTRAN(joinpath("data", "trunc_cyl_shell_0.nas"))
    @test length(connectivities) == 1
    connectivity = connectivities[1]
    @test (nshapes(connectivity.right), nshapes(connectivity.left)) == (376, 996)
    true
end
end
using .mmeshio1
mmeshio1.test()

module mmeshio2
using StaticArrays
using MeshCore: nshapes
using MeshCore: attribute, nrelations, ir_skeleton
using MeshSteward: import_NASTRAN, vtkwrite
using Test
function test()
    connectivities = import_NASTRAN(joinpath("data", "trunc_cyl_shell_0.nas"))
    @test length(connectivities) == 1
    connectivity = connectivities[1]
    @test (nshapes(connectivity.right), nshapes(connectivity.left)) == (376, 996)
    vertices = connectivity.right
    geom = attribute(vertices, "geom")
    vtkwrite("trunc_cyl_shell_0", connectivity)
    try rm("trunc_cyl_shell_0.vtu"); catch end

    ir00 = ir_skeleton(ir_skeleton(ir_skeleton(connectivity)))
    @test (nshapes(ir00.right), nshapes(ir00.left)) == (376, 376)
    vtkwrite("trunc_cyl_shell_0-0-skeleton", ir00)
    try rm("trunc_cyl_shell_0-0-skeleton" * ".vtu"); catch end
true
end
end
using .mmeshio2
mmeshio2.test()

module mmeshio5
using StaticArrays
using MeshCore: nshapes
using MeshCore: attribute, nrelations, ir_skeleton
using MeshSteward: import_NASTRAN, vtkwrite
using Test
function test()
    connectivities = import_NASTRAN(joinpath("data", "trunc_cyl_shell_0.nas"))
    @test length(connectivities) == 1
    connectivity = connectivities[1]
    @test (nshapes(connectivity.right), nshapes(connectivity.left)) == (376, 996)
    vertices = connectivity.right
    geom = attribute(vertices, "geom")
    vtkwrite("trunc_cyl_shell_0", connectivity)
    try rm("trunc_cyl_shell_0" * ".vtu"); catch end

    ir20 = ir_skeleton(connectivity)
    @test (nshapes(ir20.right), nshapes(ir20.left)) == (376, 2368)
    vtkwrite("trunc_cyl_shell_0-2-skeleton", ir20)
    try rm("trunc_cyl_shell_0-2-skeleton" * ".vtu"); catch end
    true
end
end
using .mmeshio5
mmeshio5.test()

module mmeshio6
using StaticArrays
using MeshCore: nshapes
using MeshCore: attribute, nrelations, ir_boundary
using MeshSteward: import_NASTRAN, vtkwrite
using Test
function test()
    connectivities = import_NASTRAN(joinpath("data", "trunc_cyl_shell_0.nas"))
    @test length(connectivities) == 1
    connectivity = connectivities[1]
    @test (nshapes(connectivity.right), nshapes(connectivity.left)) == (376, 996)
    vertices = connectivity.right
    geom = attribute(vertices, "geom")
    vtkwrite("trunc_cyl_shell_0", connectivity)
    try rm("trunc_cyl_shell_0" * ".vtu"); catch end

    ir20 = ir_boundary(connectivity)
    @test (nshapes(ir20.right), nshapes(ir20.left)) == (376, 752)
    vtkwrite("trunc_cyl_shell_0-boundary", ir20)
    try rm("trunc_cyl_shell_0-boundary" * ".vtu"); catch end
    true
end
end
using .mmeshio6
mmeshio6.test()

module mmeshio7
using StaticArrays
using MeshCore: nshapes
using MeshCore: attribute, nrelations, ir_boundary
using MeshSteward: import_NASTRAN, vtkwrite
using Test
function test()
    connectivities = import_NASTRAN(joinpath("data", "trunc_cyl_shell_0.nas"))
    @test length(connectivities) == 1
    connectivity = connectivities[1]
    @test (nshapes(connectivity.right), nshapes(connectivity.left)) == (376, 996)
    vertices = connectivity.right
    geom = attribute(vertices, "geom")
    vtkwrite("trunc_cyl_shell_0", connectivity)
    try rm("trunc_cyl_shell_0" * ".vtu"); catch end

    ir20 = ir_boundary(connectivity)
    @test (nshapes(ir20.right), nshapes(ir20.left)) == (376, 752)
    vtkwrite("trunc_cyl_shell_0-boundary", ir20)
    try rm("trunc_cyl_shell_0-boundary" * ".vtu"); catch end
    true
end
end
using .mmeshio7
mmeshio7.test()

module mmeshio8
using StaticArrays
using MeshCore: nshapes
using MeshCore: attribute, nrelations, ir_boundary
using MeshSteward: import_MESH, vtkwrite, export_MESH
using Test
function test()
    connectivities = import_MESH(joinpath("data", "q4-4-2.mesh"))
    @test length(connectivities) == 1
    connectivity = connectivities[1]
    @test (nshapes(connectivity.right), nshapes(connectivity.left)) == (15, 8)
    vertices = connectivity.right
    geom = attribute(vertices, "geom")
    vtkwrite("q4-4-2", connectivity)
    try rm("q4-4-2" * ".vtu"); catch end

    ir20 = ir_boundary(connectivity)
    @test (nshapes(ir20.right), nshapes(ir20.left)) == (15, 12)
    vtkwrite("q4-4-2-boundary", ir20)
    try rm("q4-4-2-boundary" * ".vtu"); catch end
    # @show connectivity
    @test export_MESH("q4-4-2-export.mesh", connectivity)
    try rm("q4-4-2-export" * ".mesh"); catch end
    try rm("q4-4-2-export-xyz" * ".dat"); catch end
    try rm("q4-4-2-export-conn" * ".dat"); catch end
    true
end
end
using .mmeshio8
mmeshio8.test()

module mmeshio9
using StaticArrays
using MeshCore: nshapes
using MeshCore: attribute, nrelations, ir_boundary
using MeshSteward: import_NASTRAN, vtkwrite, export_MESH, import_MESH
using LinearAlgebra
using Test
function test()
    connectivities = import_NASTRAN(joinpath("data", "trunc_cyl_shell_0.nas"))
    connectivity = connectivities[1]
    @test (nshapes(connectivity.right), nshapes(connectivity.left)) == (376, 996)
    vertices = connectivity.right
    geom = attribute(vertices, "geom")

    beforeexport = (nshapes(connectivity.right), nshapes(connectivity.left))
    @test export_MESH("test.mesh", connectivity)

    connectivities = import_MESH("test.mesh")
    connectivity = connectivities[1]
    connectivity = connectivities[1]
    @test (nshapes(connectivity.right), nshapes(connectivity.left)) == beforeexport
    vertices = connectivity.right
    geom2 = attribute(vertices, "geom")
    s =  sum([norm(geom2[i]-geom[i]) for i in length(geom)] )
    @test s <= 1.0e-9
    try rm("test" * ".mesh"); catch end
    try rm("test-*" * ".dat"); catch end

    true
end
end
using .mmeshio9
mmeshio9.test()


module mmeshio10
using StaticArrays
using MeshCore: nshapes
using MeshCore: attribute, nrelations, ir_boundary
using MeshSteward: import_ABAQUS, vtkwrite, export_MESH, import_MESH
using LinearAlgebra
using Test
function test()
    connectivities = import_ABAQUS(joinpath("data", "block-w-hole.inp"))
    @test length(connectivities) == 1
    connectivity = connectivities[1]
    @test connectivity.left.name == "Q4"
    @test (nshapes(connectivity.right), nshapes(connectivity.left)) == (481, 430)
    vertices = connectivity.right
    geom = attribute(vertices, "geom")

    beforeexport = (nshapes(connectivity.right), nshapes(connectivity.left))
    @test export_MESH("test.mesh", connectivity)

    connectivities = import_MESH("test.mesh")
    connectivity = connectivities[1]
    connectivity = connectivities[1]
    @test (nshapes(connectivity.right), nshapes(connectivity.left)) == beforeexport
    vertices = connectivity.right
    geom2 = attribute(vertices, "geom")
    s =  sum([norm(geom2[i]-geom[i]) for i in length(geom)] )
    @test s <= 1.0e-9
    try rm("test" * ".mesh"); catch end
    try rm("test" * "-xyz" * ".dat"); catch end
    try rm("test" * "-conn" * ".dat"); catch end
    true
end
end
using .mmeshio10
mmeshio10.test()


module mmeshio11
using StaticArrays
using MeshCore: nshapes
using MeshCore: attribute, nrelations, ir_boundary, VecAttrib
using MeshSteward: import_ABAQUS, vtkwrite, export_MESH, import_MESH
using LinearAlgebra
using Test
function test()
    connectivities = import_ABAQUS(joinpath("data", "block-w-hole.inp"))
    @test length(connectivities) == 1
    connectivity = connectivities[1]
    @test connectivity.left.name == "Q4"
    @test (nshapes(connectivity.right), nshapes(connectivity.left)) == (481, 430)
    vertices = connectivity.right
    geom = attribute(vertices, "geom")

    vertices.attributes["distance"] = VecAttrib([norm(geom[i]) for i in 1:length(geom)])
    vtkwrite("block-w-hole-distance", connectivity, [(name = "distance",)])
    try rm("block-w-hole-distance" * ".vtu"); catch end
    true
end
end
using .mmeshio11
mmeshio11.test()


module mmeshio12
using StaticArrays
using MeshCore: nshapes
using MeshCore: attribute, nrelations, ir_boundary, VecAttrib
using MeshSteward: import_ABAQUS, vtkwrite, export_MESH, import_MESH
using LinearAlgebra
using Test
function test()
    connectivities = import_ABAQUS(joinpath("data", "block-w-hole.inp"))
    @test length(connectivities) == 1
    connectivity = connectivities[1]
    @test connectivity.left.name == "Q4"
    @test (nshapes(connectivity.right), nshapes(connectivity.left)) == (481, 430)
    vertices = connectivity.right
    geom = attribute(vertices, "geom")

    vertices.attributes["dist"] = VecAttrib([norm(geom[i]) for i in 1:length(geom)])
    vertices.attributes["x"] = VecAttrib([geom[i][1] for i in 1:length(geom)])
    vtkwrite("block-w-hole-distance", connectivity, [(name = "dist",), (name = "x",)])
    try rm("block-w-hole-distance" * ".vtu"); catch end
    true
end
end
using .mmeshio12
mmeshio12.test()



module mmeshio13
using StaticArrays
using MeshCore: nshapes, nrelations
using MeshCore: attribute, nrelations, ir_boundary, VecAttrib
using MeshSteward: import_ABAQUS, vtkwrite, export_MESH, import_MESH
using LinearAlgebra
using Test
function test()
    connectivities = import_ABAQUS(joinpath("data", "block-w-hole.inp"))
    @test length(connectivities) == 1
    connectivity = connectivities[1]
    @test connectivity.left.name == "Q4"
    @test (nshapes(connectivity.right), nshapes(connectivity.left)) == (481, 430)
    vertices = connectivity.right
    geom = attribute(vertices, "geom")

    vertices.attributes["dist"] = VecAttrib([norm(geom[i]) for i in 1:length(geom)])
    vertices.attributes["x"] = VecAttrib([geom[i][1] for i in 1:length(geom)])
    
    connectivity.left.attributes["invdist"] = VecAttrib([1.0/norm(sum(geom[connectivity[i]])) for i in 1:nrelations(connectivity)])
    vtkwrite("block-w-hole-mixed", connectivity, [(name = "dist",), (name = "x",), (name = "invdist",)])
    try rm("block-w-hole-mixed" * ".vtu"); catch end
    true
end
end
using .mmeshio13
mmeshio13.test()


module mmeshio14
using StaticArrays
using MeshCore: nshapes, nrelations
using MeshCore: attribute, nrelations, ir_boundary, VecAttrib
using MeshSteward: import_ABAQUS, vtkwrite, export_MESH, import_MESH
using LinearAlgebra
using Test
function test()
    connectivities = import_ABAQUS(joinpath("data", "block-w-hole.inp"))
    @test length(connectivities) == 1
    connectivity = connectivities[1]
    @test connectivity.left.name == "Q4"
    @test (nshapes(connectivity.right), nshapes(connectivity.left)) == (481, 430)
    vertices = connectivity.right
    geom = attribute(vertices, "geom")

    vertices.attributes["dist"] = VecAttrib([norm(geom[i]) for i in 1:length(geom)])
    vertices.attributes["x"] = VecAttrib([geom[i][1] for i in 1:length(geom)])
    vertices.attributes["v"] = VecAttrib([[geom[i][2], -geom[i][1], 0.0] for i in 1:length(geom)])
    
    connectivity.left.attributes["invdist"] = VecAttrib([1.0/norm(sum(geom[connectivity[i]])) for i in 1:nrelations(connectivity)])
    vtkwrite("block-w-hole-mixed", connectivity, [(name = "dist",), (name = "x",), (name = "invdist",), (name = "v",)])
    try rm("block-w-hole-mixed" * ".vtu"); catch end
    true
end
end
using .mmeshio14
mmeshio14.test()


module mmeshio15
using StaticArrays
using MeshCore: nshapes, nrelations
using MeshCore: attribute, nrelations, ir_boundary, VecAttrib
using MeshSteward: import_ABAQUS, vtkwrite, export_MESH, import_MESH
using LinearAlgebra
using Test
function test()
    connectivities = import_ABAQUS(joinpath("data", "block-w-hole.inp"))
    @test length(connectivities) == 1
    connectivity = connectivities[1]
    @test connectivity.left.name == "Q4"
    @test (nshapes(connectivity.right), nshapes(connectivity.left)) == (481, 430)
    vertices = connectivity.right
    geom = attribute(vertices, "geom")

    vertices.attributes["dist"] = VecAttrib([norm(geom[i]) for i in 1:length(geom)])
    vertices.attributes["x"] = VecAttrib([geom[i][1] for i in 1:length(geom)])
    vertices.attributes["v"] = VecAttrib([[geom[i][2], -geom[i][1]] for i in 1:length(geom)])
    
    connectivity.left.attributes["invdist"] = VecAttrib([1.0/norm(sum(geom[connectivity[i]])) for i in 1:nrelations(connectivity)])
    vtkwrite("block-w-hole-mixed", connectivity, [(name = "dist",), (name = "x",), (name = "invdist",), (name = "v", allxyz = true)])
    try rm("block-w-hole-mixed" * ".vtu"); catch end
    true
end
end
using .mmeshio15
mmeshio15.test()
