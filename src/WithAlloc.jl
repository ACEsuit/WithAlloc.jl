module WithAlloc

using Bumper 
export whatalloc, @withalloc1, @withalloc

function whatalloc end 

@inline function _bumper_alloc(allocinfo::Tuple)
   (Bumper.alloc!(Bumper.default_buffer(), allocinfo... ), )
end

@inline function _bumper_alloc(allocinfo::NTuple{N, <: Tuple}) where {N} 
   ntuple(i -> Bumper.alloc!(Bumper.default_buffer(), allocinfo[i]...), N)
end

macro withalloc1(ex)
   fncall = esc(ex.args[1])
   args = esc.(ex.args[2:end])
   quote
      let 
         allocinfo = whatalloc($fncall, $(args...), )
         storobj = Bumper.alloc!(Bumper.default_buffer(), allocinfo... )
         $(fncall)(storobj, $(args...), )
      end
   end
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
