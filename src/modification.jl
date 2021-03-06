import Base.cat
using DelimitedFiles
using WriteVTK
using SparseArrays
using SymRCM
using MeshCore: AbsShapeDesc, P1, L2, T3, Q4, T4, H8
using MeshCore: VecAttrib
using MeshCore: shapedesc, nshapes,  IncRel
using MeshCore: ShapeColl
using LinearAlgebra: norm

"""
    transform(ir, T = x -> x)

Change the locations of the vertices through the transformation `T`.
"""
function transform(ir, T = x -> x)
    locs = ir.right.attributes["geom"]
    N = length(locs[1])
    TC = eltype(locs[1])
    nlocs =  VecAttrib([SVector{N, TC}(T(locs[i])) for i in 1:length(locs)])
    ir.right.attributes["geom"] = nlocs
end

"""
    vconnected(ir)

Find whether or not the vertices are connected to any shape on the left of the
incidence relation.

- `isconnected` = vector is returned which is for the node `k` either true 
  (vertex `k` is connected), or false (vertex `k` is not connected).
"""
function vconnected(ir)
    isconnected = falses(nshapes(ir.right));
    for i in 1:nrelations(ir)
        for j in 1:nentities(ir, i)
            isconnected[ir[i, j]] = true
        end
    end
    return isconnected
end

"""
    vnewnumbering(ir, isconnected)

Compute the new numbering obtained by deleting unconnected vertices.
"""
function vnewnumbering(ir, isconnected)
    @_check length(isconnected) == nshapes(ir.right)
    p = fill(zero(indextype(ir)), nshapes(ir.right));
    id = 1;
    for i in 1:length(isconnected)
        if (isconnected[i])
            p[i] = id;
            id = id+1;
        end
    end
    return p
end

"""
    compactify(ir, new_numbering)

Compact the finite element node set by deleting unconnected nodes.

`fens` = array of finite element nodes
`connected` = The array element `connected[j]` is either 0 (when `j` is an
  unconnected node), or a positive number (when node `j` is connected to
  other nodes by at least one finite element)

# Output
`fens` = new set of finite element nodes
`new_numbering`= array which tells where in the new `fens` array the
     connected nodes are (or 0 when the node was unconnected). For instance,
     node 5 was connected, and in the new array it is the third node: then
     `new_numbering[5]` is 3.

# Examples
Let us say there are nodes not connected to any finite element that you
would like to remove from the mesh: here is how that would be
accomplished.
```
connected = findunconnnodes(fens, fes);
fens, new_numbering = compactnodes(fens, connected);
fes = renumberconn!(fes, new_numbering);
```
Finally, check that the mesh is valid:
```
validate_mesh(fens, fes);
```
"""
function compactify(ir, new_numbering)
    @_check length(new_numbering) == nshapes(ir.right)
    locs = ir.right.attributes["geom"] # this is the old geometry attribute
    N = length(locs[1]) # number of spatial dimensions
    TC = eltype(locs[1])
    # Now generate a vector of the locations for connected vertices
    v = [SVector{N, TC}(locs[i]) for i in 1:length(locs) if new_numbering[i] != 0]
    locs =  VecAttrib(v) # this is the new geometry attribute
    vertices = ShapeColl(P1, length(locs), "vertices")
    vertices.attributes["geom"] = locs
    # Elements 
    C = [SVector{3}(ir[idx]) for idx in 1:nrelations(ir)] 
    elements = ShapeColl(shapedesc(ir.left), length(C), "elements")
    return IncRel(elements, vertices, C)
end

# This code was taken over from FinEtools: refer to fusenodes
function _fusen(xyz1, id1, xyz2, id2, tolerance)
    dim = size(xyz1,2);
    nn1 = size(xyz1, 1)
    nn2 = size(xyz2, 1)
    # Decide which nodes should be checked for proximity
    ib = intersectboxes(inflatebox!(boundingbox(xyz1), tolerance), inflatebox!(boundingbox(xyz2), tolerance))
    node1in = fill(false, nn1);
    node2in = fill(false, nn2);
    if length(ib) > 0
        for i=1:nn1
            node1in[i] = inbox(ib, @view xyz1[i, :])
        end
        for i=1:nn2
            node2in[i] = inbox(ib, @view xyz2[i, :])
        end
    end
    # Mark nodes from the first array that are duplicated in the second
    if (tolerance > 0.0) # should we attempt to merge nodes?
        for i=1:nn1
            if node1in[i]
                breakoff = false
                for rx=1:nn2
                    if node2in[rx]
                        distance = 0.0
                        for cx=1:dim
                            distance = distance + abs(xyz2[rx,cx]-xyz1[i,cx]);
                            if (distance >= tolerance) # shortcut: if the distance is already too large, stop checking
                                break
                            end
                        end
                        if (distance < tolerance)
                            id1[i] = -rx; breakoff = true;
                        end
                    end
                    if breakoff
                        break
                    end
                end
            end
        end
    end
    # Generate  fused arrays of the nodes. First copy in the nodes from the second set...
    xyzm = zeros(eltype(xyz1),nn1+nn2,dim);
    for rx = 1:nn2
        for cx = 1:dim
            xyzm[rx,cx] = xyz2[rx,cx];
        end
    end
    # idm = zeros(eltype(id1),nn1+nn2);
    # for rx = 1:nn2
    #     idm[rx] = rx;
    # end
    mid=nn2+1;
    # ...and then we add in only non-duplicated nodes from the first set
    for i=1:nn1
        if id1[i]>0
            id1[i] = mid;
            # idm[mid] = mid;
            for cx = 1:dim
                xyzm[mid,cx] = xyz1[i,cx];
            end
            mid = mid+1;
        else
            id1[i] = id2[-id1[i]];
        end
    end
    nnodes = mid-1;
    # The set 1 is described by these locations. The new numbering applies also
    # to set 1.
    xyzm = xyzm[1:nnodes,:];
    new_indexes_of_set1_nodes = deepcopy(id1);
    # The node set 2 numbering stays the same
    return xyzm, new_indexes_of_set1_nodes
end

"""
    fusevertices(locs1, locs2, tolerance)

Fuse together vertices from two vortex sets.

Fuse two vertex sets. If necessary, by gluing together vertices located within
`tolerance` of each other. The two vertex sets are fused
together by merging the vertices that fall within a box of size `tolerance`. The
merged vertex set, `fens`, and the new  indexes of the nodes in the set `fens1`
are returned.

The set `fens2` will be included unchanged, in the same order,
in the node set `fens`.
The indexes of the node set `fens1` will have changed.

# Example
After the call to this function we have
`k=new_indexes_of_fens1_nodes[j]` is the node in the node set `fens` which
used to be node `j` in node set `fens1`.
The finite element set connectivity that used to refer to `fens1`
needs to be updated to refer to the same nodes in  the set `fens` as
     `updateconn!(fes, new_indexes_of_fens1_nodes);`
"""
function fusevertices(locs1, locs2, tolerance)
    @_check length(locs1[1]) == length(locs2[1])
    dim = length(locs1[1]);
    nn1 = length(locs1)
    nn2 = length(locs2)
    TC = eltype(locs1[1])
    xyz1 = zeros(TC,nn1,dim); 
    for i in 1:length(locs1)
        xyz1[i, :] = locs1[i]
    end
    xyz2 = zeros(TC,nn2,dim); 
    for i in 1:length(locs2)
        xyz2[i, :] = locs2[i]
    end
    id1 = collect(1:nn1);
    id2 = collect(1:nn2);
    xyzm, new_indexes_of_set1_nodes = _fusen(xyz1, id1, xyz2, id2, tolerance)
    N = size(xyzm, 2)
    nlocs1 = VecAttrib([SVector{N, TC}(xyzm[i, :]) for i in 1:size(xyzm, 1)])
    return nlocs1, new_indexes_of_set1_nodes
end

"""
    withvertices(ir, locs)

Create a new incidence relation referring to a different set of vertices.

Presumably the set of vertices is simply broadened from the one used by the
incidence relation `ir`.
"""
function withvertices(ir, locs)
    vertices = ShapeColl(P1, length(locs), "vertices")
    vertices.attributes["geom"] = locs
    elements = ShapeColl(shapedesc(ir.left), nrelations(ir), "elements")
    return IncRel(elements, vertices, [ir[idx] for idx in 1:nrelations(ir)])
end

"""
    renumbered(ir, p)

Renumber the connectivity of the shapes based on a new numbering for the
vertices.

- `p` = new serial numbers for the vertices.  The connectivity
          should be changed as `conn[j]` --> `p[conn[j]]`

Returns new incidence relation with renumbered connectivity.

# Example

To do: Revise this example.
Let us say there are nodes not connected to any finite element that you would
like to remove from the mesh: here is how that would be accomplished.
```
connected = findunconnnodes(fens, fes);
fens, p = compactfens(fens, connected);
fes = renumberconn!(fes, p);
```
Finally, check that the mesh is valid:
```julia
validate_mesh(fens, fes);
```
"""
function renumbered(ir, p)
    N = nentities(ir, 1)
    C = SVector{N, indextype(ir)}[]
    for i in 1:nrelations(ir)
        c = ir[i]
        push!(C, SVector{N}(p[c]))
    end
    locs = ir.right.attributes["geom"]
    vertices = ShapeColl(P1, length(locs), "vertices")
    vertices.attributes["geom"] = locs
    elements = ShapeColl(shapedesc(ir.left), length(C), "elements")
    return IncRel(elements, vertices, C)
end

"""
    cat(ir1::T, ir2::T) where {T<:IncRel}

Concatenate the connectivities of two shape collections.

The two shape collections must be of the same shape descriptor, and they must
refer to the same attribute describing the locations of the vertices.
"""
function cat(ir1::T, ir2::T) where {T<:IncRel}
    # First, the left shapes must be of the same description
    @_check shapedesc(ir1.left) == shapedesc(ir2.left)
    # The shape collections on the right must be vertices
    @_check shapedesc(ir1.right) == shapedesc(ir2.right) == P1
    # The shape collections must refer to the same set of vertices. The length
    # is a cheap proxy for checking that condition.
    @_check length(ir1.right.attributes["geom"]) == length(ir2.right.attributes["geom"])
    # The shape collections must have fixed cardinality.
    N = nentities(ir1, 1)
    C = SVector{N, indextype(ir1)}[]
    for i in 1:nrelations(ir1)
        push!(C, ir1[i])
    end
    for i in 1:nrelations(ir2)
        push!(C, ir2[i])
    end
    locs = ir1.right.attributes["geom"]
    vertices = ShapeColl(P1, length(locs), "vertices")
    vertices.attributes["geom"] = locs
    elements = ShapeColl(shapedesc(ir1.left), length(C), "elements")
    return IncRel(elements, vertices, C)
end

"""
    mergeirs(conn1, conn2, tolerance = eps())

Merge two incidence relations, fuse vertices closer then tolerance.
"""
function mergeirs(conn1, conn2, tolerance = eps())
    locs1 = conn1.right.attributes["geom"]
    locs2 = conn2.right.attributes["geom"]
    nlocs1, ni1 = fusevertices(locs1, locs2, tolerance)
    conn1 = withvertices(conn1, nlocs1)
    conn2 = withvertices(conn2, nlocs1)
    conn1 = renumbered(conn1, ni1)
    return cat(conn1, conn2)
end

"""
    minimize_profile(conn)

Re-number the vertices so that the profile can be minimized.

# Output

Renumbered incidence relation.
"""
function minimize_profile(conn)
    I = fill(zero(Int), 0)
    J = fill(zero(Int), 0)
    for k in 1:nrelations(conn)
        ne = nentities(conn, k)
        for i in 1:ne
            append!(I, conn[k])
            for m in 1:ne
                push!(J, conn[k, i])
            end
        end
    end
    V = fill(1.0, length(I))
    S = sparse(I, J, V, nshapes(conn.right), nshapes(conn.right))
    # find the new numbering (permutation)
    p = symrcm(S)
    # number the vertices of the shapes on the left using the new permutation
    conn = renumbered(conn, p)
    # reorder the vertices attribute
    ip = similar(p) # inverse permutation
    ip[p] = 1:length(p)
    locs = conn.right.attributes["geom"]
    newlocs = VecAttrib([locs[k] for k in ip])
    conn.right.attributes["geom"] = newlocs
    return conn
end