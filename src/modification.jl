using DelimitedFiles
using WriteVTK
using MeshCore: AbsShapeDesc, P1, L2, T3, Q4, T4, H8
using MeshCore: VecAttrib
using MeshCore: shapedesc, nshapes,  IncRel
using MeshCore: ShapeColl
using LinearAlgebra: norm

"""
    vconnected(ir)

Find vertices that are not connected to any shape in the incidence relation.

- `isconnected` = vector is returned which is for the node `k` either true 
  (vertex `k` is connected), or false (vertex `k` is not connected).
"""
function vconnected(ir)
    isconnected = falses(nshapes(ir.right));
    for i in 1:nrelations(ir)
        for j in 1:nentities(ir, i)
            isconnected[retrieve(ir, i, j)] = true
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
    new_numbering = fill(zero(indextype(ir)), nshapes(ir.right));
    id = 1;
    for i in 1:length(isconnected)
        if (isconnected[i])
            new_numbering[i] = id;
            id = id+1;
        end
    end
    return new_numbering
end

"""
    compactnodes(fens::FENodeSet, connected::Vector{Bool})

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
    C = [SVector{3}(retrieve(ir, idx)) for idx in 1:nrelations(ir)] 
    elements = ShapeColl(shapedesc(ir.left), length(C), "elements")
    return IncRel(elements, vertices, C)
end

    