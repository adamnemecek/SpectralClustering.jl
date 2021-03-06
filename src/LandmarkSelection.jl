export AbstractLandmarkSelection,
       LandmarkBasedRepresentation,
       RandomLandmarkSelection,
       EvenlySpacedLandmarkSelection,
      select_landmarks,
      MS3
using StatsBase
"""
```julia
abstract type AbstractLandmarkSelection end
```
Abstract type that defines how to sample data points. Types that inherint from `AbstractLandmarkSelection` has to implements the following interface:

```julia
select_landmarks{L<:AbstractLandmarkSelection}(c::L, X)
```
The `select_landmarks`function returns an array with the indices of the sampled points.
# Arguments

- ```c::T<:AbstractLandmarkSelecion```. The landmark selection type.
- ```d::D<:DataAccessor```.  The [`DataAccessor`](ref) type.
- ```X```. The data. The data to be sampled.
"""
abstract type AbstractLandmarkSelection end

"""
```
type RandomLandmarkSelection <: LandmarkSelection
```
`Random` random samples `n` data points from a dataset.

"""

type RandomLandmarkSelection <: AbstractLandmarkSelection
end
"""
```julia
select_landmarks(c::RandomLandmarkSelection,d::T,n::Integer, X)
```
The function returns `n`random points according to [`RandomLandmarkSelection`](@ref)
# Arguments
- c::RandomLandmarkSelection.
- n::Integer. The number of data points to sample.
- X. The data to be sampled.
"""
function select_landmarks(c::RandomLandmarkSelection,n::Integer, X)
  return  StatsBase.sample(1:number_of_patterns(X), n, replace = false)
end

"""
```
type EvenlySpacedLandmarkSelection <: AbstractLandmarkSelection
```
The `EvenlySpacedLandmarkSelection` selection method selects  `n` evenly spaced points  from a dataset.

"""
type EvenlySpacedLandmarkSelection  <: AbstractLandmarkSelection
end
"""
```
select_landmarks(c::EvenlySpacedLandmarkSelection,n::Integer, X)
```

"""
function select_landmarks(c::EvenlySpacedLandmarkSelection, n::Integer, X)
  m = number_of_patterns(X)
  return collect(1:round(Integer,floor(m/n)):m)
end

"""
```
type MS3 <: AbstractLandmarkSelection
    proportion::Float64
    sim::Function
end
```
The `MS3` selection method selects  `m` 
NYSTROM SAMPLING DEPENDS ON THE EIGENSPECTRUM SHAPE OF THE DATA
"""

type MS3 <: AbstractLandmarkSelection
    proportion::Float64
    sim::Function
end
function select_landmarks(c::MS3, m::Integer, X)
    local cant = number_of_patterns(X)
    local points  = [rand(1:cant); rand(1:cant)]
    while (length(points)<m)
        local T_candidates  = setdiff(1:cant, points)
        local T = rand(T_candidates, round(Integer,length(T_candidates)*c.proportion))
        local min_simmilarity = Inf
        local min_point = 0        
        for t in T
            local simmilarity = 0            
            for p in points
                simmilarity = simmilarity + c.sim(get_element(X,p), get_element(X,t))^2
            end
            if simmilarity < min_simmilarity
                min_simmilarity = simmilarity
                min_point = t
            end
        end
        push!(points, min_point)
    end
    return points    
end
