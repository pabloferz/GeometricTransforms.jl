# GeometricTransforms.jl

Simple [Julia](https://julialang.org/) library, that defines some origin
centered geometric objects (`Ellipsoid`, `TruncatedSquarePyramid`, `Torus`,
among others).

The main functions here are `transform(f, s::AbstractShape)` and 
`transform_bounds(s::AbstractShape)`. The first one maps a function `f(x, y, z)`
to another `g(λ, μ, ν) * J(λ, μ, ν)`, where `g(λ, μ, ν)` is basically
`f(x, y, z)` within the volume of a shape `s` but under a change of variables to
a rectangular domain defined by `(λ, μ, ν)` (the limits of the domain are
given by `transform_bounds(s)`) and `J(λ, μ, ν)` is the
[Jacobian determinant](https://en.wikipedia.org/wiki/Jacobian_matrix_and_determinant)
of the transformation.

`transform(f, s)` can be used together with an integration library, *e.g.*
[NIntegration.jl](https://github.com/pabloferz/NIntegration.jl), to find out the
integral of the function `f` within the region bounded by the surface of the
shape `s`.

It also extends the `Base` method `in` to determine if a point in three dimensions
lies within the volume defined by each object.

## Installation

`Shapes.jl` works only on Julia 0.5 and can be installed from a Julia session by running

```julia
julia> Pkg.clone("https://github.com/pabloferz/Shapes.jl.git")
```

## Usage

Once installed, run

```julia
using Shapes
```

Let's see how the library can be used along an integration library to approximate the volume of a sphere of radius `1`.

```julia
julia> using Shapes
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
           integrand = transform(f, S)
           xmin, xmax = transform_bounds(S)
           @btime nintegrate($integrand, $xmin, $xmax)
       end
  4.541 μs (46 allocations: 1.05 KiB)
(4.188790204114109,6.332978594815053e-7,127,1 subregion)

julia> let
           r = 1.0
           S = Sphere(r)
           f = (x, y, z) -> 1.0
           integrand = transform(f, S)
           xmin, xmax = transform_bounds(S)
           @btime nintegrate($integrand, $xmin, $xmax, reltol=1e-10)
       end
  62.387 μs (345 allocations: 9.31 KiB)
(4.188790204786391,7.700952182138001e-12,889,4 subregions)

julia> 4π / 3
4.1887902047863905
```

**TODO**

- [ ] Add more shapes and transforms
- [ ] Make it work on julia 0.6
