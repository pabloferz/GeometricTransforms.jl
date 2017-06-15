#########################
#   Geometric objects   #
#########################

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
SphericalCap(t::NTuple{2}) = SphericalCap(promote(t[1], t[2])...)

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

#############################
#   Coordinate transforms   #
#############################

@compat abstract type AbstractPointTransform <: Function end

immutable Transform{F,PT<:AbstractPointTransform} <: Function
    f::F
    p::PT
end

for S in (:Sphere, :Torus)

    T = Symbol(S, :PT)

    @eval begin
        immutable $T{S} <: AbstractPointTransform
            s::S
        end
    end
end

for S in (:Cube, :Cylinder, :Ellipsoid, :EllipticCylinder, :Parallelepiped,
          :RectangularPyramid, :SquarePyramid)

    T = Symbol(S, :PT)

    @eval begin
        immutable $T{S,W} <: AbstractPointTransform
            s::S
            w::W
        end
    end
end

for S in (:TSP, :SphericalCap)

    T = Symbol(S, :PT)

    @eval begin
        immutable $T{S,A,W} <: AbstractPointTransform
            s::S
            a::A
            w::W
        end
    end
end

# Constructors
for S in (:Ellipsoid, :EllipticCylinder, :Parallelepiped, :RectangularPyramid)

    T = Symbol(S, :PT)

    @eval begin
        $T(s::$S) = $T(s, s.a * s.b * s.c)
    end
end

TSPPT(s::TSP                    ) = TSPPT(s, s.b * s.r, s.a^2 * s.b * s.r)
CubePT(s::Cube                  ) = CubePT(s, s.a^3)
CylinderPT(s::Cylinder          ) = CylinderPT(s, s.c * s.r)
SphericalCapPT(s::SphericalCap  ) = SphericalCapPT(s, 2(s.a / 2s.c)^2 + 2, s.c^3)
SquarePyramidPT(s::SquarePyramid) = SquarePyramidPT(s, s.a^2 * s.b)
