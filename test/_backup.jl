# Teemu's original draft, slightly edited 
#   we keep this around since it gives a hint how the interface can be 
#   extended to support named tuples. 
#
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
