"""
    import_MESH(meshfile)

Import vertices and shapes in the MESH format.

# Output
Data dictionary, with keys
- "`vertices`" (vertices),
- "`shapes`" (array of shape collections).
"""
function import_MESH(meshfile)
    meshfilebase, ext = splitext(meshfile)
    if ext == ""
        ext = ".mesh"
    end
    meshfile = meshfilebase * ext
    # Mesh file in the format of the FinEtools .mesh file
    datinfo = open(meshfile, "r") do file
        readdlm(file)
    end
    # The first line is the name of the file with the coordinates
    X = open(datinfo[1], "r") do file
        readdlm(file, ' ', Float64)
    end
    # RAW: should be able to handle multiple shape sets.
    # The second line is the name of the shape descriptor.
    sd = SHAPE_DESC[datinfo[2]]
    C = open(datinfo[3], "r") do file
        readdlm(file, ' ', Int64)
    end

    N, T = size(X, 2), eltype(X)
    locs =  VecAttrib([SVector{N, T}(X[i, :]) for i in 1:size(X, 1)])
    vrts = ShapeColl(P1, length(locs), "vertices")
    vrts.attributes["geom"] = locs
    shapes = ShapeColl(sd, size(C, 1), "elements")
    connectivity = IncRel(shapes, vrts, C)

    return [connectivity]
end

"""
!!! note 
    The arrays are reallocated as the data is read from files. The size of the
    arrays is increased by this much. If the number of entities to be read  is
    large, the CHUNK should be probably increased so that only a few reallocations
    are needed.
"""
const CHUNK = 1000


# Fix up an old style floating-point number without the exponent letter.
function _fixupdecimal(s)
    os = ""
    for i = length(s):-1:1
        os = s[i] * os
        if (s[i] == '-') && (i > 1) && (uppercase(s[i-1]) != "E") && isdigit(s[i-1])
            os = "E" * os
        end
        if (s[i] == '+') && (i > 1) && (uppercase(s[i-1]) != "E") && isdigit(s[i-1])
            os = "E" * os
        end
    end
    return os
end

"""
    import_NASTRAN(filename)

Import tetrahedral (4- and 10-node) NASTRAN mesh (.nas file).

Limitations:
1. only the GRID and CTETRA  sections are read.
2. Only 4-node and 10-node tetrahedra  are handled.
3. The file should be free-form (data separated by commas).
Some fixed-format files can also be processed (large-field, but not small-field).

# Output
Data dictionary, with keys
- "`vertices`" (vertices),
- "`shapes`" (array of shape collections).
"""
function import_NASTRAN(filename; allocationchunk=CHUNK, expectfixedformat = false)
    lines = readlines(filename)

    nnode = 0
    node = zeros(allocationchunk, 4)
    maxnodel = 10
    nelem = 0
    elem = zeros(Int64, allocationchunk, maxnodel + 3)

    current_line = 1
    while true
        if current_line >= length(lines)
            break
        end
        temp  = lines[current_line]
        current_line = current_line + 1
        if (length(temp) >= 4) && (uppercase(temp[1:4]) == "GRID")
            fixedformat = expectfixedformat
            largefield = false
            if (length(temp) >= 5) && (uppercase(temp[1:5]) == "GRID*")
                largefield = true; fixedformat = true
            end
            @assert (!fixedformat) || (fixedformat && largefield) "Can handle either free format or large-field fixed format"
            nnode = nnode + 1
            if size(node, 1) < nnode
                node = vcat(node, zeros(allocationchunk, 4))
            end
            if fixedformat
                # $------1-------2-------3-------4-------5-------6-------7-------8-------9-------0
                # GRID*                  5               0-1.66618812195+1-3.85740337853+0
                # *       1.546691269367+1               0
                node[nnode, 1] = parse(Float64, _fixupdecimal(temp[9:24]))
                node[nnode, 2] = parse(Float64, _fixupdecimal(temp[41:56]))
                node[nnode, 3] = parse(Float64, _fixupdecimal(temp[57:72]))
                temp  = lines[current_line]
                current_line = current_line + 1
                node[nnode, 4] = parse(Float64, _fixupdecimal(temp[9:24]))
            else
                # Template:
                #   GRID,1,,-1.32846E-017,3.25378E-033,0.216954
                A = split(replace(temp, "," => " "))
                for  six = 1:4
                    node[nnode, six] = parse(Float64, A[six+1])
                end
            end
        end # GRID
        if (length(temp) >= 6) && (uppercase(temp[1:6]) == "CTETRA")
            # Template:
            #   CTETRA,1,3,15,14,12,16,8971,4853,8972,4850,8973,4848
            nelem = nelem + 1
            if size(elem, 1) < nelem
                elem = vcat(elem, zeros(Int64, allocationchunk, maxnodel + 3))
            end
            continuation = ""
            fixedformat = (length(temp) == 72) || expectfixedformat # Is this fixed-format record? This is a guess based on the length of the line.
            if fixedformat
                continuation = temp[min(length(temp), 72):length(temp)]
                temp = temp[1:min(length(temp), 72)]
            end
            A = split(replace(temp, "," => " "))
            elem[nelem, 1] = parse(Int64, A[2])
            elem[nelem, 2] = parse(Int64, A[3])
            if length(A) == 7  #  nodes per element  equals  4
                nperel = 4
            else
                nperel = 10
                if length(A) < 13 # the line is continued: read the next line
                    temp  = lines[current_line]
                    current_line = current_line + 1
                    if fixedformat
                        temp = temp[length(continuation)+1:min(length(temp), 72)]
                    end
                    temp = strip(temp)
                    Acont = split(replace(temp, "," => " "))
                    A = vcat(A, Acont)
                end
            end
            elem[nelem, 3] = nperel
            for  six = 1:nperel
                elem[nelem, six+3] = parse(Int64, A[six+3])
            end
        end # CTETRA

    end # while

    node = node[1:nnode,:]
    elem = elem[1:nelem,:]

    # The nodes need to be in serial order:  if they are not,  the element
    # connectivities  will not point at the right nodes
    @assert  norm(collect(1:nnode)-node[:,1]) == 0 "Nodes are not in serial order"

    # Process output arguments
    # Extract coordinates
    xyz = node[:,2:4]
    # Cleanup element connectivities
    ennod = unique(elem[:,3])
    @assert length(ennod) == 1 "Cannot handle mixture of element types"

    @assert ((ennod[1] == 4) || (ennod[1] == 10)) "Unknown element type"
    conn = elem[:,4:3+convert(Int64, ennod[1])]

    # Create output arguments. First the nodes
    N, T = size(xyz, 2), eltype(xyz)
    locs =  VecAttrib([SVector{N, T}(xyz[i, :]) for i in 1:size(xyz, 1)])
    if ennod[1] == 4
        shapes = ShapeColl(T4, size(conn, 1), "elements")
    # else
        # fes = FESetT10(conn) # RAW
    end

    vrts = ShapeColl(P1, length(locs), "vertices")
    vrts.attributes["geom"] = locs
    connectivity = IncRel(shapes, vrts, conn)

    return [connectivity]
end

mutable struct AbaqusElementSection
    ElementLine::AbstractString
    nelem::Int64
    elem::Array{Int64,2}
end

"""
    import_ABAQUS(filename)

Import tetrahedral (4- and 10-node) or hexahedral (8- and 20-node) Abaqus mesh
(.inp file).

Limitations:
1. Only the `*NODE` and `*ELEMENT`  sections are read
2. Only 4-node and 10-node tetrahedra, 8-node or 20-node  hexahedra, 3-node triangles
    are handled.

# Output
Data dictionary, with keys
- "`fens`" (finite element nodes),
- "`fesets`" (array of finite element sets).
"""
function import_ABAQUS(filename; allocationchunk=CHUNK)
    lines = readlines(filename)

    maxelnodes = 20

    warnings = String[]
    nnode = 0
    node = zeros(allocationchunk, 4)
    Reading_nodes = false
    next_line = 1
    while true
        if next_line > length(lines)
            break
        end
        temp = uppercase(strip(lines[next_line]))
        next_line = next_line + 1
        if (length(temp) >= 5) && (temp[1:5] == "*NODE")
            Reading_nodes = true
            nnode = 0
            node = zeros(allocationchunk, 4)
            temp = uppercase(strip(lines[next_line]))
            next_line = next_line + 1
        end
        if Reading_nodes
            if temp[1:1] == "*" # another section started
                Reading_nodes = false
                break
            end
            nnode = nnode + 1
            if size(node, 1) < nnode # if needed, allocate more space
                node = vcat(node, zeros(allocationchunk, 4))
            end
            A = split(replace(temp, "," => " "))
            for  six = 1:length(A)
                node[nnode, six] = parse(Float64, A[six])
            end
        end
    end # while

    nelemset = 0
    elemset = AbaqusElementSection[]
    Reading_elements = false
    next_line = 1
    while true
        if next_line > length(lines)
            break
        end
        temp = uppercase(strip(lines[next_line]))
        next_line = next_line + 1
        if (length(temp) >= 8) && (temp[1:8] == "*ELEMENT")
            Reading_elements = true
            nelemset = nelemset + 1
            nelem = 0
            a = AbaqusElementSection(temp, nelem, zeros(Int64, allocationchunk, maxelnodes+1))
            push!(elemset, a)
            temp = uppercase(strip(lines[next_line]))
            next_line = next_line + 1
        end
        if Reading_elements
            if temp[1:1] == "*" # another section started
                Reading_elements = false
                break
            end
            elemset[nelemset].nelem = elemset[nelemset].nelem + 1
            if size(elemset[nelemset].elem, 1) < elemset[nelemset].nelem
                elemset[nelemset].elem = vcat(elemset[nelemset].elem,
                zeros(Int64, allocationchunk, maxelnodes+1))
            end
            A = split(temp, ",")
            if (A[end] == "") # the present line is continued on the next one
                temp = uppercase(strip(lines[next_line]))
                next_line = next_line + 1
                Acont = split(temp, ",")
                A = vcat(A[1:end-1], Acont)
            end
            for ixxxx = 1:length(A)
                elemset[nelemset].elem[elemset[nelemset].nelem, ixxxx] = parse(Int64, A[ixxxx])
            end
        end
    end # while

    node = node[1:nnode, :] # truncate the array to just the lines read
    # The nodes need to be in serial order:  if they are not,  the element
    # connectivities  will not point at the right nodes. So,  if that's the case we
    # will figure out the sequential numbering of the nodes  and then we will
    # renumber the connectivvities of the elements.
    # newnumbering = collect(1:nnode)
    # if norm(collect(1:nnode)-node[:,1]) != 0
    #     newnumbering = zeros(Int64, convert(Int64, maximum(node[:,1])))
    #     jn = 1
    #     for ixxxx = 1:size(node, 1)
    #         if node[ixxxx,1] != 0
    #             on = convert(Int64, node[ixxxx,1])
    #             newnumbering[on] = jn
    #             jn = jn + 1
    #         end
    #     end
    # end

    # Process output arguments
    # Nodes
    xyz = node[:,2:4]
    
    # Element sets
    connectivities = IncRel[]

    function feset_construct(elemset1)
        temp = uppercase(strip(elemset1.ElementLine))
        b  = split(temp, ",")
        for ixxx = 1:length(b)
            c = split(b[ixxx], "=")
            if (uppercase(strip(c[1])) == "TYPE") && (length(c) > 1)
                TYPE = uppercase(strip(c[2]))
                if (length(TYPE) >= 4) && (TYPE[1:4] == "C3D4")
                    return (T4, elemset1.elem[:, 2:5])
                # elseif (length(TYPE) >= 4) && (TYPE[1:4] == "C3D8")
                #     return FESetH8(elemset1.elem[:, 2:9])
                # elseif (length(TYPE) >= 5) && (TYPE[1:5] == "C3D20")
                #     return FESetH20(elemset1.elem[:, 2:21])
                # elseif (length(TYPE) >= 5) && (TYPE[1:5] == "C3D10")
                #     return FESetT10(elemset1.elem[:, 2:11])
                # elseif (length(TYPE) >= 5) && (TYPE[1:5] == "DC2D3")
                #     return FESetT3(elemset1.elem[:, 2:4])
                elseif (length(TYPE) >= 5) && ((TYPE[1:5] == "CPS4R") || (TYPE[1:4] == "CPS4"))
                    return (Q4, elemset1.elem[:, 2:5])
                else
                    return nothing, nothing
                end
            end
        end
    end

    # Create output arguments. First the nodes
    N, T = size(xyz, 2), eltype(xyz)
    locs =  VecAttrib([SVector{N, T}(xyz[i, :]) for i in 1:size(xyz, 1)])
    vrts = ShapeColl(P1, length(locs), "vertices")
    vrts.attributes["geom"] = locs
    
    for ixxxx = 1:length(elemset)
        elemset[ixxxx].elem = elemset[ixxxx].elem[1:elemset[ixxxx].nelem, :]
        fet, conn = feset_construct(elemset[ixxxx])
        if (fet == nothing)
            @warn "Don't know how to handle " * elemset[ixxxx].ElementLine
        else
            # fes = renumberconn!(fes, newnumbering)
            elements = ShapeColl(fet, size(conn, 1), fet.name)
            push!(connectivities, IncRel(elements, vrts, [SVector{size(conn, 2), Int64}(conn[i, :]) for i in 1:size(conn, 1)], fet.name))
        end
    end

    return connectivities
end
