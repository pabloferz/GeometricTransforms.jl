abstract AbstractShape{T} <: FieldVector{T}

immutable Cube{T} <: AbstractShape{T}
    a::T
end

immutable Sphere{T} <: AbstractShape{T}
    r::T
end

immutable SphericalCap{T} <: AbstractShape{T}
    a::T
    c::T
    function SphericalCap(a, c)
        if a < 0 || c ≤ 0
            throw(ArgumentError("All semi-lengths should be positive."))
        end
        return new(a, c)
    end
end

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

immutable Torus{T} <: AbstractShape{T}
    R::T
    r::T
end

immutable Vec{T} <: FieldVector{T}
    x::T
    y::T
    z::T
end
