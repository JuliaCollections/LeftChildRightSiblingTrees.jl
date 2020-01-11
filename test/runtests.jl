using LeftChildRightSiblingTrees, AbstractTrees
using Test

@testset "LeftChildRightSiblingTrees" begin
    root = Node(0)
    @test isroot(root)
    @test isleaf(root)
    nchildren = 0
    for c in root
        nchildren += 1
    end
    @test nchildren == 0
    c1 = addchild(root, 1)
    c2 = addchild(root, 2)
    c3 = addsibling(c2, 3)
    @test lastsibling(c1) == c3
    c21 = addchild(c2, 4)
    c22 = addchild(c2, 5)
    @test isroot(root)
    @test !isleaf(root)
    nchildren = 0
    for c in root
        @test !isroot(c)
        nchildren += 1
    end
    @test nchildren == 3
    @test isleaf(c1)
    @test !isleaf(c2)
    @test isleaf(c3)
    for c in c2
        @test !isroot(c)
        @test isleaf(c)
    end
    children2 = [c21,c22]
    i = 0
    for c in c2
        @test c == children2[i+=1]
    end
    io = IOBuffer()
    show(io, c2)
    str = String(take!(io))
    @test str == "Node(2)"
    LeftChildRightSiblingTrees.showedges(io, root)
    str = String(take!(io))
    @test occursin("2 has the following children", str)
end

@testset "AbstractTrees" begin
    root = Node(0)
    c1 = addchild(root, 1)
    c2 = addchild(root, 2)
    c3 = addsibling(c2, 3)
    c21 = addchild(c2, 4)
    c22 = addchild(c2, 5)
    io = IOBuffer()
    print_tree(io, root)
    @test strip(String(take!(io))) == "0\n├─ 1\n├─ 2\n│  ├─ 4\n│  └─ 5\n└─ 3"

    @test map(x->x.data, @inferred(collect(PostOrderDFS(root)))) == [1,4,5,2,3,0]
    @test map(x->x.data, @inferred(collect(PreOrderDFS(root)))) == [0,1,2,4,5,3]
    @test map(x->x.data, @inferred(collect(Leaves(root)))) == [1,4,5,3]
end
