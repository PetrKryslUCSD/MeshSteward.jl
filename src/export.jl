
# const VTKtypemap = Dict{DataType, Int}(P1=>1, L2=>3, T3=>5,
#     Q4=>9, T4=>10, H8=>12, Q8=>23,
#     L3=>21, T6=>22,
#     T10=>24, H20=>25)
const _VTK_TYPE_MAP = Dict{AbsShapeDesc, Int}(P1=>1, L2=>3, T3=>5, Q4=>9, T4=>10, H8=>12)

"""
    vtkwrite(filename, connectivity)

Write VTK file with the mesh.

- `connectivity` = incidence relation of the type `d -> 0`. It must have a "geom"
  attribute for access to the locations of all the vertices that the
  connectivity incidence relation references.
- `data` = array of string keys. Names of attributes of either the left or the
  right shape collection of the `connectivity` incidence relation.
"""
function vtkwrite(filename, connectivity, data = String[])
    locs = attribute(connectivity.right, "geom")
    # Fill in a matrix of point coordinates
    points = fill(zero(eltype(locs[1])), length(locs[1]), length(locs))
    for i in 1:length(locs)
        points[:, i] .= locs[i]
    end #
    # Figure out the cell type
    celltype = WriteVTK.VTKCellTypes.VTKCellType(_VTK_TYPE_MAP[shapedesc(connectivity.left)])
    # Prepare an array of the cells
    cells = [MeshCell(celltype, [j for j in retrieve(connectivity, i)]) for i in 1:nrelations(connectivity)]
    vtkfile = vtk_grid(filename, points, cells, compress=3)
    for d in data
        if d in keys(connectivity.right.attributes)
            a = attribute(connectivity.right, d)
            nc = length(a[1])
            pdata = fill(0.0, nc, length(a))
            for j in 1:nc
                for i in 1:length(a)
                    pdata[j, i] = a[i][j]
                end
            end
            vtkfile[d] = pdata
        elseif d in keys(connectivity.left.attributes)
            a = attribute(connectivity.left, d)
            nc = length(a[1])
            cdata = fill(0.0, nc, length(a))
            for j in 1:nc
                for i in 1:length(a)
                    cdata[j, i] = a[i][j]
                end
            end
            vtkfile[d] = cdata
        end
    end
    return vtk_save(vtkfile)
end

"""
    export_MESH(meshfile, mesh)

Import vertices and shapes in the MESH format.

# Output
Data dictionary, with keys
- "`vertices`" (vertices),
- "`shapes`" (array of shape collections).
"""
function export_MESH(meshfile, connectivity)
    meshfilebase, ext = splitext(meshfile)
    # Name of the shape descriptor
    t = shapedesc(connectivity.left).name
    datinfo = [meshfilebase * "-xyz.dat", t, meshfilebase * "-conn.dat"]
    locs = attribute(connectivity.right, "geom")
    open(datinfo[1], "w") do file
        X = [locs[idx] for idx in 1:length(locs)]
        writedlm(file, X, ' ')
    end
    open(datinfo[3], "w") do file
        c = [retrieve(connectivity, idx) for idx in 1:nrelations(connectivity)]
        writedlm(file, c, ' ')
    end
    open(meshfilebase * ".mesh", "w") do file
        writedlm(file, datinfo)
    end

    return true
end
