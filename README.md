# WithAlloc

<!-- [![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://ACEsuit.github.io/WithAlloc.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://ACEsuit.github.io/WithAlloc.jl/dev/) -->
[![Build Status](https://github.com/ACEsuit/WithAlloc.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/ACEsuit/WithAlloc.jl/actions/workflows/CI.yml?query=branch%3Amain)

This package implements a very small extension to [Bumper.jl](https://github.com/MasonProtter/Bumper.jl). 

A common pattern in our own (the developers') codes is the following: 
```julia
@no_escape begin 
   # determine the type and size a required array
   T, N = determine_array(args)
   # preallocate some arrays
   A = @alloc(T, N)
   # do a computation on A 
   calculate_something!(A, args)
end 
```
After writing the same pattern 10 times, we wondered whether there is an easy way to wrap this and the result is the present package. It allows us to replace the above 3 lines with 
```julia 
@no_escape begin 
   A = @withalloc calculate_something!(more, args)
end
```

### Preliminary Documentation

For now, there is are just a few simple use-case examples.
```julia
using WithAlloc, LinearAlgebra, Bumper 

# simple allocating operation
B = randn(5,10)
C = randn(10, 3)
A1 = B * C
s1 = sum(A1)

# we wrap mul! into a new function so we don't become pirates...
mymul!(A, B, C) = mul!(A, B, C)

# tell `WithAlloc` how to allocate memory for `mymul!`
WithAlloc.whatalloc(::typeof(mymul!), B, C) = 
          (promote_type(eltype(B), eltype(C)), size(B, 1), size(C, 2))

# the "naive use" of automated pre-allocation could look like this: 
@no_escape begin 
   A2_alloc_info = WithAlloc.whatalloc(mymul!, B, C)
   A2 = @alloc(A2_alloc_info...)
   mymul!(A2, B, C)

   @show A2 ≈ A1
end

# but the same pattern will be repreated over and over so ... 
@no_escape begin 
   A3 = @withalloc mymul!(B, C)

   @show A3 ≈ A1 
end

# ------------------------------------------------------------------------

# Multiple arrays is handled via tuples: 

B = randn(5,10)
C = randn(10, 3)
D = randn(10, 5)
A1 = B * C 
A2 = B * D

mymul2!(A1, A2, B, C, D) = mul!(A1, B, C), mul!(A2, B, D)

function WithAlloc.whatalloc(::typeof(mymul2!), B, C, D) 
   T1 = promote_type(eltype(B), eltype(C)) 
   T2 = promote_type(eltype(B), eltype(D))
   return ( (T1, size(B, 1), size(C, 2)), 
            (T2, size(B, 1), size(D, 2)) )
end

@no_escape begin 
   A1b, A2b = WithAlloc.@withalloc mymul2!(B, C, D)
   @show A1 ≈ A1b, A2 ≈ A2b   # true, true 
end


``` 

This approach should become non-allocating, which we can quickly check. 
There currently seems to be a bug in `@withalloc` for more than a single allocation though. 
```julia
using WithAlloc, LinearAlgebra, Bumper, BenchmarkTools 

mymul!(A, B, C) = mul!(A, B, C)

WithAlloc.whatalloc(::typeof(mymul!), B, C) = 
          (promote_type(eltype(B), eltype(C)), size(B, 1), size(C, 2))

alloctest(B, C) = (
   @no_escape begin sum( @withalloc mymul!(B, C) ) end )

B = randn(5,10); C = randn(10, 3)
@btime alloctest($B, $C)       #   135.246 ns (0 allocations: 0 bytes)
```
