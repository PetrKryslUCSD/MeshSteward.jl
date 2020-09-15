module MeshSteward

include("boxes.jl")
include("vselect.jl")
include("eselect.jl")
include("utilities.jl")
include("tetrahedra.jl")
include("triangles.jl")
include("quadrilaterals.jl")
include("lines.jl")
include("io.jl")
include("modification.jl")
include("mesh.jl")

# We can either use/import individual functions from MeshSteward like so:
# ```
# using MeshSteward: attach!
# ```
# or we can bring into our context all exported symbols as
# ```
# using MeshSteward.Exports
# ```
include("Exports.jl")

end # module
