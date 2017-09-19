abstract Shape{T} <: FieldVector{T}

immutable Cube{T} <: Shape{T}
    a::T
end

immutable Sphere{T} <: Shape{T}
    r::T
end

immutable SphericalCap{T} <: Shape{T}
    a::T
    c::T
    function SphericalCap(a, c)
        if a < 0 || c ≤ 0
            throw(ArgumentError("All lengths should be positive."))
        end
        return new(a, c)
    end
end

for shape in (:Ellipsoid, :EllipticCylinder, :Parallelepiped)
    @eval begin
        immutable $shape{T} <: Shape{T}
            a::T
            b::T
            c::T
            function $shape(a, b, c)
                if a ≤ 0 || b ≤ 0 || c ≤ 0
                    throw(ArgumentError("All lengths should be positive."))
                end
                return new(a, b, c)
            end
        end
    end
end

immutable Cylinder{T} <: Shape{T}
    r::T
    c::T
    function Cylinder(r, c)
        if r ≤ 0 || c ≤ 0
            throw(ArgumentError("All lengths should be positive."))
        end
        return new(r, c)
    end
end

immutable HollowCylinder{T} <: Shape{T}
    R::T
    r::T
    c::T
    function HollowCylinder(R, r, c)
        if r < 0 || c ≤ 0
            throw(ArgumentError("All lengths should be positive."))
        elseif R < r
            throw(ArgumentError("Outer radius `R` should be larger than `r`."))
        end
        return new(R, r, c)
    end
end

immutable SquarePyramid{T,S} <: Shape{T}
    a::T
    b::T
    m::S
    function SquarePyramid(a, b, m)
        if a ≤ 0 || b ≤ 0
            throw(ArgumentError("All lengths should be positive."))
        end
        @assert m == 2b / a
        return new(a, b, m)
    end
end

immutable RectangularPyramid{T,S} <: Shape{T}
    a::T
    b::T
    c::T
    ma::S
    mb::S
    function RectangularPyramid(a, b, c, ma, mb)
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
    function TriangularToroid(r, b, c)
        if r ≤ 0 || b ≤ 0 || c ≤ 0
            throw(ArgumentError("All lengths should be positive."))
        elseif r < b
            throw(ArgumentError("The radius must be equal or higher than " *
                                "the triangle base semi-length"))
        end
        return new(r, b, c)
    end
end

immutable TruncatedSquarePyramid{T,R,S} <: Shape{T}
    a::T
    b::T
    r::R
    m::S
    function TruncatedSquarePyramid(a, b, r, m)
        if a ≤ 0 || b ≤ 0
            throw(ArgumentError("All lengths should be positive."))
        end
        @assert 0 < r ≤ 1
        @assert m == 2b / a
        return new(a, b, r, m)
    end
end

immutable Ring{T} <: Shape{T}
    R::T
    a::T
    b::T
end

immutable Torus{T} <: Shape{T}
    R::T
    r::T
end

immutable Vec{T} <: FieldVector{T}
    x::T
    y::T
    z::T
end
