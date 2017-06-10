### Coordinate transforms

# Types
for (S, T) in ((:AbstractShape, :AbstractShapeTransform),
               (:Sphere,        :SphereTransform       ),
               (:Torus,         :TorusTransform        ))
    @eval begin
        immutable $T{F,S} <: Function
            f::F
            s::S
        end
        transform{F}(f::F, s::$S) = $T(f, s)
    end
end

for (S, T) in ((:Ellipsoid,          :EllipsoidTransform         ),
               (:Cylinder,           :CylinderTransform          ),
               (:EllipticCylinder,   :EllipticCylinderTransform  ),
               (:Cube,               :CubeTransform              ),
               (:Parallelepiped,     :ParallelepipedTransform    ),
               (:SquarePyramid,      :SquarePyramidTransform     ),
               (:RectangularPyramid, :RectangularPyramidTransform))
    @eval begin
        immutable $T{F,S,W} <: Function
            f::F
            s::S
            w::W
        end
        transform{F}(f::F, s::$S) = $T(f, s)
    end
end

for (S, T) in ((:TSP,          :TSPTransform         ),
               (:SphericalCap, :SphericalCapTransform))
    @eval begin
        immutable $T{F,S,A,W} <: Function
            f::F
            s::S
            a::A
            w::W
        end
        transform{F}(f::F, s::$S) = $T(f, s)
    end
end

# Constructors
for (S, T) in ((:Ellipsoid,          :EllipsoidTransform         ),
               (:EllipticCylinder,   :EllipticCylinderTransform  ),
               (:RectangularPyramid, :RectangularPyramidTransform),
               (:Parallelepiped,     :ParallelepipedTransform    ))
    @eval begin
        $T{F}(f::F, s::$S) = $T(f, s, s.a * s.b * s.c)
    end
end

SphericalCapTransform{F}(f::F, s::SphericalCap) =
    SphericalCapTransform(f, s, 2 * (s.a / 2s.c)^2 + 2, s.c^3)

CylinderTransform{F}(f::F, s::Cylinder) =
    CylinderTransform(f, s, s.c * s.r)

CubeTransform{F}(f::F, s::Cube) =
    CubeTransform(f, s, s.a^3)

SquarePyramidTransform{F}(f::F, s::SquarePyramid) =
    SquarePyramidTransform(f, s, s.a^2 * s.b)

TSPTransform{F}(f::F, s::TSP) =
    TSPTransform(f, s, s.b * s.r, s.a^2 * s.b * s.r)

# Functors
function (T::AbstractShapeTransform)(x, y, z)
    p = Point(x, y, z)
    r = T.f(x, y, z)
    return ifelse(p in T.s, r, zero(r))
end

function (T::SphereTransform)(λ, θ, φ)
    sθ, cθ = sincos(θ)
    sφ, cφ = sincos(φ)
    r = λ * T.s.r
    rsθ = r * sθ
    x = rsθ * cφ
    y = rsθ * sφ
    z = r * cθ
    return T.f(x, y, z) * T.s.r * r * rsθ
end

function (T::SphericalCapTransform)(λ, φ, ν)
    sφ, cφ = sincos(φ)
    κ = 1 - ν
    μ = κ * (T.a - κ)
    k = λ * √μ
    x = k * cφ
    y = k * sφ
    z = T.s.c * ν
    return T.f(x, y, z) * T.w * λ * μ
end

function (T::EllipsoidTransform)(λ, θ, φ)
    sθ, cθ = sincos(θ)
    sφ, cφ = sincos(φ)
    λsθ = λ * sθ
    x = λsθ * T.s.a * cφ
    y = λsθ * T.s.b * sφ
    z = λ * T.s.c * cθ
    return T.f(x, y, z) * T.w * λ * λsθ
end

function (T::CylinderTransform)(λ, φ, ν)
    sφ, cφ = sincos(φ)
    ρ = λ * T.s.r
    x = ρ * cφ
    y = ρ * sφ
    z = ν * T.s.c
    return T.f(x, y, z) * T.w * ρ
end

function (T::EllipticCylinderTransform)(λ, φ, ν)
    sφ, cφ = sincos(φ)
    x = λ * T.s.a * cφ
    y = λ * T.s.b * sφ
    z = ν * T.s.c
    return T.f(x, y, z) * T.w * λ
end

function (T::CubeTransform)(λ, μ, ν)
    x = T.s.a * λ
    y = T.s.a * μ
    z = T.s.a * ν
    return T.f(x, y, z) * T.w
end

function (T::ParallelepipedTransform)(λ, μ, ν)
    x = T.s.a * λ
    y = T.s.b * μ
    z = T.s.c * ν
    return T.f(x, y, z) * T.w
end

function (T::SquarePyramidTransform)(λ, μ, ν)
    κ = (1 - ν) / 2
    κa = κ * T.s.a
    x = κa * λ
    y = κa * μ
    z = T.s.b * ν
    return T.f(x, y, z) * T.w * κ^2
end

function (T::RectangularPyramidTransform)(λ, μ, ν)
    κ = (1 - ν) / 2
    x = κ * T.s.a * λ
    y = κ * T.s.b * μ
    z = T.s.c * ν
    return T.f(x, y, z) * T.w * κ^2
end

function (T::TSPTransform)(λ, μ, ν)
    κ = (2 - T.s.r * (1 + ν)) / 2
    κa = κ * T.s.a
    x = κa * λ
    y = κa * μ
    z = T.a * ν
    return T.f(x, y, z) * T.w * κ^2
end

function (T::TorusTransform)(λ, θ, φ)
    sθ, cθ = sincos(θ)
    sφ, cφ = sincos(φ)
    rλ = T.s.r * λ
    ρ = rλ * cθ + T.s.R
    x = ρ * cφ
    y = ρ * sφ
    z = rλ * sθ
    return T.f(x, y, z) * T.s.r * rλ * ρ
end

# Variables domains
transform_bounds(::Sphere            ) = (( 0.0,  0.0,  0.0), (1.0,  1π,  2π))
transform_bounds(::Ellipsoid         ) = (( 0.0,  0.0,  0.0), (1.0,  1π,  2π))
transform_bounds(::SphericalCap      ) = (( 0.0,  0.0, -1.0), (1.0,  2π, 1.0))
transform_bounds(::Cylinder          ) = (( 0.0,  -1π, -1.0), (1.0,  1π, 1.0))
transform_bounds(::EllipticCylinder  ) = (( 0.0,  -1π, -1.0), (1.0,  1π, 1.0))
transform_bounds(::Cube              ) = ((-1.0, -1.0, -1.0), (1.0, 1.0, 1.0))
transform_bounds(::Parallelepiped    ) = ((-1.0, -1.0, -1.0), (1.0, 1.0, 1.0))
transform_bounds(::RectangularPyramid) = ((-1.0, -1.0, -1.0), (1.0, 1.0, 1.0))
transform_bounds(::SquarePyramid     ) = ((-1.0, -1.0, -1.0), (1.0, 1.0, 1.0))
transform_bounds(::TSP               ) = ((-1.0, -1.0, -1.0), (1.0, 1.0, 1.0))
transform_bounds(::Torus             ) = (( 0.0,  -1π,  -1π), (1.0,  1π,  1π))
