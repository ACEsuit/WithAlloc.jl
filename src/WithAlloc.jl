module WithAlloc

using Bumper 
export whatalloc, @withalloc

function whatalloc end 

macro withalloc(ex)
   esc_args = esc.(ex.args)
   quote
      withalloc($(esc_args...))
   end
end

@inline function withalloc(fncall, args...)
   allocinfo = whatalloc(fncall, args...)
   _genwithalloc(allocinfo, fncall, args...) 
end

@inline function _bumper_alloc(allocinfo::Tuple{<: Type, Vararg{Int, N}}) where {N}
   Bumper.alloc!(Bumper.default_buffer(), allocinfo...)
end

@inline @generated function _genwithalloc(allocinfo::TT, fncall, args...)  where {TT <: Tuple}
   code = Expr[] 
   LEN = length(TT.types) 
   if TT.types[1] <: Tuple 
      for i in 1:LEN
         push!(code, Meta.parse("tmp$i = _bumper_alloc(allocinfo[$i])"))
      end
   else 
      push!(code, Meta.parse("tmp1 = _bumper_alloc(allocinfo)"))
      LEN = 1 
   end
   push!(code, Meta.parse("fncall($(join(["tmp$i, " for i in 1:LEN])) args...)"))
   quote
      $(code...)
   end
end 


end 
