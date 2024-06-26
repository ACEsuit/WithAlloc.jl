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
# (this is essentially the code that the macro generates)
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



# ------------------------------------------------------------------------
# Bonus: does this become non-allocating ... we can quickly check ... 

using WithAlloc, LinearAlgebra, Bumper 

mymul!(A, B, C) = mul!(A, B, C)

WithAlloc.whatalloc(::typeof(mymul!), B, C) = 
          (promote_type(eltype(B), eltype(C)), size(B, 1), size(C, 2))

nalloc = let B = randn(5,10), C = randn(10, 3)
   @allocated sum( @withalloc mymul!(B, C) )
end          

@show nalloc