var documenterSearchIndex = {"docs":
[{"location":"guide/guide.html#","page":"Guide","title":"Guide","text":"Table of contents","category":"page"},{"location":"guide/guide.html#Guide-1","page":"Guide","title":"Guide","text":"","category":"section"},{"location":"guide/guide.html#","page":"Guide","title":"Guide","text":"Let us introduce a simple example of the use of the library:","category":"page"},{"location":"guide/guide.html#","page":"Guide","title":"Guide","text":"First import the mesh from a file and check that the correct number of entities were imported.","category":"page"},{"location":"guide/guide.html#","page":"Guide","title":"Guide","text":"using MeshCore: skeleton, nvertices, nshapes\nusing MeshPorter: import_NASTRAN, vtkwrite\nmesh = import_NASTRAN(\"trunc_cyl_shell_0.nas\")\nvertices, shapes = mesh[\"vertices\"], mesh[\"shapes\"][1]\n(nvertices(vertices), nshapes(shapes)) == (376, 996)","category":"page"},{"location":"guide/guide.html#","page":"Guide","title":"Guide","text":"Extract zero-dimensional entities (points) by a triple application of the skeleton function. Check that the number of shapes is equal to the number of the vertices (in this particular skeleton they correspond one-to-one).","category":"page"},{"location":"guide/guide.html#","page":"Guide","title":"Guide","text":"bshapes = skeleton(skeleton(skeleton(shapes)))\n(nvertices(vertices), nshapes(bshapes)) == (376, 376)","category":"page"},{"location":"guide/guide.html#","page":"Guide","title":"Guide","text":"Export the mesh for visualization.","category":"page"},{"location":"guide/guide.html#","page":"Guide","title":"Guide","text":"vtkwrite(\"trunc_cyl_shell_0-boundary-skeleton\", vertices, bshapes)","category":"page"},{"location":"index.html#MeshSteward-Documentation-1","page":"Home","title":"MeshSteward Documentation","text":"","category":"section"},{"location":"index.html#Conceptual-guide-1","page":"Home","title":"Conceptual guide","text":"","category":"section"},{"location":"index.html#","page":"Home","title":"Home","text":"The concepts and ideas are described.","category":"page"},{"location":"index.html#","page":"Home","title":"Home","text":"Pages = [\n    \"guide/guide.md\",\n]\nDepth = 1","category":"page"},{"location":"index.html#Manual-1","page":"Home","title":"Manual","text":"","category":"section"},{"location":"index.html#","page":"Home","title":"Home","text":"The description of the types and of the functions.","category":"page"},{"location":"index.html#","page":"Home","title":"Home","text":"Pages = [\n    \"man/types.md\",\n    \"man/functions.md\",\n]\nDepth = 3","category":"page"},{"location":"man/types.html#Types-1","page":"Types","title":"Types","text":"","category":"section"},{"location":"man/types.html#","page":"Types","title":"Types","text":"CurrentModule = MeshSteward","category":"page"},{"location":"man/functions.html#Functions-1","page":"Functions","title":"Functions","text":"","category":"section"},{"location":"man/functions.html#","page":"Functions","title":"Functions","text":"CurrentModule = MeshSteward","category":"page"},{"location":"man/functions.html#Boxes-1","page":"Functions","title":"Boxes","text":"","category":"section"},{"location":"man/functions.html#","page":"Functions","title":"Functions","text":"initbox\nupdatebox!\nboundingbox\ninflatebox!\ninbox\nboxesoverlap\nintersectboxes","category":"page"},{"location":"man/functions.html#MeshSteward.initbox","page":"Functions","title":"MeshSteward.initbox","text":"initbox(x::AbstractVector{T}) where {T}\n\nCreate a bounding box and initialize with a single point.\n\n\n\n\n\n","category":"function"},{"location":"man/functions.html#MeshSteward.updatebox!","page":"Functions","title":"MeshSteward.updatebox!","text":"updatebox!(box::AbstractVector{T}, x::AbstractVector{T}) where {T}\n\nUpdate a box with another location, or create a new box.\n\nIf the  box does not have  the correct dimensions,  it is correctly sized.\n\nbox = bounding box     for 1-D box=[minx,maxx], or     for 2-D box=[minx,maxx,miny,maxy], or     for 3-D box=[minx,maxx,miny,maxy,minz,maxz] x = vector defining a point.  The box is expanded to include the     supplied location x.  \n\n\n\n\n\n","category":"function"},{"location":"man/functions.html#MeshSteward.boundingbox","page":"Functions","title":"MeshSteward.boundingbox","text":"boundingbox(x::AbstractArray{T}) where {T}\n\nCompute the bounding box of the points in x.\n\nx = holds points, one per row.\n\nReturns box = bounding box     for 1-D box=[minx,maxx], or     for 2-D box=[minx,maxx,miny,maxy], or     for 3-D box=[minx,maxx,miny,maxy,minz,maxz]\n\n\n\n\n\n","category":"function"},{"location":"man/functions.html#MeshSteward.inflatebox!","page":"Functions","title":"MeshSteward.inflatebox!","text":"inflatebox!(box::AbstractVector{T}, inflatevalue::T) where {T}\n\nInflate the box by the value supplied.\n\n\n\n\n\n","category":"function"},{"location":"man/functions.html#MeshSteward.inbox","page":"Functions","title":"MeshSteward.inbox","text":"inbox(box::AbstractVector{T}, x::AbstractVector{T}) where {T}\n\nIs the given location inside the box?\n\nbox = vector entries arranged as minx,maxx,miny,maxy,minz,maxz.\n\nNote: point on the boundary of the box is counted as being inside.\n\n\n\n\n\n","category":"function"},{"location":"man/functions.html#MeshSteward.boxesoverlap","page":"Functions","title":"MeshSteward.boxesoverlap","text":"boxesoverlap(box1::AbstractVector{T}, box2::AbstractVector{T}) where {T}\n\nDo the given boxes overlap?\n\n\n\n\n\n","category":"function"},{"location":"man/functions.html#MeshSteward.intersectboxes","page":"Functions","title":"MeshSteward.intersectboxes","text":"intersectboxes(box1::AbstractVector{T}, box2::AbstractVector{T}) where {T}\n\nCompute the intersection of two boxes.\n\nThe function returns an empty box (length(b) == 0) if the intersection is empty; otherwise a box is returned.\n\n\n\n\n\n","category":"function"},{"location":"man/functions.html#Searching-vertices-and-elements-1","page":"Functions","title":"Searching vertices and elements","text":"","category":"section"},{"location":"man/functions.html#","page":"Functions","title":"Functions","text":"vselect\neselect","category":"page"},{"location":"man/functions.html#MeshSteward.vselect","page":"Functions","title":"MeshSteward.vselect","text":"vselect(v::VT; kwargs...) where {VT}\n\nSelect locations (vertices) based on some criterion.\n\nVT is an abstract array that returns the coordinates of a vertex given its number.\n\nSelection criteria\n\nbox\n\nnLx = vselect(v, box = [0.0 Lx  0.0 0.0 0.0 0.0], inflate = Lx/1.0e5)\n\nThe keyword 'inflate' may be used to increase or decrease the extent of the box (or the distance) to make sure some nodes which would be on the boundary are either excluded or included.\n\ndistance\n\nlist = vselect(v, distance=1.0+0.1/2^nref, from=[0. 0.], inflate=tolerance);\n\nplane\n\ncandidates = vselect(v, plane = [0.0 0.0 1.0 0.0], thickness = h/1000)\n\nThe keyword plane defines the plane by its normal (the first two or three numbers) and its distance from the origin (the last number). Nodes are selected they lie on the plane,  or near the plane within the distance thickness from the plane. The normal is assumed to be of unit length, if it isn't provided as such, it will be normalized internally.\n\nnearestto\n\nFind the node nearest to the location given.\n\nnh = vselect(v, nearestto = [R+Ro/2, 0.0, 0.0])\n\nReturns\n\nThe list of vertices that match the search criterion.\n\n\n\n\n\nvselect(m::Mesh; kwargs...)\n\nSelect vertices. Return as an incidence relation.\n\nRefer to MeshFinder vselect.\n\n\n\n\n\n","category":"function"},{"location":"man/functions.html#MeshSteward.eselect","page":"Functions","title":"MeshSteward.eselect","text":"eselect(ir::IncRel; kwargs...)\n\nSelect finite elements.\n\nArguments\n\nir = incidence relation representing finite element set (d, 0). The \"elements\" are the shapes on the left of the incidence relation.\nkwargs = keyword arguments to specify the selection criteria\n\nSelection criteria\n\nfacing\n\nSelect all \"boundary\" elements that \"face\" a certain direction.\n\nexteriorbfl = eselect(ir, facing=true, direction=x -> [1.0, 1.0, 0.0]);\n\nor\n\nexteriorbfl = eselect(ir, facing=true, direction=xyz -> xyz/norm(xyz), dotmin = 0.99);\n\nwhere xyz is the location of the centroid  of  a boundary element. Here the finite element is considered \"facing\" in the given direction if the dot product of its normal and the direction vector is greater than dotmin. The default value for dotmin is 0.01 (this corresponds to  almost 90 degrees between the normal to the finite element  and the given direction).\n\nThis selection method makes sense only for elements that are  surface-like (i. e. for boundary meshes).\n\nlabel\n\nSelect elements based on their label.\n\nrl1 = eselect(ir, label=1)\n\nbox, distance\n\nSelect elements based on some criteria that their nodes satisfy.  See the function vselect().\n\nExample: Select all  elements whose nodes are closer than R+inflate from the point from.\n\nlinner = eselect(ir, distance = R, from = [0.0 0.0 0.0], inflate = tolerance)\n\nExample:\n\nexteriorbfl = eselect(ir, box=[1.0, 1.0, 0.0, pi/2, 0.0, Th], inflate=tolerance)\n\nwhere Th is a variable.\n\nOptional keyword arguments\n\nShould we consider the element only if all its nodes are in?\n\nallin = Boolean: if true, then all nodes of an element must satisfy the criterion; otherwise  one is enough.\n\nOutput\n\nfelist = list of finite elements (shapes) from the from the collection on the left of the incidence relation that satisfy the criteria\n\n\n\n\n\n","category":"function"},{"location":"man/functions.html#Import-of-meshes-1","page":"Functions","title":"Import of meshes","text":"","category":"section"},{"location":"man/functions.html#","page":"Functions","title":"Functions","text":"import_MESH\nimport_NASTRAN\nimport_ABAQUS","category":"page"},{"location":"man/functions.html#MeshSteward.import_MESH","page":"Functions","title":"MeshSteward.import_MESH","text":"import_MESH(meshfile)\n\nImport vertices and shapes in the MESH format.\n\nOutput\n\nData dictionary, with keys\n\n\"vertices\" (vertices),\n\"shapes\" (array of shape collections).\n\n\n\n\n\n","category":"function"},{"location":"man/functions.html#MeshSteward.import_NASTRAN","page":"Functions","title":"MeshSteward.import_NASTRAN","text":"import_NASTRAN(filename)\n\nImport tetrahedral (4- and 10-node) NASTRAN mesh (.nas file).\n\nLimitations:\n\nonly the GRID and CTETRA  sections are read.\nOnly 4-node and 10-node tetrahedra  are handled.\nThe file should be free-form (data separated by commas).\n\nSome fixed-format files can also be processed (large-field, but not small-field).\n\nOutput\n\nData dictionary, with keys\n\n\"vertices\" (vertices),\n\"shapes\" (array of shape collections).\n\n\n\n\n\n","category":"function"},{"location":"man/functions.html#MeshSteward.import_ABAQUS","page":"Functions","title":"MeshSteward.import_ABAQUS","text":"import_ABAQUS(filename)\n\nImport tetrahedral (4- and 10-node) or hexahedral (8- and 20-node) Abaqus mesh (.inp file).\n\nLimitations:\n\nOnly the *NODE and *ELEMENT  sections are read\nOnly 4-node and 10-node tetrahedra, 8-node or 20-node  hexahedra, 3-node triangles  are handled.\n\nOutput\n\nData dictionary, with keys\n\n\"fens\" (finite element nodes),\n\"fesets\" (array of finite element sets).\n\n\n\n\n\n","category":"function"},{"location":"man/functions.html#Export-of-meshes-1","page":"Functions","title":"Export of meshes","text":"","category":"section"},{"location":"man/functions.html#","page":"Functions","title":"Functions","text":"vtkwrite\nexport_MESH","category":"page"},{"location":"man/functions.html#MeshSteward.vtkwrite","page":"Functions","title":"MeshSteward.vtkwrite","text":"vtkwrite(filename, connectivity)\n\nWrite VTK file with the mesh.\n\nconnectivity = incidence relation of the type d -> 0. It must have a \"geom\" attribute for access to the locations of all the vertices that the connectivity incidence relation references.\ndata = array of named tuples. Names of attributes of either the left or the right shape collection of the connectivity incidence relation. Property names: :name required, name of the attribute. :allxyz optional, pad the attribute to be a three-dimensional quantity (in the global Cartesian coordinate system).\n\n\n\n\n\n","category":"function"},{"location":"man/functions.html#MeshSteward.export_MESH","page":"Functions","title":"MeshSteward.export_MESH","text":"export_MESH(meshfile, mesh)\n\nImport vertices and shapes in the MESH format.\n\nOutput\n\nData dictionary, with keys\n\n\"vertices\" (vertices),\n\"shapes\" (array of shape collections).\n\n\n\n\n\n","category":"function"},{"location":"man/functions.html#Management-of-meshes-1","page":"Functions","title":"Management of meshes","text":"","category":"section"},{"location":"man/functions.html#","page":"Functions","title":"Functions","text":"load\nsave\nincrel\ninsert!\nbasecode\nnspacedims\nBase.summary\nboundary\nvertices\nsubmesh\nlabel","category":"page"},{"location":"man/functions.html#MeshSteward.load","page":"Functions","title":"MeshSteward.load","text":"load(m::Mesh, filename::String)\n\nLoad a mesh (incidence relation) from a MESH file.\n\nnote: Note\n\n\nNo check is performed that the loaded incidence relation is compatible with the existing incidence relations in the mesh.\n\n\n\n\n\n","category":"function"},{"location":"man/functions.html#MeshSteward.save","page":"Functions","title":"MeshSteward.save","text":"save(m::Mesh, filename::String)\n\nSave a mesh base incidence relation to a MESH file.\n\n\n\n\n\n","category":"function"},{"location":"man/functions.html#MeshSteward.increl","page":"Functions","title":"MeshSteward.increl","text":"increl(m::Mesh, irc::Tuple{Int64, Int64})\n\nRetrieve the named incidence relation based on the code.\n\n\n\n\n\nincrel(m::Mesh, fullirc::Tuple{Int64, Int64, String})\n\nRetrieve the named incidence relation based on the full key.\n\n\n\n\n\n","category":"function"},{"location":"man/functions.html#MeshSteward.insert!","page":"Functions","title":"MeshSteward.insert!","text":"insert!(m::Mesh, increl::IncRel)\n\nInsert the incidence relation under its code and empty tag. \n\nThe code of the incidence relation combined with an empty tag (\"\") is the key under which this relation is stored in the mesh.\n\n\n\n\n\ninsert!(m::Mesh, increl::IncRel, tag::String)\n\nInsert the incidence relation under its code and given tag. \n\nThe code of the incidence relation combined with the tag is the key under which this relation is stored in the mesh.\n\n\n\n\n\n","category":"function"},{"location":"man/functions.html#MeshSteward.basecode","page":"Functions","title":"MeshSteward.basecode","text":"basecode(m::Mesh)\n\nCompute the code of the base relation.\n\nThe base incidence relation is (d, 0) that represents the elements of the interior of the domain.\n\n\n\n\n\n","category":"function"},{"location":"man/functions.html#MeshSteward.nspacedims","page":"Functions","title":"MeshSteward.nspacedims","text":"nspacedims(m::Mesh)\n\nFurnish the dimension of the space in which the mesh lives.\n\n\n\n\n\n","category":"function"},{"location":"man/functions.html#Base.summary","page":"Functions","title":"Base.summary","text":"Base.summary(ir::IncRel)\n\nForm a brief summary of the incidence relation.\n\n\n\n\n\nBase.summary(sc::S) where {S<:ShapeColl}\n\nForm a brief summary of the shape collection.\n\n\n\n\n\nBase.summary(m::Mesh)\n\nForm a brief summary of the mesh.\n\n\n\n\n\nBase.summary(io::IO, m::Mesh)\n\nForm a brief summary of the mesh.\n\n\n\n\n\n","category":"function"},{"location":"man/functions.html#MeshSteward.boundary","page":"Functions","title":"MeshSteward.boundary","text":"boundary(m::Mesh)\n\nCompute the boundary of the mesh.\n\nThe incidents relation is stored in the mesh with the tag \"boundary\".\n\n\n\n\n\n","category":"function"},{"location":"man/functions.html#MeshSteward.vertices","page":"Functions","title":"MeshSteward.vertices","text":"vertices(m::Mesh)\n\nCompute the (0, 0) incidence relation for the vertices of the base incidence relation.\n\n\n\n\n\n","category":"function"},{"location":"man/functions.html#MeshSteward.submesh","page":"Functions","title":"MeshSteward.submesh","text":"submesh(m::Mesh, list)\n\nExtract a submesh constructed of a subset of the base relation. \n\n\n\n\n\n","category":"function"},{"location":"man/functions.html#MeshSteward.label","page":"Functions","title":"MeshSteward.label","text":"label(m::Mesh, irc, list, lab)\n\nLabel shapes in list with the label lab.\n\nLabel the shapes on the shapecoll of the incidence relation. shapecoll must be either :left or :right.\n\n\n\n\n\n","category":"function"},{"location":"man/functions.html#Index-1","page":"Functions","title":"Index","text":"","category":"section"},{"location":"man/functions.html#","page":"Functions","title":"Functions","text":"","category":"page"}]
}
