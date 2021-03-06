using Documenter, MeshCore, MeshSteward

makedocs(
	modules = [MeshSteward],
	doctest = false, clean = true,
	format = Documenter.HTML(prettyurls = false),
	authors = "Petr Krysl",
	sitename = "MeshSteward.jl",
	pages = Any[
			"Home" => "index.md",
			"How to guide" => "guide/guide.md",
			"Reference" => Any[
				"man/types.md",
				"man/functions.md"],
			"Concepts" => "concepts/concepts.md"	
		],
	)

deploydocs(
    repo = "github.com/PetrKryslUCSD/MeshSteward.jl.git",
)
