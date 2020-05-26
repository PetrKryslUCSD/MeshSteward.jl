using LinearAlgebra: norm

"""
linearspace(start, stop, N) 

Generate linear space.

Generate a linear sequence of `N` numbers between  `start` and `stop` (i. e.
sequence  of number with uniform intervals inbetween).

# Example
```
julia> linearspace(2.0, 3.0, 5)
2.0:0.25:3.0
```
"""
function linearspace(start, stop, N) 
    return collect(range(Float64(start), stop = Float64(stop), length = Int64(N)))
end

"""
gradedspace(start, stop, N, strength=2)

Generate graded space.

Generate a graded sequence of `N` numbers between `start` and `stop`. This
sequence corresponds to separation of adjacent numbers that increases in 
proportion corresponding to the power coefficient `strength`
from start to finish.

# Example
```
julia> gradedspace(2.0, 3.0, 5)
5-element Array{Float64,1}:
2.0
2.0625
2.25
2.5625
3.0
```
"""
function gradedspace(start, stop, N, strength=2)
    N = Int64(N)
    x = range(0.0, stop = 1.0, length = N);
    x = x.^strength
    # for i = 1:strength
    #     x = cumsum(x);
    # end
    x = x./maximum(x);
    out = Float64(start) .* (1.0 .- x) .+ Float64(stop) .* x;
end
