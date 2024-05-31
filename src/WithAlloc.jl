module WithAlloc

using Bumper 
export whatalloc, @withalloc

function whatalloc end 

@inline function _bumper_alloc(allocinfo::Tuple{<: Type, Vararg{Int, N}}) where {N}
   (Bumper.alloc!(Bumper.default_buffer(), allocinfo...), )
end

@inline function _bumper_alloc(allocinfo)
   map( a -> _bumper_alloc(a)[1], allocinfo )
end

# macro withalloc(ex)
#    fncall = esc(ex.args[1])
#    args = esc.(ex.args[2:end])
#    quote
#       # not sure why this isn't working ... 
#       # whatalloc($fncall, $(args...))
#       let 
#          allocinfo = whatalloc($fncall, $(args...), )
#          storobj = _bumper_alloc(allocinfo)
#          $(fncall)(storobj..., $(args...), )
#       end
#    end
# end

macro withalloc(ex)
   esc_args = esc.(ex.args)
   quote
      withalloc($(esc_args...))
   end
end


# For some reason that I don't understand the following implementation is allocating 
# The @generated implementation below is to get around this. 
# @inline function withalloc(fncall, args...) 
#    allocinfo = whatalloc(fncall, args..., )
#    storobj = _bumper_alloc(allocinfo)
#    fncall(storobj..., args..., )
# end 

@inline function withalloc(fncall, args...)
   allocinfo = whatalloc(fncall, args...)
   _genwithalloc(allocinfo, fncall, args...) 
end

@inline @generated function _genwithalloc(allocinfo::TT, fncall, args...)  where {TT <: Tuple}
   code = Expr[] 
   LEN = length(TT.types) 
   if TT.types[1] <: Tuple 
      for i in 1:LEN
         push!(code, Meta.parse("tmp$i = _bumper_alloc(allocinfo[$i])[1]"))
      end
   else 
      push!(code, Meta.parse("tmp1 = _bumper_alloc(allocinfo)[1]"))
      LEN = 1 
   end
   push!(code, Meta.parse("fncall($(join(["tmp$i, " for i in 1:LEN])) args...)"))
   quote
      $(code...)
   end
end 


end 
