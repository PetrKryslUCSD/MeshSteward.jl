using DelimitedFiles
using WriteVTK
using MeshCore: AbsShapeDesc, P1, L2, L3
using MeshCore: VecAttrib
using MeshCore: shapedesc, nshapes,  IncRel
using MeshCore: ShapeColl
using LinearAlgebra: norm
using StaticArrays

"""
    L2blockx(xs::Vector{T}; intbytes = 8) where {T}

Generate a graded mesh on an interval.

Keyword argument `intbytes` controls the size of the integer indexes.

# Return
By convention the function returns an incidence relation (`connectivity`)
between the elements (`connectivity.left`) and the vertices
(`connectivity.right`). The geometry is stored as the attribute "geom" of the
vertices.
"""
function L2blockx(xs::Vector{T}; intbytes = 8) where {T}
	inttype = Int64
    if intbytes == 4
        inttype = Int32
    end
    nL = length(xs)-1;
    nnodes = (nL+1);
    ncells = (nL);
    xys = zeros(T, nnodes, 1);
    conns = zeros(inttype, ncells, 2);

    f=1;
    for i in 1:(nL+1)
        xys[f, 1] = xs[i]
        f=f+1;
    end
    
    gc=1;
    for i in 1:nL
       conns[gc, 1] = i
       conns[gc, 2] = (i+1)
       gc=gc+1;
    end
    
    C = inttype.(conns[1:gc-1, :]);
    N, TC = size(xys, 2), eltype(xys)
    locs =  VecAttrib([SVector{N, TC}(xys[i, :]) for i in 1:size(xys, 1)])
    vertices = ShapeColl(P1, length(locs), "vertices")
    vertices.attributes["geom"] = locs
    elements = ShapeColl(L2, size(C, 1), "elements")
    return IncRel(elements, vertices, C)
end

"""
    L2block(Length, nL; kwargs...)

Generate a quadrilateral mesh  of the 2D block.

See also: L2blockx
"""
function L2block(Length, nL; kwargs...)
    return L2blockx(collect(linearspace(0.0, Length, nL+1)); kwargs...);
end
