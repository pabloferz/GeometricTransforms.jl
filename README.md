# GeometricTransforms.jl

Simple [Julia](https://julialang.org/) library, that defines some origin
centered geometric objects (`Ellipsoid`, `TruncatedSquarePyramid`, `Torus`,
among others).

The main functions here are `ftransform(f, s::Shape)`, `ptransform(s::Shape)`
and `domain(s::Shape)`. The first one maps a function `f(x, y, z)` to another
`g(λ, μ, ν) * J(λ, μ, ν)`, where `g(λ, μ, ν)` is basically `f(x(λ, μ, ν), y(λ,
μ, ν), z(λ, μ, ν))` within the volume of a shape `s` but under a change of
variables to a rectangular domain defined by `(λ, μ, ν)` and `J(λ, μ, ν)` is
the [Jacobian
determinant](https://en.wikipedia.org/wiki/Jacobian_matrix_and_determinant) of
the transformation. The limits of the domain are given by `domain(s)`.

`ptransform(s::Shape)` returns a function that maps a point `(λ, μ, ν)` on the
domain given by `domain(s)` to a tuple `(j, x, y, z)`, where `p = (x, y, z)`
corresponds to the cartesian coordinates of a point inside `s`, and `j` is the
is the Jacobian determinant of the transformation `(x, y, z) ↦ (λ, μ, ν)`
evaluated on `p`.

`ftransform(f, s)` can be used together with an integration library, *e.g.*
[NIntegration.jl](https://github.com/pabloferz/NIntegration.jl), to find out
the integral of the function `f` within the region bounded by the surface of
the shape `s`.

It also extends the `Base` method `in` to determine if a point in three
dimensions lies within the volume defined by each object.

## Installation

`GeometricTransforms.jl` should work on Julia 0.5 and later versions, and can
be installed from a Julia session by running

```julia
julia> Pkg.clone("https://github.com/pabloferz/GeometricTransforms.jl.git")
```

## Usage

Once installed, run

```julia
using GeometricTransforms
```

Let's see how the library can be used along an integration library to
approximate the volume of a sphere of radius `1`.

```julia
julia> using GeometricTransforms
julia> using BenchmarkTools

julia> Pkg.clone("https://github.com/pabloferz/NIntegration.jl.git")
julia> using NIntegration

julia> let
           r = 1.0
           S = Sphere(r)
           f = (x, y, z) -> 1.0
           integrand = (x, y, z) -> Point(x, y, z) in S
           xmin, xmax = (-r, -r, -r), (r, r, r)
           @btime nintegrate($integrand, $xmin, $xmax)
       end
  56.498 ms (752069 allocations: 16.04 MiB)
(4.189016214102217,0.1294570371126839,1000125,3938 subregions)

julia> let
           r = 1.0
           S = Sphere(r)
           f = (x, y, z) -> 1.0
           integrand = ftransform(f, S)
           xmin, xmax = domain(S)
           @btime nintegrate($integrand, $xmin, $xmax)
       end
  4.541 μs (46 allocations: 1.05 KiB)
(4.188790204114109,6.332978594815053e-7,127,1 subregion)

julia> let
           r = 1.0
           S = Sphere(r)
           f = (x, y, z) -> 1.0
           integrand = ftransform(f, S)
           xmin, xmax = domain(S)
           @btime nintegrate($integrand, $xmin, $xmax, reltol=1e-10)
       end
  62.387 μs (345 allocations: 9.31 KiB)
(4.188790204786391,7.700952182138001e-12,889,4 subregions)

julia> 4π / 3
4.1887902047863905
```

## Acknowledgements

This work was financially supported by CONACYT through grant 354884.
