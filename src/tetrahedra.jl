using DelimitedFiles
using WriteVTK
using MeshCore: AbsShapeDesc, P1, L2, T3, Q4, T4, H8
using MeshCore: VecAttrib
using MeshCore: shapedesc, nshapes, IncRel
using MeshCore: ShapeColl
using LinearAlgebra: norm

"""
    T4blockx(xs::Vector{T}, ys::Vector{T}, zs::Vector{T}, orientation::Symbol) where {T}

Generate a graded tetrahedral mesh  of a 3D block.

Four-node tetrahedra in a regular arrangement, with non-uniform given spacing
between the nodes, with a given orientation of the diagonals.
The mesh is produced by splitting each logical  rectangular cell into a certain number of
tetrahedra. Orientation may be chosen as `:a`, `:b` (six tetrahedra per rectangular cell),
or `:ca` or `:cb` (five tetrahedra per rectangular cell). Keyword argument

# Return
By convention the function returns an incidence relation (`connectivity`)
between the elements (`connectivity.left`) and the vertices
(`connectivity.right`). The geometry is stored as the attribute "geom" of the
vertices.
"""
function T4blockx(xs::Vector{T}, ys::Vector{T}, zs::Vector{T}, orientation::Symbol; intbytes = 8) where {T}
    inttype = Int64
    if intbytes == 4
        inttype = Int32
    end
    nL = length(xs)-1;
    nW = length(ys)-1;
    nH = length(zs)-1;
    nnodes = (nL+1)*(nW+1)*(nH+1);
    ncells = 6*(nL)*(nW)*(nH);
    xyzs = zeros(T, nnodes, 3);
    conns = zeros(inttype, ncells, 4);
    if (orientation==:a)
        t4ia = inttype[1  8  5  6; 3  4  2  7; 7  2  6  8; 4  7  8  2; 2  1  6  8; 4  8  1  2];
        t4ib =  inttype[1  8  5  6; 3  4  2  7; 7  2  6  8; 4  7  8  2; 2  1  6  8; 4  8  1  2];
    elseif (orientation==:b)
        t4ia = inttype[2 7 5 6; 1 8 5 7; 1 3 4 8; 2 1 5 7; 1 2 3 7; 3 7 8 1];
        t4ib =  [2 7 5 6; 1 8 5 7; 1 3 4 8; 2 1 5 7; 1 2 3 7; 3 7 8 1];
    elseif (orientation==:ca)
        t4ia = inttype[8  4  7  5; 6  7  2  5; 3  4  2  7; 1  2  4  5; 7  4  2  5];
        t4ib = inttype[7  3  6  8; 5  8  6  1; 2  3  1  6; 4  1  3  8; 6  3  1  8];
    elseif (orientation==:cb)
        t4ia = inttype[7  3  6  8; 5  8  6  1; 2  3  1  6; 4  1  3  8; 6  3  1  8];
        t4ib = inttype[8  4  7  5; 6  7  2  5; 3  4  2  7; 1  2  4  5; 7  4  2  5];
    else
        error("Unknown orientation")
    end

    f=1;
    for k=1:(nH+1)
        for j=1:(nW+1)
            for i=1:(nL+1)
                xyzs[f, 1] = xs[i]
                xyzs[f, 2] = ys[j]
                xyzs[f, 3] = zs[k];
                f=f+1;
            end
        end
    end

    function node_numbers(i, j, k, nL, nW, nH)
        f=(k-1)*((nL+1)*(nW+1))+(j-1)*(nL+1)+i;
        nn=[f (f+1)  f+(nL+1)+1 f+(nL+1)];
        return inttype[nn broadcast(+, nn, (nL+1)*(nW+1))];
    end

    gc=1;
    for i=1:nL
        for j=1:nW
            for k=1:nH
                nn=node_numbers(i, j, k, nL, nW, nH);
                if (mod(sum( [i, j, k] ), 2)==0)
                    t4i =t4ib;
                else
                    t4i =t4ia;
                end
                for r=1:size(t4i, 1)
                    for c1=1:size(t4i, 2)
                        conns[gc, c1] = nn[t4i[r, c1]];
                    end
                    gc=gc+1;
                end
            end
        end
    end

    C = inttype.(conns[1:gc-1, :]);
    N, TC = size(xyzs, 2), eltype(xyzs)
    locs =  VecAttrib([SVector{N, TC}(xyzs[i, :]) for i in 1:size(xyzs, 1)])
    vertices = ShapeColl(P1, length(locs), "vertices")
    vertices.attributes["geom"] = locs
    elements = ShapeColl(T4, size(C, 1), "elements")
    return IncRel(elements, vertices, C)
end

"""
    T4block(Length, Width, Height, nL, nW, nH, orientation = :a)

Generate a tetrahedral mesh  of the 3D block.

Four-node tetrahedra in a regular arrangement, with uniform spacing between
the nodes, with a given orientation of the diagonals.
The mesh is produced by splitting each logical  rectangular cell into six
tetrahedra. Range =<0, Length> x <0, Width> x <0, Height>.
Divided into elements: nL,  nW,  nH in the first,  second,  and
third direction (x, y, z).

See also: T4blockx
"""
function T4block(Length, Width, Height, nL, nW, nH, orientation = :a; kwargs...)
    return T4blockx(collect(linearspace(0.0, Length, nL+1)),
                    collect(linearspace(0.0, Width, nW+1)),
                    collect(linearspace(0.0, Height, nH+1)), orientation; kwargs...);
end
