module osamplet4
using StaticArrays
function osamplet4mesh()
    xyz = [
    0.0 0.0 0.0
    1.0 0.0 0.0
    2.0 0.0 0.0
    3.0 0.0 0.0
    0.0 2.0 0.0
    1.0 2.0 0.0
    2.0 2.0 0.0
    3.0 2.0 0.0
    0.0 4.0 0.0
    1.0 4.0 0.0
    2.0 4.0 0.0
    3.0 4.0 0.0
    0.0 6.0 0.0
    1.0 6.0 0.0
    2.0 6.0 0.0
    3.0 6.0 0.0
    0.0 8.0 0.0
    1.0 8.0 0.0
    2.0 8.0 0.0
    3.0 8.0 0.0
    0.0 0.0 2.5
    1.0 0.0 2.5
    2.0 0.0 2.5
    3.0 0.0 2.5
    0.0 2.0 2.5
    1.0 2.0 2.5
    2.0 2.0 2.5
    3.0 2.0 2.5
    0.0 4.0 2.5
    1.0 4.0 2.5
    2.0 4.0 2.5
    3.0 4.0 2.5
    0.0 6.0 2.5
    1.0 6.0 2.5
    2.0 6.0 2.5
    3.0 6.0 2.5
    0.0 8.0 2.5
    1.0 8.0 2.5
    2.0 8.0 2.5
    3.0 8.0 2.5
    0.0 0.0 5.0
    1.0 0.0 5.0
    2.0 0.0 5.0
    3.0 0.0 5.0
    0.0 2.0 5.0
    1.0 2.0 5.0
    2.0 2.0 5.0
    3.0 2.0 5.0
    0.0 4.0 5.0
    1.0 4.0 5.0
    2.0 4.0 5.0
    3.0 4.0 5.0
    0.0 6.0 5.0
    1.0 6.0 5.0
    2.0 6.0 5.0
    3.0 6.0 5.0
    0.0 8.0 5.0
    1.0 8.0 5.0
    2.0 8.0 5.0
    3.0 8.0 5.0
    ]
    c = [1 25 21 22
    6 5 2 26
    26 2 22 25
    5 26 25 2
    2 1 22 25
    5 25 1 2
    21 45 41 42
    26 25 22 46
    46 22 42 45
    25 46 45 22
    22 21 42 45
    25 45 21 22
    5 29 25 26
    10 9 6 30
    30 6 26 29
    9 30 29 6
    6 5 26 29
    9 29 5 6
    25 49 45 46
    30 29 26 50
    50 26 46 49
    29 50 49 26
    26 25 46 49
    29 49 25 26
    9 33 29 30
    14 13 10 34
    34 10 30 33
    13 34 33 10
    10 9 30 33
    13 33 9 10
    29 53 49 50
    34 33 30 54
    54 30 50 53
    33 54 53 30
    30 29 50 53
    33 53 29 30
    13 37 33 34
    18 17 14 38
    38 14 34 37
    17 38 37 14
    14 13 34 37
    17 37 13 14
    33 57 53 54
    38 37 34 58
    58 34 54 57
    37 58 57 34
    34 33 54 57
    37 57 33 34
    2 26 22 23
    7 6 3 27
    27 3 23 26
    6 27 26 3
    3 2 23 26
    6 26 2 3
    22 46 42 43
    27 26 23 47
    47 23 43 46
    26 47 46 23
    23 22 43 46
    26 46 22 23
    6 30 26 27
    11 10 7 31
    31 7 27 30
    10 31 30 7
    7 6 27 30
    10 30 6 7
    26 50 46 47
    31 30 27 51
    51 27 47 50
    30 51 50 27
    27 26 47 50
    30 50 26 27
    10 34 30 31
    15 14 11 35
    35 11 31 34
    14 35 34 11
    11 10 31 34
    14 34 10 11
    30 54 50 51
    35 34 31 55
    55 31 51 54
    34 55 54 31
    31 30 51 54
    34 54 30 31
    14 38 34 35
    19 18 15 39
    39 15 35 38
    18 39 38 15
    15 14 35 38
    18 38 14 15
    34 58 54 55
    39 38 35 59
    59 35 55 58
    38 59 58 35
    35 34 55 58
    38 58 34 35
    3 27 23 24
    8 7 4 28
    28 4 24 27
    7 28 27 4
    4 3 24 27
    7 27 3 4
    23 47 43 44
    28 27 24 48
    48 24 44 47
    27 48 47 24
    24 23 44 47
    27 47 23 24
    7 31 27 28
    12 11 8 32
    32 8 28 31
    11 32 31 8
    8 7 28 31
    11 31 7 8
    27 51 47 48
    32 31 28 52
    52 28 48 51
    31 52 51 28
    28 27 48 51
    31 51 27 28
    11 35 31 32
    16 15 12 36
    36 12 32 35
    15 36 35 12
    12 11 32 35
    15 35 11 12
    31 55 51 52
    36 35 32 56
    56 32 52 55
    35 56 55 32
    32 31 52 55
    35 55 31 32
    15 39 35 36
    20 19 16 40
    40 16 36 39
    19 40 39 16
    16 15 36 39
    19 39 15 16
    35 59 55 56
    40 39 36 60
    60 36 56 59
    39 60 59 36
    36 35 56 59
    39 59 35 36
    ]
    return xyz, c
end
end

module mt4mesh1
using StaticArrays
using MeshCore: P1, T4, ShapeColl,  manifdim, nvertices, nridges, nshapes
using MeshCore: bbyridges, skeleton, bbyfacets, nshifts, _sense
using MeshCore: IncRel, transpose, nrelations, nentities
using MeshCore: VecAttrib, attribute, code
using MeshSteward: Mesh, insert!, increl, basecode 
using ..osamplet4: osamplet4mesh
using Test
function test()
    xyz, cc = osamplet4mesh()
    # Construct the initial incidence relation
    N, T = size(xyz, 2), eltype(xyz)
    locs =  VecAttrib([SVector{N, T}(xyz[i, :]) for i in 1:size(xyz, 1)])
    vrts = ShapeColl(P1, length(locs))
    vrts.attributes["geom"] = locs
    tets = ShapeColl(T4, size(cc, 1))
    ir30 = IncRel(tets, vrts, cc)

    mesh = Mesh()
    insert!(mesh, ir30)
    irc = basecode(mesh)
    @test irc == (3, 0)

    @test increl(mesh, (3, 0)) == ir30
    ir = increl(mesh, (3, 0))
    locs = attribute(ir.right, "geom")
    @test locs[nshapes(ir.right)] == [3.0, 8.0, 5.0]

    true
end
end
using .mt4mesh1
mt4mesh1.test()

module mmeshio2a
using StaticArrays
using MeshCore: nshapes
using MeshCore: attribute, nrelations, skeleton
using MeshSteward: import_NASTRAN, vtkwrite
using MeshSteward: Mesh, insert!, increl, basecode
using Test
function test()
    connectivities = import_NASTRAN("trunc_cyl_shell_0.nas")
    connectivity = connectivities[1]
    mesh = Mesh()
    insert!(mesh, connectivity)
    irc = basecode(mesh)
    connectivity = increl(mesh, irc)
    @test (nshapes(connectivity.right), nshapes(connectivity.left)) == (376, 996)
    vertices = connectivity.right
    geom = attribute(vertices, "geom")
    # @show typeof(geom)
    # @show typeof(geom.val)
    vtkwrite("trunc_cyl_shell_0", connectivity)
    try rm("trunc_cyl_shell_0" * ".vtu"); catch end

    connectivity0 = skeleton(skeleton(skeleton(connectivity)))
    @test (nshapes(connectivity0.right), nshapes(connectivity0.left)) == (376, 376)
    vtkwrite("trunc_cyl_shell_0-boundary-skeleton", connectivity0)
    try rm("trunc_cyl_shell_0-boundary-skeleton" * ".vtu"); catch end
    true
end
end
using .mmeshio2a
mmeshio2a.test()

module mmeshio3
using StaticArrays
using MeshCore: nshapes
using MeshCore: attribute, nrelations, skeleton
using MeshSteward: import_NASTRAN, vtkwrite, export_MESH
using MeshSteward: Mesh, insert!, increl, load, basecode, nspacedims
using Test
function test()
    connectivities = import_NASTRAN("trunc_cyl_shell_0.nas")
    connectivity = connectivities[1]
    mesh = Mesh()
    insert!(mesh, connectivity)
    connectivity = increl(mesh, (3, 0))
    @test (nshapes(connectivity.right), nshapes(connectivity.left)) == (376, 996)
    
    export_MESH("trunc_cyl_shell_0.mesh", connectivity)
    mesh2 = Mesh("new mesh")
    mesh2 = load(mesh2, "trunc_cyl_shell_0.mesh")
    connectivity = increl(mesh2, (3, 0))
    @test (nshapes(connectivity.right), nshapes(connectivity.left)) == (376, 996)
    irc = basecode(mesh)
    @test irc == (3, 0)
    @test nspacedims(mesh2) == 3
    try rm("trunc_cyl_shell_0" * ".mesh"); catch end
    try rm("trunc_cyl_shell_0-xyz" * ".dat"); catch end
    try rm("trunc_cyl_shell_0-conn" * ".dat"); catch end
    true
end
end
using .mmeshio3
mmeshio3.test()

module mmeshio4
using StaticArrays
using MeshCore: nshapes
using MeshCore: attribute, nrelations, skeleton
using MeshSteward: import_NASTRAN, vtkwrite, export_MESH
using MeshSteward: Mesh, insert!, increl, load, basecode, nspacedims, save
using Test
function test()
    connectivities = import_NASTRAN("trunc_cyl_shell_0.nas")
    connectivity = connectivities[1]
    mesh = Mesh()
    insert!(mesh, connectivity)
    save(mesh, "trunc_cyl_shell_0")
    mesh2 = Mesh()
    mesh2 = load(mesh2, "trunc_cyl_shell_0")
    @test nspacedims(mesh) == nspacedims(mesh2)
    try rm("trunc_cyl_shell_0" * ".mesh"); catch end
    try rm("trunc_cyl_shell_0-xyz" * ".dat"); catch end
    try rm("trunc_cyl_shell_0-conn" * ".dat"); catch end
    
    true
end
end
using .mmeshio4
mmeshio4.test()

module mmfind1
using MeshSteward: boundingbox
using MeshSteward: Mesh, insert!, increl, load, basecode, nspacedims, save, baseincrel
using MeshSteward: vselect
using MeshSteward: import_NASTRAN, vtkwrite
using MeshCore: nshapes
using Test
function test()
	connectivities = import_NASTRAN("trunc_cyl_shell_0.nas")
	mesh = Mesh()
	insert!(mesh, connectivities[1])
	# vtkwrite("trunc_cyl_shell_0-elements", baseincrel(mesh))
    selectedv = vselect(mesh, box = boundingbox([-Inf -Inf 0.5; Inf Inf 0.5]), inflate = 0.001)
	# vtkwrite("trunc_cyl_shell_0-selected-vertices", selectedv)
	@test nshapes(selectedv.left) == 44
end
end
using .mmfind1
mmfind1.test()

module mmbd1
using MeshSteward: import_NASTRAN, vtkwrite
using MeshSteward: Mesh, insert!, boundary
using MeshSteward: summary
using Test
function test()
	connectivities = import_NASTRAN("trunc_cyl_shell_0.nas")
	connectivity = connectivities[1]
	mesh = Mesh()
	insert!(mesh, connectivity)
	bir = boundary(mesh) 
    s = summary(mesh)
    vtkwrite("trunc_cyl_shell_0-boundary", bir)
	try rm("trunc_cyl_shell_0-boundary" * ".vtu"); catch end
end
end
using .mmbd1
mmbd1.test()


module mmvtx1
using MeshSteward: import_NASTRAN, vtkwrite
using MeshSteward: Mesh, insert!, vertices
using MeshSteward: summary
using MeshCore: nshapes
using Test
function test()
    connectivities = import_NASTRAN("trunc_cyl_shell_0.nas")
    connectivity = connectivities[1]
    mesh = Mesh()
    insert!(mesh, connectivity)
    vir = vertices(mesh) 
    @test nshapes(vir.right) == nshapes(vir.left) 
    @test nshapes(vir.right) == nshapes(connectivity.right) 
    # s = summary(mesh)
    # vtkwrite("trunc_cyl_shell_0-vertices", vir)
    # try rm("trunc_cyl_shell_0-vertices" * ".vtu"); catch end
end
end
using .mmvtx1
mmvtx1.test()


module mmvtx2
using MeshSteward: import_NASTRAN, vtkwrite
using MeshSteward: Mesh, insert!, vertices, submesh
using MeshSteward: summary, basecode, boundary, eselect, label, initbox, updatebox!, baseincrel
using MeshCore: nshapes, attribute, subset
using Test
function test()
    connectivities = import_NASTRAN("trunc_cyl_shell_0.nas")
    connectivity = connectivities[1]
    mesh = Mesh()
    insert!(mesh, connectivity)
    @test basecode(mesh) == (3, 0)
    vir = vertices(mesh) 
    @test nshapes(vir.right) == nshapes(vir.left) 
    @test nshapes(vir.right) == nshapes(connectivity.right) 
    geom = attribute(vir.right, "geom")
    box = initbox(geom[1])
    for i in 1:length(geom)
        updatebox!(box, geom[i])
    end
    box[1] = (box[1] + box[2]) / 2
    ir = baseincrel(mesh)
    el = eselect(ir; box = box, inflate = 0.0009)
    @test length(el)  == 498
    label(mesh, (3, 0), :left, el, 8)
    el = eselect(ir; label = 8)
    @test length(el)  == 498

    # @test length(el) == 44
    @test summary(mesh) == "Mesh mesh: ((3, 0), \"\") = (elements, vertices): elements = 996 x T4 {label,}, vertices = 376 x P1 {geom,}; "
    # vtkwrite("trunc_cyl_shell_0-full", ir)
    # vtkwrite("trunc_cyl_shell_0-subset", subset(ir, el))
    # try rm("trunc_cyl_shell_0-vertices" * ".vtu"); catch end
    return true
end
end
using .mmvtx2
mmvtx2.test()


module mmvtx3
using MeshSteward: import_NASTRAN, vtkwrite, geometry
using MeshSteward: Mesh, insert!, vertices, submesh, increl, baseincrel
using MeshSteward: summary, basecode, boundary, eselect, label, initbox, updatebox!, baseincrel
using MeshCore: nshapes, attribute, subset, code, nrelations
using Test
function test()
    connectivities = import_NASTRAN("trunc_cyl_shell_0.nas")
    connectivity = connectivities[1]
    mesh = Mesh()
    insert!(mesh, connectivity)
    @test basecode(mesh) == (3, 0)
    vir = vertices(mesh) 
    @test nshapes(vir.right) == nshapes(vir.left) 
    @test nshapes(vir.right) == nshapes(connectivity.right) 
    geom = geometry(mesh)
    box = initbox(geom[1])
    for i in 1:length(geom)
        updatebox!(box, geom[i])
    end
    box[1] = (box[1] + box[2]) / 2
    ir = baseincrel(mesh)
    el = eselect(ir; box = box, inflate = 0.0009)
    @test length(el)  == 498
    label(mesh, (3, 0), :left, el, 8)
    el = eselect(ir; label = 8)
    @test length(el)  == 498

    halfmesh = submesh(mesh, el)
    # @show  summary(halfmesh)
    @test nrelations(halfmesh) == 498

    bir = boundary(mesh)
    bir2 = increl(mesh, (code(bir), "boundary"))
    @test summary(bir) == summary(bir2)
    # @test length(el) == 44
    # @show  summary(mesh)
    # vtkwrite("trunc_cyl_shell_0-full", ir)
    # vtkwrite("trunc_cyl_shell_0-subset", subset(ir, el))
    try rm("trunc_cyl_shell_0-full" * ".vtu"); catch end
    try rm("trunc_cyl_shell_0-subset" * ".vtu"); catch end
    try rm("trunc_cyl_shell_0-vertices" * ".vtu"); catch end
    return true
end
end
using .mmvtx3
mmvtx3.test()