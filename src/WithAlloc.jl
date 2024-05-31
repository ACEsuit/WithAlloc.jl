module WithAlloc

using Bumper 
export whatalloc, @withalloc1, @withalloc

function whatalloc end 

function _bumper_alloc(allocinfo::Tuple{Type, Vararg{Int, N}})  where {N} 
   (Bumper.alloc!(Bumper.default_buffer(), allocinfo... ), )
end

function _bumper_alloc(allocinfo::NTuple{N, <: Tuple}) where {N} 
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


# Teemu's original draft, slightly edited 
# macro withalloc(ex)
#    # Create symbols based on imput
#    out_obj = Symbol( "out_" * String(ex.args[2]) )
#    out_obj_info = Symbol( "out_" * String(ex.args[2]) * "_info" )

#    # Create expressions
#    # out_obj_info = whatalloc(somecalculation!, x1, x2, ...)
#    l1 = Expr(:call, :(=), out_obj_info, Expr(:call, :whatalloc, ex.args...)  )


#    # A = @alloc(out_obj_info.A...)
#    # la = Expr(:(=), :A, Expr(:macrocall, Symbol("@alloc"), Symbol("# empty #"), Expr(:..., Expr(:., out_obj_info, :(:A))) ) )

#    # B = @alloc(out_obj_info.B...)
#    # lb = Expr(:(=), :B, Expr(:macrocall, Symbol("@alloc"), Symbol("# empty #"), Expr(:..., Expr(:., out_obj_info, :(:B))) ) )

#    # out_obj = (A = @alloc(out_obj_info.A...), B = @alloc(out_obj_info.B...) )
#    l2 = Expr(:(=), out_obj, Expr(:tuple, la, lb) )
#    l3 = Expr(:call, out_obj, ex.args... )

#    # Create the final expression
#    q = quote
#       $l1
#       $l2
#       $l3
#    end
# end

end 
