[Table of contents](https://petrkryslucsd.github.io/MeshEssentials.jl/latest/index.html)

# Guide

Let us introduce a simple example of the use of the library:

First import the mesh from a file and check that the correct number of entities
were imported.
```
using MeshCore: skeleton, nvertices, nshapes
using MeshPorter: import_NASTRAN, vtkwrite
mesh = import_NASTRAN("trunc_cyl_shell_0.nas")
vertices, shapes = mesh["vertices"], mesh["shapes"][1]
(nvertices(vertices), nshapes(shapes)) == (376, 996)
```
Extract zero-dimensional entities (points) by a triple application of the
`skeleton` function. Check that the number of shapes is equal to the number of
the vertices (in this particular skeleton they correspond one-to-one).
```
bshapes = skeleton(skeleton(skeleton(shapes)))
(nvertices(vertices), nshapes(bshapes)) == (376, 376)
```
Export the mesh for visualization.
```
vtkwrite("trunc_cyl_shell_0-boundary-skeleton", vertices, bshapes)
```
