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

@no_escape begin 
   A4 = WithAlloc.withalloc(mymul!, B, C)
   @show A4 ≈ A1 
   s4 = sum(A4) 
end
@test s4 ≈ s1

## allocation test 

alloctest(B, C) = (@no_escape begin sum( @withalloc mymul!(B, C) ); end)
alloctest_nm(B, C) = (@no_escape begin sum( WithAlloc.withalloc(mymul!, B, C) ); end)

nalloc = let    
   B = randn(5,10); C = randn(10, 3)
   @allocated alloctest(B, C)
end
@test nalloc == 0

nalloc_nm = let    
   B = randn(5,10); C = randn(10, 3)
   @allocated alloctest_nm(B, C)
end
@test nalloc_nm == 0
   
## 

# multiple allocations 

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
   A1b, A2b = @withalloc mymul2!(B, C, D)
   @show A1 ≈ A1b
   @show A2 ≈ A2b
   sb = sum(A1b) + sum(A2b)
end

@no_escape begin 
   A1c, A2c = WithAlloc.withalloc(mymul2!, B, C, D)
   @show A1 ≈ A1c
   @show A2 ≈ A2c
   sc = sum(A1b) + sum(A2b)
end

@test sc ≈ s

## allocation test

alloctest2(B, C, D) = 
         (@no_escape begin sum(sum.( @withalloc mymul2!(B, C, D) )); end)

alloctest2_nm(B, C, D) = 
         (@no_escape begin sum(sum.( WithAlloc.withalloc(mymul2!, B, C, D) )); end)

nalloc2 = let    
   B = randn(5,10); C = randn(10, 3); D = randn(10, 5)
   @allocated alloctest2(B, C, D)
end
@show nalloc2  # 64

nalloc2_nm = let    
   B = randn(5,10); C = randn(10, 3); D = randn(10, 5)
   @allocated alloctest2_nm(B, C, D)
end
@show nalloc2_nm  # 64



##
# multiple allocations of different type 

B = randn(5,10)
C = randn(10, 3)
D = randn(3)
A1 = B * C 
A2 = A1 * D 
s = sum(A1) + sum(A2)

function mymul3!(A1, A2, B, C, D)
   mul!(A1, B, C)
   mul!(A2, A1, D)
   return A1, A2 
end

function WithAlloc.whatalloc(::typeof(mymul3!), B, C, D) 
   T1 = promote_type(eltype(B), eltype(C)) 
   T2 = promote_type(T1, eltype(D))
   return ( (T1, size(B, 1), size(C, 2)), 
            (T2, size(B, 1)) )
end


@no_escape begin 
   A1b, A2b = WithAlloc.@withalloc mymul3!(B, C, D)
   @show A1 ≈ A1b
   @show A2 ≈ A2b
   sb = sum(A1b) + sum(A2b)
end

@test sb ≈ s

## allocation test

alloctest3(B, C, D) = 
      (@no_escape begin sum(sum.( @withalloc mymul3!(B, C, D) )); end)

nalloc3 = let    
   B = randn(5,10)
   C = randn(10, 3)
   D = randn(10, 5)
   @allocated alloctest2(B, C, D)
end

@show nalloc3   # 64


