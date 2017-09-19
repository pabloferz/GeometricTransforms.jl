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
for S in (:Ellipsoid, :EllipticCylinder, :HollowCylinder, :Parallelepiped,
          :TriangularToroid, :Vec)
    @eval begin
        $S(a, b, c) = (t = promote(a, b, c); $S{eltype(t)}(t...))
    end
end

Cylinder(r, c) = (t = promote(r, c); Cylinder{eltype(t)}(t...))

SphericalCap(a, c) = (t = promote(a, c); SphericalCap{eltype(t)}(t...))

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

#############################
#   Coordinate transforms   #
#############################

@compat abstract type ShapePointTransformation end

immutable FunctionTransformation{F,T<:ShapePointTransformation}
    f::F
    t::T
end

for S in (:Ring, :Sphere, :Torus)

    T = Symbol(S, :PT)

    @eval begin
        immutable $T{S} <: ShapePointTransformation
            s::S
        end
    end
end

for S in (:Cube, :Cylinder, :Ellipsoid, :EllipticCylinder, :Parallelepiped,
          :RectangularPyramid, :SquarePyramid, :TriangularToroid)

    T = Symbol(S, :PT)

    @eval begin
        immutable $T{S,W} <: ShapePointTransformation
            s::S
            w::W
        end
    end
end

for S in (:HollowCylinder, :TSP, :SphericalCap)

    T = Symbol(S, :PT)

    @eval begin
        immutable $T{S,A,W} <: ShapePointTransformation
            s::S
            a::A
            w::W
        end
    end
end

### Constructors
for S in (:Ellipsoid, :EllipticCylinder, :Parallelepiped, :RectangularPyramid)

    T = Symbol(S, :PT)

    @eval begin
        $T(s::$S) = $T(s, s.a * s.b * s.c)
    end
end

TSPPT(s::TSP) = TSPPT(s, s.b * s.r, s.a^2 * s.b * s.r)

CubePT(s::Cube) = CubePT(s, s.a^3)

CylinderPT(s::Cylinder) = CylinderPT(s, s.c * s.r)

SquarePyramidPT(s::SquarePyramid) = SquarePyramidPT(s, s.a^2 * s.b)

TriangularToroidPT(s::TriangularToroid) = TriangularToroidPT(s, s.b * s.c)

SphericalCapPT(s::SphericalCap) =
    SphericalCapPT(s, 2 * (s.a / 2s.c)^2 + 2, s.c^3)

HollowCylinderPT(s::HollowCylinder) =
    HollowCylinderPT(s, s.R - s.r, s.c * (s.R - s.r))
