module WithAlloc

using Bumper 
export whatalloc, @withalloc

function whatalloc end 

@inline function _bumper_alloc(allocinfo::Tuple{<: Type, Vararg{Int, N}}) where {N}
   (Bumper.alloc!(Bumper.default_buffer(), allocinfo...), )
end

@inline function _bumper_alloc(allocinfo::Tuple)
   ntuple(i -> _bumper_alloc(allocinfo[i])[1], length(allocinfo))
end

macro withalloc(ex)
   fncall = esc(ex.args[1])
   args = esc.(ex.args[2:end])
   quote
      let 
         allocinfo = whatalloc($fncall, $(args...), )
         storobj = _bumper_alloc(allocinfo)
         $(fncall)(storobj..., $(args...), )
      end
   end
end


end 
