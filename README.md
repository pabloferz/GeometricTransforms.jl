# Shapes.jl

Simple [Julia](https://julialang.org/) library, that defines some origin
centered geometric objects (`Ellipsoid`, `TruncatedSquarePyramid`, `Torus`,
among others).

It extends the `Base` method `in` to determine if a point in three dimensions
lies within the volume defined by each object.

Another pair of useful functions here are `transform(f, s::AbstractShape)` and 
`transform_bounds(s::AbstractShape)`. The first one maps a function `f(x, y, z)`
to another `g(λ, μ, ν) * J(λ, μ, ν)`, where `g(λ, μ, ν)` is basically
`f(x, y, z)` within the volume of a shape `s` but under a change of variables to
the rectangular domain defined by `(λ, μ, ν)` (the limits of the domain are
given by `transform_bounds(s)`) and `J(λ, μ, ν)` is the
[Jacobian determinant](https://en.wikipedia.org/wiki/Jacobian_matrix_and_determinant)
of the transformation.

`transform(f, s)` can be used together with an integration library, *e.g.*
[NIntegration.jl](https://github.com/pabloferz/NIntegration.jl), to find out the
integral of the function `f` within the region bounded by the surface of the
shape `s`.
