using LinearAlgebra: norm, dot, cross
using Statistics: mean
using MeshCore: IncRel, indextype, nshapes, retrieve, attribute, nentities, nrelations, manifdim, n1storderv

"""
    eselect(ir::IncRel; kwargs...) 

Select finite elements.

# Arguments
- `ir` = incidence relation representing finite element set `(d, 0)`.
- `kwargs` = keyword arguments to specify the selection criteria

## Selection criteria

### facing
Select all "boundary" elements that "face" a certain direction.
```
exteriorbfl = eselect(ir, facing=true, direction=x -> [1.0, 1.0, 0.0]);
```
or
```
exteriorbfl = eselect(ir, facing=true, direction=xyz -> xyz/norm(xyz), dotmin = 0.99);
```
where `xyz` is the location of the centroid  of  a boundary element.
Here the finite element is considered "facing" in the given direction if the dot
product of its normal and the direction vector is greater than `dotmin`.
The default value for `dotmin` is 0.01 (this corresponds to  almost 90 degrees
between the normal to the finite element  and the given direction).

This selection method makes sense only for elements that are  surface-like (i. e.
for boundary meshes).

### label
Select elements based on their label.
```
rl1 = eselect(ir, label=1)
```

### box, distance
Select elements based on some criteria that their nodes satisfy.  See the
function `vselect()`.

Example:
Select all  elements whose nodes are closer than `R+inflate` from the point `from`.
```
linner = eselect(ir, distance = R, from = [0.0 0.0 0.0], inflate = tolerance)
```

Example:

```
exteriorbfl = eselect(ir, box=[1.0, 1.0, 0.0, pi/2, 0.0, Th], inflate=tolerance)
```
where `Th` is a variable.

### Optional keyword arguments
Should we consider the element only if all its nodes are in?
- `allin` = Boolean: if true, then all nodes of an element must satisfy the
  criterion; otherwise  one is enough.

# Output
- `felist` = list of finite elements (shapes) from the from the collection on
  the left of the incidence relation that satisfy the criteria
"""
function eselect(ir::IncRel; kwargs...) 

    # Extract arguments
    allin = nothing; flood = nothing; facing = nothing; label = nothing;
    # nearestto = nothing; smoothpatch = nothing;
    startnode = 0; dotmin = 0.01
    overlappingbox = nothing
    for apair in pairs(kwargs)
        sy, val = apair
        if sy == :flood
            flood = val
        elseif sy == :facing
            facing = val
        elseif sy == :label
            label = val
        elseif sy == :overlappingbox
            overlappingbox = val
        elseif sy == :nearestto
            nearestto = val
        elseif sy == :allin
            allin = val
        end
    end

    if flood != nothing
        for apair in pairs(kwargs)
            sy, val = apair
            if sy == :startnode
                startnode = val
            end
        end
    end

    if facing != nothing
        facing = true;
        direction = nothing
        dotmin = 0.01;
        for apair in pairs(kwargs)
            sy, val = apair
            if sy == :direction
                direction = val
            elseif (sy == :dotmin) || (sy == :tolerance)# allow for obsolete keyword  to work
                dotmin = val
            end
        end
    end

    # The  elements of this array are flipped from zero  when the element satisfies
    # the search condition. This list is  eventually purged of the zero elements and
    # returned.
    felist = zeros(indextype(ir),nshapes(ir.left));

    #     Select based on fe label
    if label != nothing
        _label = attribute(ir.left, "label")
        for i in 1:nshapes(ir.left)
            if label == _label[i]
                felist[i] = i;   # matched this element
            end
        end
        return  felist[findall(x->x!=0, felist)]; # return the nonzero element numbers
    end

    # Select by flooding
    # if flood != nothing && (flood)
    #     @assert startnode > 0
    #     fen2fe = FENodeToFEMap(connasarray(fes), count(fens))
    #     felist = zeros(FInt, count(fes));
    #     pfelist = zeros(FInt, count(fes));
    #     felist[fen2fe.map[startnode]] .= 1;
    #     while true
    #         copyto!(pfelist, felist);
    #         markedl = findall(x -> x != 0, felist)
    #         for j = markedl
    #             for k = fes.conn[j]
    #                 felist[fen2fe.map[k]] .= 1;
    #             end
    #         end
    #         if sum(pfelist-felist) == 0 # If there are no more changes in this pass, we are done
    #             break;
    #         end
    #     end
    #     return findall(x -> x != 0, felist); # return the nonzero element numbers;
    # end

    # Helper function: calculate the normal to a boundary finite element
    function normal2d(c, locs, n1stov)
        t = locs[c[2]] - locs[c[1]]
        n = [t[2], -t[1]]
        return n/norm(n);
    end
    function normal3d(c, locs, n1stov)
        if n1stov == 3 # triangle
            v1 = locs[c[2]] - locs[c[1]]
            v2 = locs[c[3]] - locs[c[1]]
            n = cross(v1, v2)
            return n/norm(n);
        else
            v1 = locs[c[3]] - locs[c[1]]
            v2 = locs[c[4]] - locs[c[2]]
            n = cross(v1, v2)
            return n/norm(n);
        end
    end
    center(c, locs) = begin
        r = locs[c[1]]
        for i in 2:length(c)
            r += locs[c[i]]
        end
        return r  ./ length(c)
    end

    # Select by in which direction the normal of the fes face
    if (facing != nothing) && (facing)
        locs = attribute(ir.right, "geom")
        sdim = length(locs[1])
        mdim = manifdim(shapedesc(ir.left));
        @assert (mdim == sdim-1) "'Facing': only for Manifold dim. == Space dim.-1"
        n1stov = n1storderv(shapedesc(ir.left))
        @assert (mdim == 1) && (n1stov == 2) || 
                (mdim == 2) && ((n1stov == 2) || (n1stov == 3)) "'Facing': shapes with n1stov = $(n1stov)"
        normal = (mdim == 2) ? normal3d : normal2d
        for i in 1:nrelations(ir)
            c = retrieve(ir, i)
            n = normal(c, locs, n1stov)
            d = direction(center(c, locs))
            d = d / norm(d)
            if (dot(vec(n),vec(d)) > dotmin)
                felist[i] = i;
            end
        end
        return  felist[findall(x->x!=0, felist)]; # return the nonzero element numbers
    end

    #  Default:   Select based on location of nodes
    #   Should we consider the element only if all its nodes are in?
    allinvalue = (allin == nothing) || ((allin != nothing) && (allin))
    # Select elements whose nodes are in the selected node list
    locs = attribute(ir.right, "geom")
    vlist = vselect(locs; kwargs...);
    allv = zeros(Bool, nshapes(ir.right));
    allv[vlist] .= true
    for i in 1:nrelations(ir)
        found = 0
        for nd in retrieve(ir, i)
            if allv[nd]
                found = found + 1
            end
        end
        if allinvalue
            if found == nentities(ir, i)
                felist[i] = i;
            end
        else
            if found >= 1
                felist[i] = i;
            end
        end
    end
    return felist[findall(x -> x!=0, felist)]; # return the nonzero element numbers

end
