using MeshCore
using MeshCore: ShapeColl, IncRel, ir_skeleton
using MeshCore: shapedesc, nshapes, ir_code, attribute
import Base.show
using StaticArrays

"""
    Mesh

The type of the mesh. 

It stores the incidence relations keyed by the code of the relation.

The incidence relation code is `(d1, d2)`, where `d1` is the manifold dimension
of the shape collection on the left, and `d2` is the manifold dimension of the
shape collection on the right.

The incidence relations are stored with a key consisting of the code and a
string tag. If the string tag is unspecified, it is assumed to be an empty
string.
"""
struct Mesh
    name::String # name of the mesh
    _increls::Dict{Tuple{Tuple{Int64, Int64}, String}, IncRel} # dictionary of incidence relations
end

"""
    Mesh()

Define the mesh with default name and empty dictionary of incidence relations.
"""
function Mesh()
    Mesh("mesh", Dict{Tuple{Tuple{Int64, Int64}, String}, IncRel}())
end

"""
    Mesh(s::String)

Define the mesh named `s` with an empty dictionary of incidence relations.
"""
function Mesh(s::String)
    Mesh(s, Dict{Tuple{Tuple{Int64, Int64}, String}, IncRel}())
end

"""
    load(m::Mesh, filename::String)

Load a mesh (incidence relation) from a MESH file.

!!! note 

    No check is performed that the loaded incidence relation is compatible
    with the existing incidence relations in the mesh.
"""
function load(m::Mesh, filename::String)
    conns = import_MESH(filename)
    return attach!(m, conns[1])
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

Retrieve the named incidence relation based on the code.

Any tag is matched.
"""
function increl(m::Mesh, irc::Tuple{Int64, Int64}) 
    for (k, v) in zip(keys(m._increls), values(m._increls))
        if k[1] == irc
            return v
        end
    end
    return nothing
end

"""
    increl(m::Mesh, fullirc::Tuple{Tuple{Int64, Int64}, String})

Retrieve the named incidence relation based on the full key (code + tag).
"""
increl(m::Mesh, fullirc::Tuple{Tuple{Int64, Int64}, String}) = m._increls[fullirc]

"""
    attach!(m::Mesh, increl::IncRel)

Attach the incidence relation under its code and empty tag. 

The code of the incidence relation combined with an empty tag (`""`) is the key
under which this relation is stored in the mesh.
"""
function attach!(m::Mesh, ir::IncRel) 
    return attach!(m, ir, "")
end

"""
    attach!(m::Mesh, increl::IncRel, tag::String)

Attach the incidence relation under its code and given tag. 

The code of the incidence relation combined with the tag is the key
under which this relation is stored in the mesh.
"""
function attach!(m::Mesh, ir::IncRel, tag::String) 
    m._increls[(ir_code(ir), tag)] = ir
    return m
end

"""
    basecode(m::Mesh)

Compute the code of the base relation.

The base incidence relation is `(d, 0)` that represents the elements of the
interior of the domain.
"""
function basecode(m::Mesh)
    maxd = 0
    for irc in keys(m._increls)
        maxd = max(maxd, irc[1][1])
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
    baseincrel(m::Mesh, tag::String)

Retrieve the base incidence relation for the mesh distinguished by its tag.
"""
baseincrel(m::Mesh, tag::String) = increl(m, (basecode(m), tag))

"""
    geometry(m::Mesh)

Retrieve the geometry attribute from the vertices.
"""
function geometry(m::Mesh)
    ir = increl(m, basecode(m))
    return attribute(ir.right, "geom")
end

"""
    Base.summary(m::Mesh)

Form a brief summary of the mesh.
"""
function Base.summary(m::Mesh)
    s = "Mesh $(m.name):"
    for ir in m._increls
        s = s * " $(ir[1]) = " * summary(ir[2]) * "; "
    end
    return s
end

"""
    Base.summary(io::IO, m::Mesh)

Form a brief summary of the mesh.
"""
function Base.summary(io::IO, m::Mesh)
    print(io, summary(m), "\n")
end

"""
    vselect(m::Mesh; kwargs...)

Select vertices. Return as an incidence relation.

Refer to `vselect` that works with the geometry attribute.
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

The incidents relation is stored in the mesh with the tag "boundary".
"""
function boundary(m::Mesh)
	ir = increl(m, basecode(m))
    sir = ir_skeleton(ir, "skeleton") # compute the skeleton of the base incidence relation
    attach!(m, sir) # insert the skeleton into the mesh
    # Now construct the boundary incidence relation
    isboundary = sir.left.attributes["isboundary"]
    ind = [i for i in 1:length(isboundary) if isboundary[i]] 
    lft = ShapeColl(shapedesc(sir.left), length(ind), "facets")
    bir = IncRel(lft, sir.right, deepcopy(sir._v[ind]))
    attach!(m, bir, "boundary")
    return bir
end

"""
    vertices(m::Mesh)

Compute the `(0, 0)` incidence relation for the vertices of the base incidence
relation.
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
    ir = increl(m, basecode(m))
    lft = ShapeColl(shapedesc(ir.left), length(list))
    v = [ir[idx] for idx in list]
    nir = IncRel(lft, ir.right, v)
    nm = Mesh()
    return attach!(nm, nir)
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
