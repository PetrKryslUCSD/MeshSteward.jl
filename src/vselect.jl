using LinearAlgebra: norm, dot, cross
using Statistics: mean
using MeshCore: IncRel, indextype, nshapes, retrieve

"""
    selectnode(fens::FENodeSet; kwargs...)

Select nodes using some criterion.

# Arguments
- `v` = array of locations, one location per row
- `kwargs` = pairs of keyword argument/value

### distance
```
list = selectnode(fens.xyz, distance=1.0+0.1/2^nref, from=[0. 0.],
        inflate=tolerance);
```

### plane
```
candidates = selectnode(fens, plane = [0.0 0.0 1.0 0.0], thickness = h/1000)
```
The keyword `plane` defines the plane by its normal (the first two or
three numbers) and its distance from the origin (the last number). Nodes
are selected they lie on the plane,  or near the plane within the
distance `thickness` from the plane. The normal is assumed to be of unit
length, if it isn't apply as such, it will be normalized internally.

### nearestto
Find the node nearest to the location given.
```
nh = selectnode(fens, nearestto = [R+Ro/2, 0.0, 0.0] )
```
"""
# function selectnode(fens::FENodeSet; kwargs...)
#     nodelist = vselect(fens.xyz; kwargs...)
#     nodelist = dropdims(reshape(nodelist,1,length(nodelist)), dims=1);
#     return nodelist
# end


function _box_outputlist!(outputlist::Vector{IT}, abox::BT, sdim::IT, v::VT) where {IT, BT, VT}
    # Helper functions
    @inline inrange(rangelo,rangehi,x) = (rangelo <= x <= rangehi)
    nn = 0
    for j in 1:length(v)
        matches = true
        for i in 1:sdim
            if !inrange(abox[2*i-1], abox[2*i], v[j][i])
                matches = false; break
            end
        end
        if matches
            nn = nn + 1; outputlist[nn] = j;
        end
    end
    return outputlist, nn
end

"""
    vselect(v::FO; kwargs...) where {FO}

Select locations (vertices) based on some criterion.

`FO` is the type of a function or an callable object that returns the
coordinates of a vertex given its number.

## Selection criteria

### box
```
nLx = vselect(geom.co, box = [0.0 Lx  0.0 0.0 0.0 0.0], inflate = Lx/1.0e5)
```

The keyword 'inflate' may be used to increase or decrease the extent of
the box (or the distance) to make sure some nodes which would be on the
boundary are either excluded or included.

Returns
The list of vertices that match the search criterion.
"""
function vselect(v::VT; kwargs...) where {VT}
    # Extract arguments
    box = nothing; distance = nothing; from = nothing; plane  =  nothing;
    thickness = nothing; nearestto = nothing; inflate = 0.0;
    for apair in pairs(kwargs)
        sy, val = apair
        if sy == :box
            box = val
        elseif sy == :distance
            distance = val
        elseif sy == :from
            from = val
        elseif sy == :plane
            plane = val
        elseif sy == :thickness
            thickness = val
        elseif sy == :nearestto
            nearestto = val
        elseif sy == :inflate
            inflate = val
        end
    end

    # Did we get an inflate value
    inflatevalue = 0.0;
    if inflate != nothing
        inflatevalue = Float64(inflate);
    end

    # Initialize the output list
    outputlist = zeros(Int64, length(v)); nn = 0;


    # Process the different options
    if box != nothing
        sdim = length(v[1])
        dim = Int64(round(length(box)/2.));
        @assert dim == sdim "Dimension of box not matched to dimension of array of vertices"
        abox = vec(box)
        inflatebox!(abox, inflatevalue)
        outputlist, nn = _box_outputlist!(outputlist, abox, sdim, v) 
    elseif distance != nothing
        fromvalue =fill!(deepcopy(v[1,:]), 0.0);
        if from!=nothing
            fromvalue = from;
        end
        fromvalue = reshape(fromvalue, (size(v[1,:])))
        d=distance+inflatevalue;
        for i=1:size(v,1)
            if norm(fromvalue-v[i,:])<d
                nn =nn +1; outputlist[nn] =i;
            end
        end
    elseif plane != nothing
        normal = plane[1:end-1];
        normal = vec(normal/norm(normal));
        thicknessvalue = 0.0;
        if thickness != nothing
            thicknessvalue = thickness;
        end
        t = thicknessvalue+inflatevalue;
        distance = plane[end];
        for i = 1:size(v,1)
            ad = dot(v[i,:], normal);
            if abs(distance-ad)<t
                nn = nn +1; outputlist[nn] =i;
            end
        end
    elseif nearestto != nothing
        location = vec(nearestto);
        distance =  zeros(size(v,1));
        for i=1:size(v,1)
            distance[i] = norm(location-vec(v[i,:]))
        end
        Mv,j = findmin(distance)
        outputlist[1] = j;
        nn=1;
    end
    if (nn==0)
        outputlist = Int64[];# nothing matched
    else
        outputlist = outputlist[1:nn];
    end
    return outputlist
end


"""
    connectedv(fes::AbstractFESet)

Extract the node numbers of the nodes connected by given finite elements.

Extract the list of unique node numbers for the nodes that are connected
by the finite element set `fes`. Note that it is assumed that all the
FEs are of the same type (the same number of connected nodes by each
cell).
"""
function connectedv(ir::IncRel)
    vl = fill(zero(indextype(ir)), 0)
    for i in 1:nshapes(ir.left)
        append!(vl, retrieve(ir, i))
    end
    return unique(vl);
end
