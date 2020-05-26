using LinearAlgebra: norm, dot, cross
using Statistics: mean
using MeshCore: IncRel, indextype, nshapes, retrieve, attribute, nentities, nrelations

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
exteriorbfl = selectelem(fens, bdryfes, facing=true, direction=[1.0, 1.0, 0.0]);
```
or
```
exteriorbfl = selectelem(fens, bdryfes, facing=true, direction=dout, dotmin = 0.99);
```
where
```
function dout(xyz)
    return xyz/norm(xyz)
end
```
and `xyz` is the location of the centroid  of  a boundary element.
Here the finite element is considered "facing" in the given direction if the dot
product of its normal and the direction vector is greater than `dotmin`.
The default value for `dotmin` is 0.01 (this corresponds to  almost 90 degrees
between the normal to the finite element  and the given direction).

This selection method makes sense only for elements that are  surface-like (i. e.
for boundary mmeshes).

### label
Select elements based on their label.
```
rl1 = selectelem(fens, fes, label=1)
```

### box, distance
Select elements based on some criteria that their nodes satisfy.  See the
function `selectnode()`.

Example:
Select all  elements whose nodes are closer than `R+inflate` from the point `from`.
```
linner = selectelem(fens, bfes, distance = R, from = [0.0 0.0 0.0],
  inflate = tolerance)
```

Example:

```
exteriorbfl = selectelem(fens, bdryfes,
   box=[1.0, 1.0, 0.0, pi/2, 0.0, Thickness], inflate=tolerance);
```

### flood
Select all FEs connected together, starting from a given node.

Example:
Select all FEs connected together (Starting from node 13):
```julia
l = selectelem(fens, fes, flood = true, startnode = 13)
```

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
        for i in 1:length(fes.conn)
            if label==fes.label[i]
                felist[i] =i;   # matched this element
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
    function normal(Tangents)
        sdim, mdim = size(Tangents);
        @assert (mdim==1) || (mdim==2)
        if     mdim==1 # 1-D fe
            N = [Tangents[2,1],-Tangents[1,1]];
            return N/norm(N);
        elseif mdim==2 # 2-D fe
            N= cross(Tangents[:,1],Tangents[:,2])
            return N/norm(N);
        end
    end

    # Select by in which direction the normal of the fes face
    if (facing != nothing) && (facing)
        xs =fens.xyz;
        sd =spacedim(fens);
        md =manifdim(fes);
        @assert (md == sd-1) "'Facing': only for Manifold dim. == Space dim.-1"
        param_coords =zeros(FFlt,1,md);
        Need_Evaluation = (typeof(direction) <: Function);
        if ( !Need_Evaluation)
            d = reshape(direction,1,sd)/norm(direction);
        end
        Nder = bfungradpar(fes, vec(param_coords));
        for i=1:length(fes.conn)
            xyz =xs[[j for j in fes.conn[i]],:];
            Tangents =xyz'*Nder;
            N = normal(Tangents);
            if (Need_Evaluation)
                d = direction(mean(xyz, dims = 1));
                d = reshape(d,1,sd)/norm(d);
            end
            if (dot(vec(N),vec(d)) > dotmin)
                felist[i]=i;
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
