# Issues

- Test skeleton and boundary.

- Documenter used to generate documentation:
pkg"add DocumenterTools"  
using DocumenterTools
DocumenterTools.genkeys(user="PetrKryslUCSD", repo="git@github.com:PetrKryslUCSD/Elfel.jl.git")

and follow the instructions to install the keys.

- Export method could take just the mesh. How do we handle multiple element types in the mesh? That would mean multiple connectivity incidence relations.

- Import methods needs to be documented: outputs are incorrectly described.

- Import mesh in the .h5mesh format.
- 