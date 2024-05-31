using WithAlloc, Bumper, Test, LinearAlgebra

# @testset "WithAlloc.jl" begin
# end


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
@show s2 ≈ s1 

@no_escape begin 
   A3 = WithAlloc.@withalloc_let mymul!(B, C)

   @show A3 ≈ A1 
   s3 = sum(A3) 
end
@show s3 ≈ s1
   
