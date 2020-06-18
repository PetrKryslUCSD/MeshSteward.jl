using Test

@time @testset "Search elements" begin include("test_eselect.jl") end
@time @testset "Boxes" begin include("test_boxes.jl") end
@time @testset "Search vertices" begin include("test_vselect.jl") end

@time @testset "Mesh import/export" begin include("test_io.jl") end

@time @testset "Quadrilaterals" begin include("test_quadrilaterals.jl") end
@time @testset "Triangles" begin include("test_triangles.jl") end
@time @testset "Tetrahedra" begin include("test_tetrahedra.jl") end

@time @testset "Modification" begin include("test_modification.jl") end

@time @testset "High-level" begin include("test_mesh.jl") end
