# WithAlloc

<!-- [![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://ACEsuit.github.io/WithAlloc.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://ACEsuit.github.io/WithAlloc.jl/dev/) -->
[![Build Status](https://github.com/ACEsuit/WithAlloc.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/ACEsuit/WithAlloc.jl/actions/workflows/CI.yml?query=branch%3Amain)

This package implements a very small extension to [Bumper.jl](https://github.com/MasonProtter/Bumper.jl). 

### Introduction and Motivation 

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
   A = @with_alloc calculate_something!(more, args)
end
```

### Documentation

