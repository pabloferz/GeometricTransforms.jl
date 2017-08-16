abstract type Shape{N,T} <: FieldVector{N,T} end

struct Cube{T} <: Shape{3,T}
    a::T
end

struct Sphere{T} <: Shape{3,T}
    r::T
end

struct SphericalCap{T} <: Shape{3,T}
    a::T
    c::T
    function SphericalCap{T}(a, c) where {T}
        if a < 0 || c ≤ 0
            throw(ArgumentError("All lengths should be positive."))
        end
        return new(a, c)
    end
end

for shape in (:Ellipsoid, :EllipticCylinder, :Parallelepiped)
    @eval begin
        struct $shape{T} <: Shape{3,T}
            a::T
            b::T
            c::T
            function $shape{T}(a, b, c) where {T}
                if a ≤ 0 || b ≤ 0 || c ≤ 0
                    throw(ArgumentError("All lengths should be positive."))
                end
                return new(a, b, c)
            end
        end
    end
end

struct Cylinder{T} <: Shape{3,T}
    r::T
    c::T
    function Cylinder{T}(r, c) where {T}
        if r ≤ 0 || c ≤ 0
            throw(ArgumentError("All lengths should be positive."))
        end
        return new(r, c)
    end
end

struct HollowCylinder{T} <: Shape{3,T}
    R::T
    r::T
    c::T
    function HollowCylinder{T}(R, r, c) where {T}
        if r < 0 || c ≤ 0
            throw(ArgumentError("All lengths should be positive."))
        elseif R < r
            throw(ArgumentError("Outer radius `R` should be larger than `r`."))
        end
        return new(R, r, c)
    end
end

struct SquarePyramid{T,S} <: Shape{3,T}
    a::T
    b::T
    m::S
    function SquarePyramid{T,S}(a, b, m) where {T,S}
        if a ≤ 0 || b ≤ 0
            throw(ArgumentError("All lengths should be positive."))
        end
        @assert m == 2b / a
        return new(a, b, m)
    end
end

struct RectangularPyramid{T,S} <: Shape{3,T}
    a::T
    b::T
    c::T
    ma::S
    mb::S
    function RectangularPyramid{T,S}(a, b, c, ma, mb) where {T,S}
        if a ≤ 0 || b ≤ 0 || c ≤ 0
            throw(ArgumentError("All lengths should be positive."))
        end
        @assert ma == 2c / a
        @assert mb == 2c / b
        return new(a, b, c, ma, mb)
    end
end

immutable TriangularToroid{T} <: Shape{T}
    r::T
    b::T
    c::T
    function TriangularToroid{T}(r, b, c) where {T}
        if r ≤ 0 || b ≤ 0 || c ≤ 0
            throw(ArgumentError("All lengths should be positive."))
        elseif r < b
            throw(ArgumentError("The radius must be equal or higher than " *
                                "the triangle base semi-length"))
        end
        return new(r, b, c)
    end
end

struct TruncatedSquarePyramid{T,R,S} <: Shape{3,T}
    a::T
    b::T
    r::R
    m::S
    function TruncatedSquarePyramid{T,R,S}(a, b, r, m) where {T,R,S}
        if a ≤ 0 || b ≤ 0
            throw(ArgumentError("All semi-lengths should be positive."))
        end
        @assert 0 < r ≤ 1
        @assert m == 2b / a
        return new(a, b, r, m)
    end
end

struct Torus{T} <: Shape{3,T}
    R::T
    r::T
end

struct Vec{T} <: FieldVector{3,T}
    x::T
    y::T
    z::T
end
