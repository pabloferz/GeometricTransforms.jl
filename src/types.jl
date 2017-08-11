#########################
#   Geometric objects   #
#########################

### Declarations
if VERSION < v"0.6.0"
    include("geomtypes-0.5.jl")
else
    include("geomtypes.jl")
end

const TSP = TruncatedSquarePyramid
const Point = Vec

### Constructors
Cylinder(r, c) = (t = promote(r, c); Cylinder{eltype(t)}(t...))

SphericalCap(a, c) = (t = promote(a, c); SphericalCap{eltype(t)}(t...))

Ellipsoid(a, b, c) = (t = promote(a, b, c); Ellipsoid{eltype(t)}(t...))

HemiEllipsoid(a, b, c) = (t = promote(a, b, c); HemiEllipsoid{eltype(t)}(t...))

Parallelepiped(a, b, c) = (t = promote(a, b, c);
    Parallelepiped{eltype(t)}(t...))

EllipticCylinder(a, b, c) = (t = promote(a, b, c);
    EllipticCylinder{eltype(t)}(t...))

HollowCylinder(R, r, c) = (t = promote(R, r, c);
    HollowCylinder{eltype(t)}(t...))

TriangularToroid(r, b, c) = (t = promote(r, b, c);
    TriangularToroid{eltype(t)}(t...))

SquarePyramid(a, b) = (t = promote(a, b); m = 2b / a;
    SquarePyramid{eltype(t),typeof(m)}(t..., m))

SquarePyramid{T}(a, b, m::T) = (t = promote(a, b);
    SquarePyramid{eltype(t),T}(t..., m))

RectangularPyramid(a, b, c) = (t = promote(a, b, c); ma = 2c / a; mb = 2c / b;
    RectangularPyramid{eltype(t),typeof(ma)}(t..., ma, mb))

RectangularPyramid{T}(a, b, c, ma::T, mb::T) = (t = promote(a, b, c);
    RectangularPyramid{eltype(t),T}(t..., ma, mb))

TSP{R}(a, b, r::R) = (t = promote(a, b); m = 2b / a;
    TSP{eltype(t),R,typeof(m)}(t..., r, m))

TSP{R,S}(a, b, r::R, m::S) = (t = promote(a, b);
    TSP{eltype(t),R,S}(t..., r, m))

Vec(x, y, z) = (t = promote(x, y, z); Vec{eltype(t)}(t...))

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

for S in (:Cube, :Cylinder, :Ellipsoid, :EllipticCylinder, :HemiEllipsoid,
          :Parallelepiped, :RectangularPyramid, :SquarePyramid,
          :TriangularToroid)

    T = Symbol(S, :PT)

    @eval begin
        immutable $T{S,W} <: AbstractPointTransform
            s::S
            w::W
        end
    end
end

for S in (:HollowCylinder, :TSP, :SphericalCap)

    T = Symbol(S, :PT)

    @eval begin
        immutable $T{S,A,W} <: AbstractPointTransform
            s::S
            a::A
            w::W
        end
    end
end

### Constructors
for S in (:Ellipsoid, :EllipticCylinder, :HemiEllipsoid, :Parallelepiped,
          :RectangularPyramid)

    T = Symbol(S, :PT)

    @eval begin
        $T(s::$S) = $T(s, s.a * s.b * s.c)
    end
end

TSPPT(s::TSP                          ) = TSPPT(s, s.b * s.r, s.a^2 * s.b * s.r)

CubePT(s::Cube                        ) = CubePT(s, s.a^3)

CylinderPT(s::Cylinder                ) = CylinderPT(s, s.c * s.r)

SquarePyramidPT(s::SquarePyramid      ) = SquarePyramidPT(s, s.a^2 * s.b)

TriangularToroidPT(s::TriangularToroid) = TriangularToroidPT(s, s.b * s.c)

SphericalCapPT(s::SphericalCap) =
    SphericalCapPT(s, 2 * (s.a / 2s.c)^2 + 2, s.c^3)

HollowCylinderPT(s::HollowCylinder) =
    HollowCylinderPT(s, s.R - s.r, s.c * (s.R - s.r))
