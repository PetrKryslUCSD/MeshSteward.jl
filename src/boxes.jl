using LinearAlgebra

"""
    initbox(x::AbstractVector{T}) where {T}

Create a bounding box and initialize with a single point.
"""
function initbox(x::AbstractVector{T}) where {T}
    sdim = length(x)
    box = fill(zero(T), 2*sdim)
    for i in 1:sdim
        box[2*i-1] = box[2*i] = x[i];
    end
    return box
end

function initbox(x::AbstractMatrix{T}) where {T}
	box = initbox(x[1, :])
	return updatebox!(box, x)
end

"""
    updatebox!(box::AbstractVector{T}, x::AbstractVector{T}) where {T}

Update a box with another location, or create a new box.

If the  `box` does not have  the correct dimensions,  it is correctly sized.

`box` = bounding box
    for 1-D `box=[minx,maxx]`, or
    for 2-D `box=[minx,maxx,miny,maxy]`, or
    for 3-D `box=[minx,maxx,miny,maxy,minz,maxz]`
`x` = vector defining a point.  The `box` is expanded to include the
    supplied location `x`.  
"""
function updatebox!(box::AbstractVector{T}, x::AbstractVector{T}) where {T}
    sdim = length(x)
    for i in 1:sdim
    	box[2*i-1] = min(box[2*i-1],x[i]);
    	box[2*i]   = max(box[2*i],x[i]);
    end
    return box
end

function updatebox!(box::AbstractVector{T}, x::AbstractMatrix{T}) where {T}
    for i in 1:size(x, 1)
    	updatebox!(box, x[i, :])
    end
    return box
end

"""
    boundingbox(x::AbstractArray{T}) where {T}

Compute the bounding box of the points in `x`.

`x` = holds points, one per row.

Returns `box` = bounding box
    for 1-D `box=[minx,maxx]`, or
    for 2-D `box=[minx,maxx,miny,maxy]`, or
    for 3-D `box=[minx,maxx,miny,maxy,minz,maxz]`
"""
function boundingbox(x::AbstractArray{T}) where {T}
	box = initbox(x[1, :])
	for i in 2:size(x, 1)
		updatebox!(box, x)
	end
    return box
end

"""
    inflatebox!(box::AbstractVector{T}, inflatevalue::T) where {T}

Inflate the box by the value supplied.
"""
function inflatebox!(box::AbstractVector{T}, inflatevalue::T) where {T}
    abox = deepcopy(box)
    sdim = Int(length(box)/2);
    for i=1:sdim
        box[2*i-1] = min(abox[2*i-1],abox[2*i]) - inflatevalue;
        box[2*i]   = max(abox[2*i-1],abox[2*i]) + inflatevalue;
    end
    return box
end

"""
    inbox(box::AbstractVector{T}, x::AbstractVector{T}) where {T}

Is the given location inside the box?

- `box` = vector entries arranged as [minx,maxx,miny,maxy,minz,maxz] (or
  adjusted in an obvious way for lower space dimension).

Note: point on the boundary of the box is counted as being inside.
"""
function inbox(box::AbstractVector{T}, x::AbstractVector{T}) where {T}
    inrange(rangelo,rangehi,r) = ((r>=rangelo) && (r<=rangehi));
    sdim=length(x);
    @assert 2*sdim == length(box)
    if !inrange(box[1], box[2], x[1])
        return false # short-circuit
    end
    for i=2:sdim
        if !inrange(box[2*i-1], box[2*i], x[i])
            return false # short-circuit
        end
    end
    return true
end

function inbox(box::AbstractVector{T}, x::AbstractArray{T}) where {T}
    return inbox(box, vec(x))
end

"""
    boxesoverlap(box1::AbstractVector{T}, box2::AbstractVector{T}) where {T}

Do the given boxes overlap?
"""
function boxesoverlap(box1::AbstractVector{T}, box2::AbstractVector{T}) where {T}
    dim=Int(length(box1)/2);
    @assert 2*dim == length(box2) "Mismatched boxes"
    for i=1:dim
        if box1[2*i-1]>box2[2*i]
            return false;
        end
        if box1[2*i]<box2[2*i-1]
            return false;
        end
    end
    return  true;
end

"""
    intersectboxes(box1::AbstractVector{T}, box2::AbstractVector{T}) where {T}

Compute the intersection of two boxes.

The function returns an empty box (length(b) == 0) if the intersection is
empty; otherwise a box is returned.
"""
function intersectboxes(box1::AbstractVector{T}, box2::AbstractVector{T}) where {T}
    @assert length(box1) == length(box2) "Mismatched boxes"
    b = copy(box1)
    dim=Int(length(box1)/2);
    @assert 2*dim == length(box2) "Wrong box data"
    for i=1:dim
        lb = max(box1[2*i-1], box2[2*i-1])
        ub = min(box1[2*i], box2[2*i])
        if (ub <= lb) # intersection is empty
            return eltype(box1)[] # box of length zero signifies empty intersection
        end
        b[2*i-1] = lb
        b[2*i]   = ub
    end
    return  b;
end
