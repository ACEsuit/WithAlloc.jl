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
   A3 = @withalloc1 mymul!(B, C)

   @show A3 ≈ A1 
end

# ------------------------------------------------------------------------
# Bonus: does this become non-allocating ... we can quickly check ... 
function alloctest(B, C) 
   @no_escape begin 
      s3 = sum( @withalloc1 mymul!(B, C) )
   end
   return s3 
end 

using BenchmarkTools 
@btime alloctest($B, $C)  
# 125.284 ns (0 allocations: 0 bytes)
