"""    transform(f, s::AbstractShape)

Maps a function `f(x, y, z)` to another `g(λ, μ, ν) * J(λ, μ, ν)`, where
`g(λ, μ, ν)` is basically `f(x(λ, μ, ν), y(λ, μ, ν), z(λ, μ, ν))` within the
volume of the shape `s` but under a change of variables to a rectangular
domain, and `J(λ, μ, ν)` is the Jacobian determinant of the transformation. The
limits of the domain are given by `transform_bounds(s)`
"""
function transform(f, s::AbstractShape)
    function g(x, y, z)
        p = Point(x, y, z)
        r = f(x, y, z)
        return ifelse(p in s, r, zero(r))
    end
    return g
end

"""    ptransform(s::AbstractShape)

Returns a function that maps a point `(λ, μ, ν)` on the domain given by
`transform_bounds(s)` to a tuple `(j, x, y, z)`, where `p = (x, y, z)`
corresponds to the cartesian coordinates of a point inside `s`, and `j` is the
is the Jacobian determinant of the transformation `(x, y, z) ↦ (λ, μ, ν)`
evaluated on `p`.
"""
function ptransform end

for S in (:Cube, :Cylinder, :Ellipsoid, :EllipticCylinder, :HemiEllipsoid,
          :HollowCylinder, :Parallelepiped, :RectangularPyramid, :Sphere,
          :SphericalCap, :SquarePyramid, :TriangularToroid, :Torus, :TSP)

    T = Symbol(S, :PT)

    @eval begin
        ptransform(s::$S) = $T(s)
        transform{F}(f::F, s::$S) = Transform(f, $T(s))
    end
end

function (T::Transform)(λ, μ, ν)
    j, x, y, z = T.p(λ, μ, ν)
    return j * T.f(x, y, z)
end

@inline function (T::SpherePT)(λ, θ, φ)
    sθ, cθ = sincos(θ)
    sφ, cφ = sincos(φ)
    r = λ * T.s.r
    rsθ = r * sθ
    j = T.s.r * r * rsθ
    x = rsθ * cφ
    y = rsθ * sφ
    z = r * cθ
    return j, x, y, z
end

@inline function (T::SphericalCapPT)(λ, φ, ν)
    sφ, cφ = sincos(φ)
    κ = 1 - ν
    μ = κ * (T.a - κ)
    k = λ * √μ
    j = T.w * λ * μ
    x = k * cφ
    y = k * sφ
    z = T.s.c * ν
    return j, x, y, z
end

@inline function (T::EllipsoidPT)(λ, θ, φ)
    sθ, cθ = sincos(θ)
    sφ, cφ = sincos(φ)
    λsθ = λ * sθ
    j = T.w * λ * λsθ
    x = λsθ * T.s.a * cφ
    y = λsθ * T.s.b * sφ
    z = λ * T.s.c * cθ
    return j, x, y, z
end

@inline function (T::HemiEllipsoidPT)(λ, θ, φ)
    sθ, cθ = sincos(θ)
    sφ, cφ = sincos(φ)
    λsθ = λ * sθ
    j = T.w * λ * λsθ
    x = T.s.a * λsθ * cφ
    y = T.s.b * λsθ * sφ
    z = T.s.c * (λ * cθ - 0.5)
    return j, x, y, z
end

@inline function (T::CylinderPT)(λ, φ, ν)
    sφ, cφ = sincos(φ)
    ρ = λ * T.s.r
    j = T.w * ρ
    x = ρ * cφ
    y = ρ * sφ
    z = ν * T.s.c
    return j, x, y, z
end

@inline function (T::HollowCylinderPT)(λ, φ, ν)
    sφ, cφ = sincos(φ)
    ρ = λ * T.a + T.s.r
    j = T.w * ρ
    x = ρ * cφ
    y = ρ * sφ
    z = ν * T.s.c
    return j, x, y, z
end

@inline function (T::TriangularToroidPT)(λ, φ, ν)
    sφ, cφ = sincos(φ)
    κ = 0.5 * (1 - ν)
    ρ = λ * κ * T.s.b + T.s.r
    j = T.w * κ * ρ
    x = ρ * cφ
    y = ρ * sφ
    z = ν * T.s.c
    return j, x, y, z
end

@inline function (T::EllipticCylinderPT)(λ, φ, ν)
    sφ, cφ = sincos(φ)
    j = T.w * λ
    x = λ * T.s.a * cφ
    y = λ * T.s.b * sφ
    z = ν * T.s.c
    return j, x, y, z
end

@inline function (T::CubePT)(λ, μ, ν)
    j = T.w
    x = T.s.a * λ
    y = T.s.a * μ
    z = T.s.a * ν
    return j, x, y, z
end

@inline function (T::ParallelepipedPT)(λ, μ, ν)
    j = T.w
    x = T.s.a * λ
    y = T.s.b * μ
    z = T.s.c * ν
    return j, x, y, z
end

@inline function (T::SquarePyramidPT)(λ, μ, ν)
    κ = 0.5 * (1 - ν)
    κa = κ * T.s.a
    j = T.w * κ^2
    x = κa * λ
    y = κa * μ
    z = T.s.b * ν
    return j, x, y, z
end

@inline function (T::RectangularPyramidPT)(λ, μ, ν)
    κ = 0.5 * (1 - ν)
    j = T.w * κ^2
    x = κ * T.s.a * λ
    y = κ * T.s.b * μ
    z = T.s.c * ν
    return j, x, y, z
end

@inline function (T::TSPPT)(λ, μ, ν)
    κ = 0.5 * (2 - T.s.r * (1 + ν))
    κa = κ * T.s.a
    j = T.w * κ^2
    x = κa * λ
    y = κa * μ
    z = T.a * ν
    return j, x, y, z
end

@inline function (T::TorusPT)(λ, θ, φ)
    sθ, cθ = sincos(θ)
    sφ, cφ = sincos(φ)
    rλ = T.s.r * λ
    ρ = rλ * cθ + T.s.R
    j = T.s.r * rλ * ρ
    x = ρ * cφ
    y = ρ * sφ
    z = rλ * sθ
    return j, x, y, z
end

### Variables domains
transform_bounds(::Sphere            ) = (( 0.0,  0.0,  0.0), (1.0,  1π,  2π))
transform_bounds(::Ellipsoid         ) = (( 0.0,  0.0,  0.0), (1.0,  1π,  2π))
transform_bounds(::HemiEllipsoid     ) = (( 0.0,  0.0,  0.0), (1.0, π/2,  2π))
transform_bounds(::Cylinder          ) = (( 0.0,  -1π, -1.0), (1.0,  1π, 1.0))
transform_bounds(::HollowCylinder    ) = (( 0.0,  -1π, -1.0), (1.0,  1π, 1.0))
transform_bounds(::EllipticCylinder  ) = (( 0.0,  -1π, -1.0), (1.0,  1π, 1.0))
transform_bounds(::TriangularToroid  ) = ((-1.0,  -1π, -1.0), (1.0,  1π, 1.0))
transform_bounds(::SphericalCap      ) = (( 0.0,  0.0, -1.0), (1.0,  2π, 1.0))
transform_bounds(::Cube              ) = ((-1.0, -1.0, -1.0), (1.0, 1.0, 1.0))
transform_bounds(::Parallelepiped    ) = ((-1.0, -1.0, -1.0), (1.0, 1.0, 1.0))
transform_bounds(::RectangularPyramid) = ((-1.0, -1.0, -1.0), (1.0, 1.0, 1.0))
transform_bounds(::SquarePyramid     ) = ((-1.0, -1.0, -1.0), (1.0, 1.0, 1.0))
transform_bounds(::TSP               ) = ((-1.0, -1.0, -1.0), (1.0, 1.0, 1.0))
transform_bounds(::Torus             ) = (( 0.0,  -1π,  -1π), (1.0,  1π,  1π))
