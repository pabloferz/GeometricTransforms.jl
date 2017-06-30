abstract type AbstractShape{N,T} <: FieldVector{N,T} end

struct Cube{T} <: AbstractShape{3,T}
    a::T
end

struct Sphere{T} <: AbstractShape{3,T}
    r::T
end

struct SphericalCap{T} <: AbstractShape{3,T}
    a::T
    c::T
    function SphericalCap{T}(a, c) where {T}
        if a < 0 || c ≤ 0
            throw(ArgumentError("All semi-lengths should be positive."))
        end
        return new(a, c)
    end
end

struct Parallelepiped{T} <: AbstractShape{3,T}
    a::T
    b::T
    c::T
    function Parallelepiped{T}(a, b, c) where {T}
        if a ≤ 0 || b ≤ 0 || c ≤ 0
            throw(ArgumentError("All semi-lengths should be positive."))
        end
        return new(a, b, c)
    end
end

struct Ellipsoid{T} <: AbstractShape{3,T}
    a::T
    b::T
    c::T
    function Ellipsoid{T}(a, b, c) where {T}
        if a ≤ 0 || b ≤ 0 || c ≤ 0
            throw(ArgumentError("All semi-lengths should be positive."))
        end
        return new(a, b, c)
    end
end

struct Cylinder{T} <: AbstractShape{3,T}
    r::T
    c::T
    function Cylinder{T}(r, c) where {T}
        if r ≤ 0 || c ≤ 0
            throw(ArgumentError("All semi-lengths should be positive."))
        end
        return new(r, c)
    end
end

struct EllipticCylinder{T} <: AbstractShape{3,T}
    a::T
    b::T
    c::T
    function EllipticCylinder{T}(a, b, c) where {T}
        if a ≤ 0 || b ≤ 0 || c ≤ 0
            throw(ArgumentError("All semi-lengths should be positive."))
        end
        return new(a, b, c)
    end
end

struct SquarePyramid{T,S} <: AbstractShape{3,T}
    a::T
    b::T
    m::S
    function SquarePyramid{T,S}(a, b, m) where {T,S}
        if a ≤ 0 || b ≤ 0
            throw(ArgumentError("All semi-lengths should be positive."))
        end
        @assert m == 2b / a
        return new(a, b, m)
    end
end

struct RectangularPyramid{T,S} <: AbstractShape{3,T}
    a::T
    b::T
    c::T
    ma::S
    mb::S
    function RectangularPyramid{T,S}(a, b, c, ma, mb) where {T,S}
        if a ≤ 0 || b ≤ 0 || c ≤ 0
            throw(ArgumentError("All semi-lengths should be positive."))
        end
        @assert ma == 2c / a
        @assert mb == 2c / b
        return new(a, b, c, ma, mb)
    end
end

struct TruncatedSquarePyramid{T,S} <: AbstractShape{3,T}
    a::T
    b::T
    r::Float64
    m::S
    function TruncatedSquarePyramid{T,S}(a, b, r::Float64, m) where {T,S}
        if a ≤ 0 || b ≤ 0
            throw(ArgumentError("All semi-lengths should be positive."))
        end
        @assert 0 < r ≤ 1
        @assert m == 2b / a
        return new(a, b, r, m)
    end
end

struct Torus{T} <: AbstractShape{3,T}
    R::T
    r::T
end

struct Vec{T} <: FieldVector{3,T}
    x::T
    y::T
    z::T
end
