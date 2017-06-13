__precompile__()

module GeometricTransforms


### Dependencies
using Compat
using Reexport

@reexport using StaticArrays

### Imports
import Base: in

### Implementation
path = dirname(realpath(@__FILE__)) # works even for symlinks
include(joinpath(path, "types.jl"))
include(joinpath(path, "utils.jl"))
include(joinpath(path, "in.jl"))
include(joinpath(path, "transforms.jl"))

### Exports
export AbstractShape, Cube, Cylinder, Ellipsoid, EllipticCylinder,
       Parallelepiped, Point, RectangularPyramid, Sphere, SphericalCap,
       SquarePyramid, TSP, TruncatedSquarePyramid, Torus, Vec, ptransform,
       transform, transform_bounds


end # module
