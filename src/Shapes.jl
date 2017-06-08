__precompile__()

module Shapes


### Dependencies
using Compat
using Reexport

@reexport using StaticArrays

### Imports
import Base: in

### Types
@compat abstract type AbstractShape{T} <: FieldVector{T} end

immutable Cube{T} <: AbstractShape{T}
    a::T
end
Cube(t::NTuple{1}) = Cube(t[1])

immutable Sphere{T} <: AbstractShape{T}
    r::T
end
Sphere(t::NTuple{1}) = Sphere(t[1])

immutable SphericalCap{T} <: AbstractShape{T}
    a::T
    c::T
end
SphericalCap(t::NTuple{2}) = SphericalCap(t...)

immutable Parallelepiped{T} <: AbstractShape{T}
    a::T
    b::T
    c::T
    function Parallelepiped(a, b, c)
        if a ≤ 0 || b ≤ 0 || c ≤ 0
            throw(ArgumentError("All semi-lengths should be positive."))
        end
        return new(a, b, c)
    end
end
(::Type{S}){S<:Parallelepiped}(a, b, c) = (t = promote(a, b, c);
    Parallelepiped{eltype(t)}(t...))

immutable Ellipsoid{T} <: AbstractShape{T}
    a::T
    b::T
    c::T
    function Ellipsoid(a, b, c)
        if a ≤ 0 || b ≤ 0 || c ≤ 0
            throw(ArgumentError("All semi-lengths should be positive."))
        end
        return new(a, b, c)
    end
end
(::Type{S}){S<:Ellipsoid}(a, b, c) = (t = promote(a, b, c);
    Ellipsoid{eltype(t)}(t...))

immutable Cylinder{T} <: AbstractShape{T}
    r::T
    c::T
    function Cylinder(r, c)
        if r ≤ 0 || c ≤ 0
            throw(ArgumentError("All semi-lengths should be positive."))
        end
        return new(r, c)
    end
end
(::Type{S}){S<:Cylinder}(r, c) = (t = promote(r, c);
    Cylinder{eltype(t)}(t...))

immutable EllipticCylinder{T} <: AbstractShape{T}
    a::T
    b::T
    c::T
    function EllipticCylinder(a, b, c)
        if a ≤ 0 || b ≤ 0 || c ≤ 0
            throw(ArgumentError("All semi-lengths should be positive."))
        end
        return new(a, b, c)
    end
end
(::Type{S}){S<:EllipticCylinder}(a, b, c) = (t = promote(a, b, c);
    EllipticCylinder{eltype(t)}(t...))

immutable SquarePyramid{T,S} <: AbstractShape{T}
    a::T
    b::T
    m::S
    function SquarePyramid(a, b, m)
        if a ≤ 0 || b ≤ 0
            throw(ArgumentError("All semi-lengths should be positive."))
        end
        @assert m == 2b / a
        return new(a, b, m)
    end
end
(::Type{S}){S<:SquarePyramid,T}(a, b, m::T) = (t = promote(a, b);
    SquarePyramid{eltype(t),T}(t..., m))
(::Type{S}){S<:SquarePyramid}(a, b) = (t = promote(a, b); m = 2b / a;
    SquarePyramid{eltype(t),typeof(m)}(t..., m))

immutable RectangularPyramid{T,S} <: AbstractShape{T}
    a::T
    b::T
    c::T
    ma::S
    mb::S
    function RectangularPyramid(a, b, c, ma, mb)
        if a ≤ 0 || b ≤ 0 || c ≤ 0
            throw(ArgumentError("All semi-lengths should be positive."))
        end
        @assert ma == 2c / a
        @assert mb == 2c / b
        return new(a, b, c, ma, mb)
    end
end
(::Type{S}){S<:RectangularPyramid,T}(a, b, c, ma::T, mb::T) =
    (t = promote(a, b, c); SquarePyramid{eltype(t),T}(t..., ma, mb))
(::Type{S}){S<:RectangularPyramid}(a, b, c) =
    (t = promote(a, b, c); ma = 2c / a; mb = 2c / b;
     RectangularPyramid{eltype(t),typeof(ma)}(t..., ma, mb))

immutable TruncatedSquarePyramid{T,S} <: AbstractShape{T}
    a::T
    b::T
    r::Float64
    m::S
    function TruncatedSquarePyramid(a, b, r::Float64, m)
        if a ≤ 0 || b ≤ 0
            throw(ArgumentError("All semi-lengths should be positive."))
        end
        @assert 0 < r ≤ 1
        @assert m == 2b / a
        return new(a, b, r, m)
    end
end
const TSP = TruncatedSquarePyramid
(::Type{S}){S<:TSP,T}(a, b, r::Float64, m::T) = (t = promote(a, b);
    TSP{eltype(t),T}(t..., r, m))
(::Type{S}){S<:TSP}(a, b, r::Float64) = (t = promote(a, b); m = 2b / a;
    TSP{eltype(t),typeof(m)}(t..., r, m))

immutable Torus{T} <: AbstractShape{T}
    R::T
    r::T
end

immutable Vec{T} <: FieldVector{T}
    x::T
    y::T
    z::T
end
Vec(x, y, z) = Vec(promote(x, y, z)...)

const Point = Vec

### Methods
"""    in(p::Point, s::AbstractShape)

Returns `true` if the point `p` lies inside or in the boundary of `s`,
or `false` otherwise.
"""
in(p::Point, s::Sphere            ) = p.x^2 + p.y^2 + p.z^2 ≤ s.r^2

in(p::Point, s::Ellipsoid         ) = (p.x / s.a)^2 + (p.y / s.b)^2 +
                                      (p.z / s.c)^2 ≤ 1

in(p::Point, s::Cylinder          ) = (p.x^2 + p.y^2 ≤ s.r^2) &&
                                      (abs(p.z) ≤ s.c)

in(p::Point, s::EllipticCylinder  ) = (p.x / s.a)^2 + (p.y / s.b)^2 ≤ 1 &&
                                      (abs(p.z) ≤ s.c)

in(p::Point, s::Cube              ) = (abs(p.x) ≤ s.a) && (abs(p.y) ≤ s.a) &&
                                      (abs(p.z) ≤ s.a)

in(p::Point, s::Parallelepiped    ) = (abs(p.x) ≤ s.a) && (abs(p.y) ≤ s.b) &&
                                      (abs(p.z) ≤ s.c)

in(p::Point, s::SquarePyramid     ) = (p.z + s.m * abs(p.x) ≤ s.b) &&
                                      (p.z + s.m * abs(p.y) ≤ s.b) &&
                                      (abs(p.z) ≤ s.b)

in(p::Point, s::RectangularPyramid) = (p.z + s.ma * abs(p.x) ≤ s.c) &&
                                      (p.z + s.mb * abs(p.y) ≤ s.c) &&
                                      (abs(p.z) ≤ s.c)

function in(p::Point, s::TSP)
    z = s.r * s.b
    b = 2 * s.b - z
    return (p.z + s.m * abs(p.x) ≤ b) &&
           (p.z + s.m * abs(p.y) ≤ b) &&
           (abs(p.z) ≤ z)
end


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

### Utils

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

### Exports
export AbstractShape, Cube, Cylinder, Ellipsoid, EllipticCylinder,
       Parallelepiped, Point, RectangularPyramid, Sphere, SphericalCap,
       SquarePyramid, TSP, TruncatedSquarePyramid, Torus, Vec, transform,
       transform_bounds


end # Shapes
