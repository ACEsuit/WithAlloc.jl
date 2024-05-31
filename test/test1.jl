using WithAlloc, Bumper, Test, LinearAlgebra

##

function mymul!(A, B, C) 
   mul!(A, B, C)
end

function WithAlloc.whatalloc(::typeof(mymul!), B, C) 
   T = promote_type(eltype(B), eltype(C))
   return (T, size(B, 1), size(C, 2))
end

B = randn(5,10)
C = randn(10, 3)
A1 = B * C
s1 = sum(A1)

@no_escape begin 
   A2_alloc_info = WithAlloc.whatalloc(mymul!, B, C)
   A2 = @alloc(A2_alloc_info...)
   mymul!(A2, B, C)
   @show A2 ≈ A1
   s2 = sum(A2)
end
@test s2 ≈ s1 

@no_escape begin 
   A3 = WithAlloc.@withalloc mymul!(B, C)
   @show A3 ≈ A1 
   s3 = sum(A3) 
end
@test s3 ≈ s1

## allocation test 

alloctest(B, C) = (@no_escape begin sum( @withalloc mymul!(B, C) ); end)

nalloc = let    
   B = randn(5,10)
   C = randn(10, 3)
   @allocated alloctest(B, C)
end

@test nalloc == 0

   
## 

B = randn(5,10)
C = randn(10, 3)
D = randn(10, 5)
A1 = B * C 
A2 = B * D
s = sum(A1) + sum(A2)

function mymul2!(A1, A2, B, C, D)
   mul!(A1, B, C)
   mul!(A2, B, D)
   return A1, A2 
end

function WithAlloc.whatalloc(::typeof(mymul2!), B, C, D) 
   T1 = promote_type(eltype(B), eltype(C)) 
   T2 = promote_type(eltype(B), eltype(D))
   return ( (T1, size(B, 1), size(C, 2)), 
            (T2, size(B, 1), size(D, 2)) )
end


@no_escape begin 
   A1b, A2b = WithAlloc.@withalloc mymul2!(B, C, D)
   @show A1 ≈ A1b
   @show A2 ≈ A2b
   sb = sum(A1b) + sum(A2b)
end

@test sb ≈ s

## allocation test

alloctest2(B, C, D) = 
         (@no_escape begin sum(sum.( @withalloc mymul2!(B, C, D) )); end)

nalloc2 = let    
   B = randn(5,10)
   C = randn(10, 3)
   D = randn(10, 5)
   @allocated alloctest2(B, C, D)
end

@show nalloc2
