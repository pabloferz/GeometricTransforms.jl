# Fast sincos function for Julia 0.5
# (see https://github.com/JuliaLang/julia/pull/21589)
@inline function sincos(v::Float64)
    return Base.llvmcall("""
        %f = bitcast i8 *%1 to void (double, double *, double *)*
        %ps = alloca double
        %pc = alloca double
        call void %f(double %0, double *%ps, double *%pc)
        %s = load double, double* %ps
        %c = load double, double* %pc
        %res0 = insertvalue [2 x double] undef, double %s, 0
        %res = insertvalue [2 x double] %res0, double %c, 1
        ret [2 x double] %res
        """, Tuple{Float64,Float64}, Tuple{Float64,Ptr{Void}}, v,
        cglobal((:sincos, Base.Math.libm)))
end

sincos(v::Real) = ( (r, i) = reim(cis(v)); (i, r) )
