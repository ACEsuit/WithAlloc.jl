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

macro withalloc(ex)
   fncall = esc(ex.args[1])
   args = esc.(ex.args[2:end])
   quote
      # not sure why this isn't working ... 
      # whatalloc($fncall, $(args...))
      let 
         allocinfo = whatalloc($fncall, $(args...), )
         storobj = _bumper_alloc(allocinfo)
         $(fncall)(storobj..., $(args...), )
      end
   end
end


@inline function withalloc(fncall, args...) 
   allocinfo = whatalloc(fncall, args..., )
   storobj = _bumper_alloc(allocinfo)
   fncall(storobj..., args..., )
end 


end 
