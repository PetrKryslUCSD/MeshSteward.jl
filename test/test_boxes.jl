module mbox1
using MeshSteward: initbox, updatebox!, inflatebox!, inbox, boxesoverlap
using Test
function test()
	box = Float64[]
	box = initbox([0.0])
	@test isapprox(box, [0.0, 0.0])

	box = updatebox!(box, [-1.0])
	@test isapprox(box, [-1.0, 0.0])

	box = Float64[]
	box = initbox([1.0])
	inflate = 0.01
	box = inflatebox!(box, inflate) 
	@test isapprox(box, [0.99, 1.01])

	box = initbox([0.0])
	inflate = 0.01
	box = inflatebox!(box, inflate) 
	@test inbox(box, [-0.003]) == true

	box = initbox([2.0])
	updatebox!(box, [1.0])
	inflate = 0.01
	box = inflatebox!(box, inflate) 
	@test inbox(box, [rand()+1.0]) == true

	box = Float64[]
	box = initbox([0.0; 1.0])
	@test isapprox(box, [0.0, 0.0, 1.0, 1.0])

	box = updatebox!(box, [1.0; -1.0])
	@test isapprox(box, [0.0, 1.0, -1.0, 1.0])

	box = Float64[]
	box = initbox([0.0; 1.0])
	inflate = 0.01
	box = inflatebox!(box, inflate) 
	@test isapprox(box, [-0.01, 0.01, 0.99, 1.01])

	box = initbox([0.0; 1.0])
	inflate = 0.01
	box = inflatebox!(box, inflate) 
	@test inbox(box, [-0.003; 0.995]) == true

	box = initbox([0.0; 0.0])
	updatebox!(box, [1.0; 1.0])
	inflate = 0.01
	box = inflatebox!(box, inflate) 
	@test inbox(box, [-0.003; 0.995]) == true
	@test inbox(box, [rand(); rand()]) == true
	@test inbox(box, [0.5; 0.5]) == true
	@test inbox(box, [0.0-inflate; 0.0-inflate]) == true
	@test inbox(box, [0.0-inflate; 0.0-2*inflate]) == false
	@test inbox(box, [0.0+inflate; 1.0+inflate]) == true

	box = initbox([0.0; 0.0; 0.0].-1.0)
	updatebox!(box, [1.0; 1.0; 1.0])
	inflate = 0.01
	box = inflatebox!(box, inflate) 
	@test inbox(box, [-0.003; 0.995; 1.0]) == true
	@test inbox(box, [rand(); rand(); rand()]) == true
	@test inbox(box, [-rand(); rand(); rand()]) == true
	@test inbox(box, [rand(); -rand(); rand()]) == true
	@test inbox(box, [rand(); rand(); -rand()]) == true
	@test inbox(box, [0.0-inflate; 0.0-inflate; 1.0]) == true
	@test inbox(box, [0.0-inflate; 0.0-inflate; -1.0]) == true
	
	return true
end
end
using .mbox1
mbox1.test()

module mbox2
using MeshSteward: initbox, updatebox!, inflatebox!, inbox, boxesoverlap, boundingbox
using LinearAlgebra
using Test
function test()
	a = [0.431345 0.611088 0.913161;
	    0.913581 0.459229 0.82186;
	    0.999429 0.965389 0.571139;
	    0.390146 0.711732 0.302495;
	    0.873037 0.248077 0.51149;
	    0.999928 0.832524 0.93455]
	    b1 = boundingbox(a)
	    @test norm(b1 - [0.390146, 0.999928, 0.248077, 0.965389, 0.302495, 0.93455]) < 1.0e-4
	    b2 = updatebox!(b1, a)
	    @test norm(b1 - b2) < 1.0e-4
	    b2 = initbox(a)
	    @test norm(b1 - b2) < 1.0e-4
	    c = [-1.0, 3.0, -0.5]
	    b3 = updatebox!(b1, c)
	    # # println("$(b3)")
	    @test norm(b3 - [-1.0, 0.999928, 0.248077, 3.0, -0.5, 0.93455]) < 1.0e-4
	    x = [0.25 1.1 -0.3]
	    @test inbox(b3, x)
	    @test inbox(b3, c)
	    @test inbox(b3, a[2, :])
	    b4 = boundingbox(-a)
	    # # println("$(b3)")
	    # # println("$(b4)")
	    # # println("$(boxesoverlap(b3, b4))")
	    @test !boxesoverlap(b3, b4)
	    b5 = updatebox!(b3, [0.0 -0.4 0.0])
	    # # println("$(b5)")
	    # # println("$(boxesoverlap(b5, b4))")
	    @test boxesoverlap(b5, b4)
end
end
using .mbox2
mbox2.test()