using MeshCore
using MeshCore: ShapeColl, IncRel, skeleton
using MeshCore: shapedesc, nshapes, code, attribute
import Base.show
using StaticArrays

"""
    Mesh

The type of the mesh. 

It stores the incidence relations keyed by the code of the relation: `(d1,
d2)`, where `d1` is the manifold dimension of the shape collection on the left,
and `d2` is the manifold dimension of the shape collection on the right.
"""
struct Mesh
    increls::Dict{Tuple{Int64, Int64}, IncRel} # dictionary of incidence relations
    name::String # name of the mesh
end

"""
    Mesh()

Define the mesh with default name and empty dictionary of incidence relations.
"""
function Mesh()
    Mesh(Dict{Tuple{Int64, Int64}, IncRel}(), "mesh")
end

"""
    Mesh(s::String)

Define the mesh named `s` with an empty dictionary of incidence relations.
"""
function Mesh(s::String)
    Mesh(Dict{Tuple{Int64, Int64}, IncRel}(), s)
end

"""
    load(m::Mesh, filename::String)

Load a mesh (incidence relation) from a MESH file.

!!! note

No check is performed that the loaded incidence relation is compatible with the
existing incidence relations in the mesh.
"""
function load(m::Mesh, filename::String)
    conns = import_MESH(filename)
    insert!(m, conns[1])
    return m
end

"""
    save(m::Mesh, filename::String)

Save a mesh base incidence relation to a MESH file.
"""
function save(m::Mesh, filename::String)
    ir = increl(m, basecode(m))
    return export_MESH(filename, ir)
end
 
"""
    increl(m::Mesh, irc::Tuple{Int64, Int64}) 

Retrieve the named incidence relation.
"""
increl(m::Mesh, irc::Tuple{Int64, Int64}) = m.increls[irc]

"""
    insert!(m::Mesh, increl::IncRel)

Insert the incidence relation. The code of the incidence relation is the key
under which this relation is stored in the mesh.
"""
insert!(m::Mesh, ir::IncRel) = (m.increls[code(ir)] = ir)

"""
    basecode(m::Mesh)

Compute the code of the base relation.

The base incidence relation is `(d, 0)` that represents the elements of the
interior of the domain.
"""
function basecode(m::Mesh)
    maxd = 0
    for irc in keys(m.increls)
        maxd = max(maxd, irc[1])
    end
    return (maxd, 0)
end

"""
    nspacedims(m::Mesh) 

Furnish the dimension of the space in which the mesh lives.
"""
function nspacedims(m::Mesh) 
    ir = increl(m, basecode(m))
    a = attribute(ir.right, "geom")
    return length(a[1]) 
end

"""
    baseincrel(m::Mesh)

Retrieve the base incidence relation for the mesh.
"""
baseincrel(m::Mesh) = increl(m, basecode(m))

"""
    Base.summary(ir::IncRel)

Form a brief summary of the incidence relation.
"""
function Base.summary(ir::IncRel)
    return "$(ir.name): " * summary(ir.left) * ", " * summary(ir.right) 
end

"""
    Base.summary(sc::S) where {S<:ShapeColl}

Form a brief summary of the shape collection.
"""
function Base.summary(sc::S) where {S<:ShapeColl}
    s = "$(sc.name) = $(nshapes(sc)) x $(shapedesc(sc).name)"
    if !isempty(values(sc.attributes))
        s = s * " {"
        for k in keys(sc.attributes)
            s = s * k * ","
        end
        s = s * "}"
    end
    
    return s
end

"""
    Base.summary(m::Mesh)

Form a brief summary of the mesh.
"""
function Base.summary(m::Mesh)
    s = "Mesh $(m.name):"
    for ir in m.increls
        s = s * " $(ir[1]) = " * summary(ir[2]) * "; "
    end
    return s
end

function Base.summary(io::IO, m::Mesh)
    println(summary(m))
end

"""
    vselect(m::Mesh; kwargs...)

Select vertices. Return as an incidence relation.

Refer to MeshFinder `vselect`.
"""
function vselect(m::Mesh; kwargs...)
	ir = increl(m, basecode(m))
	geom = attribute(ir.right, "geom")
	list =  vselect(geom; (kwargs...))
	return IncRel(ShapeColl(MeshCore.P1, length(list)), ir.right, [[idx] for idx in list]) 
end

"""
    boundary(m::Mesh)

Compute the boundary of the mesh.
"""
function boundary(m::Mesh)
	ir = increl(m, basecode(m))
    sir = skeleton(ir, "skeleton") # compute the skeleton of the base incidence relation
    insert!(m, sir) # insert the skeleton into the mesh
    # Now construct the boundary incidence relation
    isboundary = sir.left.attributes["isboundary"]
    ind = [i for i in 1:length(isboundary) if isboundary[i]] 
    lft = ShapeColl(shapedesc(sir.left), length(ind), "facets")
    return IncRel(lft, sir.right, deepcopy(sir._v[ind]))
end

"""
    vertices(m::Mesh)

Compute the `(0, 0)` incidence relation for the vertices of the base incidence relation.
"""
function vertices(m::Mesh)
    ir = increl(m, basecode(m))
    return IncRel(ir.right, ir.right, [SVector{1, Int64}([idx]) for idx in 1:nshapes(ir.right)], "vertices")
end

"""
    submesh(m::Mesh, list)

Extract a submesh constructed of a subset of the base relation. 
"""
function submesh(m::Mesh, list)
    left = ShapeColl(shapedesc(sir.left), length(ind))
    return Mesh(IncRel(left, ir.right, [SVector{1, Int64}([idx]) for idx in 1:nshapes(ir.right)]))
end

function _label(sc, list, lab)
    if !("label" in keys(sc.attributes))
        sc.attributes["label"] = VecAttrib([zero(typeof(lab)) for idx in 1:nshapes(sc)])
    end
    a = sc.attributes["label"]
    for i in 1:length(list)
        a[list[i]] = lab
    end
end

"""
    label(m::Mesh, irc, list, lab)

Label shapes in `list` with the label `lab`.

Label the shapes on the `shapecoll` of the incidence relation.
`shapecoll` must be either `:left` or `:right`.
"""
function label(m::Mesh, irc, shapecoll, list, lab)
    ir = increl(m, irc)
    if shapecoll == :left
        _label(ir.left, list, lab)
    else
        shapecoll == :right
        _label(ir.right, list, lab)
    end
end
