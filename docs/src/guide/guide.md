[Table of contents](https://petrkryslucsd.github.io/MeshSteward.jl/latest/index.html)

# How to Guide

- [How to create simple meshes](@ref simplemeshes)
- [How to find a particular incidence relation](@ref find)
- [How to visualize meshes](@ref visualize)
- [How to export meshes](@ref export)
- [How to import meshes](@ref import)
- [How to select entities](@ref select)

## [How to create simple meshes](@id simplemeshes)

We will generate the tetrahedral mesh inside a rectangular block.
The block will have the dimensions shown below:
```
a, b, c = 2.0, 2.5, 3.0
```
The tetrahedra will be generated in a regular pattern, with the number of
edges per side of the block given as
```
na, nb, nc = 2, 2, 3
```
Now we bring in function to generate mesh, and use it to generate the incidence relation representing the mesh.
```
using MeshSteward: T4block
conn = T4block(a, b, c, na, nb, nc);
```

The variable `conn` is an incidence relation. This will become the base
relation of the mesh. The mesh is first created.
```
using MeshSteward: Mesh
m = Mesh()
```
Then the ``(3, 0)`` incidence relation, which defines the tetrahedral elements in terms of the vertices at their corners, is attached to it.
```
using MeshSteward: attach!
attach!(m, conn);
```

We can now inspect the mesh by printing its summary.
```
println(summary(m))
```

## [How to find a particular incidence relation](@id find)

Find an incidence relation based on a code. 
The ``(3, 0)`` incidence relation, which defines the tetrahedral elements in terms of the vertices at their corners, is found like this:
```
conn = increl(m, (3, 0))
```

We can extract the boundary of this incidence relation and attach it to the mesh:
```
using MeshCore: ir_boundary
bconn = ir_boundary(conn)
```
This incidence relation than may be attached to the mesh, with a name and a code.
```
attach!(m, bconn, "boundary_triangles") 
```
To recover this incidence relation from the mesh we can do:
```
bconn = increl(m, ((2, 0), "boundary_triangles"))
```

## [How to visualize meshes](@id visualize)

The mesh can be exported for visualization. The tetrahedral elements are the
base incidence relation of the mesh.

```
using MeshSteward: baseincrel
using MeshSteward: vtkwrite
vtkwrite("trunc_cyl_shell_0-elements", baseincrel(mesh))
```

Start "Paraview", load the file `"trunc_cyl_shell_0-elements.vtu"` and
select for instance view as "Surface with Edges". The result will be a view
of the surface of the tetrahedral mesh.
```
@async run(`paraview trunc_cyl_shell_0-elements.vtu`)
```

## [How to export meshes ](@id export)
## [How to import meshes ](@id import)


## [How to select entities](@id select)

