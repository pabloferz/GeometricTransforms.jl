SameXYZLength = Union{Cube,Sphere}
SameXYLength  = Union{Cylinder,SphericalCap,SquarePyramid}
NoSameLength  = Union{Ellipsoid,EllipticCylinder,HemiEllipsoid,Parallelepiped,
                      RectangularPyramid}

halflengths(s::SameXYZLength   ) = Vec(s[1], s[1], s[1])
halflengths(s::SameXYLength    ) = Vec(s[1], s[1], s[2])
halflengths(s::NoSameLength    ) = Vec(s[1], s[2], s[3])
halflengths(s::HollowCylinder  ) = Vec(s[1], s[1], s[3])
halflengths(s::TSP             ) = Vec(s[1], s[1], s[2] * s[3])
halflengths(s::Torus           ) = Vec(s[1] + s[2], s[1] + s[2], s[2])
halflengths(s::TriangularToroid) = Vec(s[1] + s[2], s[1] + s[2], s[3])


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
