using LinearAlgebra: norm, dot, cross
using Statistics: mean
using MeshCore: IncRel, indextype, nshapes

"""
    selectnode(fens::FENodeSet; kwargs...)

Select nodes using some criterion.

# Arguments
- `v` = array of locations, one location per row
- `kwargs` = pairs of keyword argument/value

# Selection criteria:

## Distance from point

```
list = selectnode(fens.xyz, distance=1.0+0.1/2^nref, from=[0. 0.],
        inflate=tolerance);
```

## Distance from a plane

```
candidates = selectnode(fens, plane = [0.0 0.0 1.0 0.0], thickness = h/1000)
```
The keyword `plane` defines the plane by its normal (the first two or
three numbers) and its distance from the origin (the last number). Nodes
are selected they lie on the plane,  or near the plane within the
distance `thickness` from the plane. The normal is assumed to be of unit
length, if it isn't apply as such, it will be normalized internally.

## Nearest-to a point

Find the node nearest to the location given.
```
nh = selectnode(fens, nearestto = [R+Ro/2, 0.0, 0.0] )
```
"""



function _box_outputlist!(outputlist::Vector{IT}, abox::BT, sdim::IT, v::VT) where {IT, BT, VT}
    # Helper functions
    @inline inrange(rangelo,rangehi,x) = (rangelo <= x <= rangehi)
    nn = 0
    for j in eachindex(v)
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

function _distance_outputlist!(outputlist::Vector{IT}, d, fromvalue, sdim::IT, v::VT) where {IT, VT}
    # Helper functions
    nn = 0
    for j in eachindex(v)
        if norm(fromvalue-v[j]) < d
            nn = nn + 1; outputlist[nn] = j;
        end
    end
    return outputlist, nn
end

function _plane_outputlist!(outputlist::Vector{IT}, distance, normal, t, sdim::IT, v::VT) where {IT, VT}
    # Helper functions
    nn = 0
    for j in eachindex(v)
        ad = dot(v[j], normal);
        if abs(distance-ad)<t
            nn = nn + 1; outputlist[nn] = j;
        end
    end
    return outputlist, nn
end

function _nearestto_outputlist!(outputlist::Vector{IT}, nearestto, sdim::IT, v::VT) where {IT, VT}
    distances =  fill(0.0, length(v));
    for j in eachindex(v)
        distances[j] = norm(nearestto-v[j])
    end
    Mv,j = findmin(distances)
    return [j], 1
end

"""
    vselect(v::VT; kwargs...) where {VT}

Select locations (vertices) based on some criterion.

`VT` is an abstract array that returns the coordinates of a vertex given its
number.

## Selection criteria

### box
```
nLx = vselect(v, box = [0.0 Lx  0.0 0.0 0.0 0.0], inflate = Lx/1.0e5)
```

The keyword 'inflate' may be used to increase or decrease the extent of
the box (or the distance) to make sure some nodes which would be on the
boundary are either excluded or included.

### distance
```
list = vselect(v, distance=1.0+0.1/2^nref, from=[0. 0.], inflate=tolerance);
```

### plane
```
candidates = vselect(v, plane = [0.0 0.0 1.0 0.0], thickness = h/1000)
```
The keyword `plane` defines the plane by its normal (the first two or
three numbers) and its distance from the origin (the last number). Nodes
are selected they lie on the plane,  or near the plane within the
distance `thickness` from the plane. The normal is assumed to be of unit
length, if it isn't provided as such, it will be normalized internally.

### nearestto
Find the node nearest to the location given.
```
nh = vselect(v, nearestto = [R+Ro/2, 0.0, 0.0])
```

# Returns
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

    sdim = length(v[1])
    # Process the different options
    if box != nothing
        dim = Int64(round(length(box)/2.));
        @assert dim == sdim "Dimension of box not matched to dimension of array of vertices"
        abox = vec(box)
        inflatebox!(abox, inflatevalue)
        outputlist, nn = _box_outputlist!(outputlist, abox, sdim, v) 
    elseif distance != nothing
        fromvalue = fill(0.0, sdim);
        if from != nothing
            fromvalue = from;
        end
        d = distance+inflatevalue;
        outputlist, nn = _distance_outputlist!(outputlist, d, fromvalue, sdim, v) 
    elseif plane != nothing
        normal = plane[1:end-1];
        normal = vec(normal/norm(normal));
        thicknessvalue = 0.0;
        if thickness != nothing
            thicknessvalue = thickness;
        end
        t = thicknessvalue+inflatevalue;
        distance = plane[end];
        outputlist, nn = _plane_outputlist!(outputlist, distance, normal, t, sdim, v)
    elseif nearestto != nothing
        nearestto = vec(nearestto);
        outputlist, nn = _nearestto_outputlist!(outputlist, nearestto, sdim, v)
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
        append!(vl, ir[i])
    end
    return unique(vl);
end
