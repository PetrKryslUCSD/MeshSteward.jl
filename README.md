[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)
[![Build status](https://github.com/PetrKryslUCSD/MeshSteward.jl/workflows/CI/badge.svg)](https://github.com/PetrKryslUCSD/MeshSteward.jl/actions)
[![Coverage Status](https://coveralls.io/repos/github/PetrKryslUCSD/MeshSteward.jl/badge.svg?branch=master)](https://coveralls.io/github/PetrKryslUCSD/MeshSteward.jl?branch=master)
[![Latest documentation](https://img.shields.io/badge/docs-latest-blue.svg)](https://petrkryslucsd.github.io/MeshSteward.jl/dev)

# MeshSteward.jl

Manages finite element meshes powered by [`MeshCore.jl`](https://github.com/PetrKryslUCSD/MeshCore.jl).

## Installation

The package is registered: doing
```
]add MeshSteward
```
is enough. 

Depends on: [`MeshCore`](https://github.com/PetrKryslUCSD/MeshCore.jl).

## Using

The user can either use/import individual functions from `MeshSteward` like so:
```
using MeshSteward: Mesh, attach!
```
or all exported symbols maybe made available in the user's context as
```
using MeshSteward.Exports
```

## Learning

Please refer to the tutorials in the package [`MeshTutor.jl`](https://github.com/PetrKryslUCSD/MeshTutor.jl).


## News

- 07/06/2020: Exports have been added to facilitate use of the library.
- 06/17/2020: Key the stored relations with a tuple consisting of the code and a
  string tag.
- 05/26/2020: First version.
