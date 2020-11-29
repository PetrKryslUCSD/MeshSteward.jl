[Table of contents](https://petrkryslucsd.github.io/MeshSteward.jl/latest/index.html)

# How to Guide

## How to create simple meshes

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

## How to visualize meshes

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

## How to export and import meshes

## How to manipulate topology

## How to select entities

