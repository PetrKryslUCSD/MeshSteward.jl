using Documenter, MeshCore, MeshSteward

makedocs(
	modules = [MeshSteward],
	doctest = false, clean = true,
	format = Documenter.HTML(prettyurls = false),
	authors = "Petr Krysl",
	sitename = "MeshSteward.jl",
	pages = Any[
	"Home" => "index.md",
	"How to Guide" => "guide/guide.md",
	"Types and Functions" => Any[
		"man/types.md",
		"man/functions.md"]
		]
	)

deploydocs(
    repo = "github.com/PetrKryslUCSD/MeshSteward.jl.git",
)
