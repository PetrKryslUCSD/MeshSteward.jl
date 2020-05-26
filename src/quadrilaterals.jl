using DelimitedFiles
using WriteVTK
using MeshCore: AbsShapeDesc, P1, L2, T3, Q4, T4, H8
using MeshCore: VecAttrib
using MeshCore: shapedesc, nshapes,  IncRel
using MeshCore: ShapeColl
using LinearAlgebra: norm

"""
    Q4blockx(xs::Vector{T}, ys::Vector{T}; intbytes = 8) where {T}

Generate a graded quadrilateral mesh  of a 2D block.

Keyword argument `intbytes` controls the size of the integer indexes.

# Return
By convention the function returns an incidence relation (`connectivity`)
between the elements (`connectivity.left`) and the vertices
(`connectivity.right`). The geometry is stored as the attribute "geom" of the
vertices.
"""
function Q4blockx(xs::Vector{T}, ys::Vector{T}; intbytes = 8) where {T}
	inttype = Int64
    if intbytes == 4
        inttype = Int32
    end
    nL = length(xs)-1;
    nW = length(ys)-1;
    nnodes = (nL+1)*(nW+1);
    ncells = (nL)*(nW);
    xys = zeros(T, nnodes, 2);
    conns = zeros(inttype, ncells, 4);

    f=1;
    for j in 1:(nW+1)
        for i in 1:(nL+1)
            xys[f, 1] = xs[i]
            xys[f, 2] = ys[j]
            f=f+1;
        end
    end
    
    gc=1;
    for i in 1:nL
        for j in 1:nW
        	f=(j-1)*(nL+1)+i;
        	f = (j-1) * (nL+1) + i;
        	conns[gc, 1] = f
        	conns[gc, 2] = (f+1)
        	conns[gc, 3] = f+(nL+1)+1
        	conns[gc, 4] = f+(nL+1)
        	gc=gc+1;
        end
    end
    
    C = inttype.(conns[1:gc-1, :]);
    N, TC = size(xys, 2), eltype(xys)
    locs =  VecAttrib([SVector{N, TC}(xys[i, :]) for i in 1:size(xys, 1)])
    vertices = ShapeColl(P1, length(locs), "vertices")
    vertices.attributes["geom"] = locs
    elements = ShapeColl(Q4, size(C, 1), "elements")
    return IncRel(elements, vertices, C)
end

"""
    Q4block(Length, Width, nL, nW; kwargs...)

Generate a quadrilateral mesh  of the 2D block.

See also: Q4blockx
"""
function Q4block(Length, Width, nL, nW; kwargs...)
    return Q4blockx(collect(linearspace(0.0, Length, nL+1)),
                    collect(linearspace(0.0, Width, nW+1)); kwargs...);
end
