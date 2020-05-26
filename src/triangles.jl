using DelimitedFiles
using WriteVTK
using MeshCore: AbsShapeDesc, P1, L2, T3, Q4, T4, H8
using MeshCore: VecAttrib
using MeshCore: shapedesc, nshapes, IncRel
using MeshCore: ShapeColl
using LinearAlgebra: norm

"""
    T3blockx(xs::Vector{T}, ys::Vector{T}, orientation::Symbol) where {T}

Generate a graded triangle mesh  of a 2D block.

The mesh is produced by splitting each logical  rectangular cell into two
triangles. Orientation may be chosen as `:a`, `:b`.

Keyword argument `intbytes` controls the size of the integer indexes.

# Return
By convention the function returns an incidence relation (`connectivity`)
between the elements (`connectivity.left`) and the vertices
(`connectivity.right`). The geometry is stored as the attribute "geom" of the
vertices.
"""
function T3blockx(xs::Vector{T}, ys::Vector{T}, orientation::Symbol; intbytes = 8) where {T}
    if (orientation==:a) || (orientation==:b)
        # nothing
    else
        error("Unknown orientation")
    end
    inttype = Int64
    if intbytes == 4
        inttype = Int32
    end
    nL = length(xs)-1;
    nW = length(ys)-1;
    nnodes = (nL+1)*(nW+1);
    ncells = 2*(nL)*(nW);
    xys = zeros(T, nnodes, 2);
    conns = zeros(inttype, ncells, 3);

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
            if     (orientation==:a)
                conns[gc,:] .= f, (f+1), f+(nL+1)
            elseif (orientation==:b)
                conns[gc,:] .= f, (f+1), f+(nL+1)+1
            end
            gc=gc+1;
            if     (orientation==:a)
                conns[gc,:] .= (f+1), f+(nL+1)+1, f+(nL+1)
            elseif (orientation==:b)
                conns[gc,:] .= f, f+(nL+1)+1, f+(nL+1)
            end
            gc=gc+1;
        end
    end
    
    C = inttype.(conns[1:gc-1, :]);
    N, TC = size(xys, 2), eltype(xys)
    locs =  VecAttrib([SVector{N, TC}(xys[i, :]) for i in 1:size(xys, 1)])
    vertices = ShapeColl(P1, length(locs), "vertices")
    vertices.attributes["geom"] = locs
    elements = ShapeColl(T3, size(C, 1), "elements")
    return IncRel(elements, vertices, C)
end

"""
    T3block(Length, Width, nL, nW, orientation = :a)

Generate a triangle mesh  of the 2D block.

See also: T3blockx
"""
function T3block(Length, Width, nL, nW, orientation = :a; kwargs...)
    return T3blockx(collect(linearspace(0.0, Length, nL+1)),
                    collect(linearspace(0.0, Width, nW+1)), orientation; kwargs...);
end
