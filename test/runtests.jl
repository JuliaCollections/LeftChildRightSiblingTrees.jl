using LeftChildRightSiblingTrees, AbstractTrees
using Test

function mumtree()
    # from the README
    mum = Node("Mum")
    me = addchild(mum, "Me")
    son = addchild(me, "Son")
    daughter = addchild(me, "Daughter")
    brother = addsibling(me, "Brother")
    return mum
end

@testset "LeftChildRightSiblingTrees" begin
    root = Node(0)
    @test isroot(root)
    @test isleaf(root)
    @test islastsibling(root)
    nchildren = 0
    for c in root
        nchildren += 1
    end
    @test nchildren == 0
    c1 = addchild(root, 1)
    @test islastsibling(c1)
    c2 = addchild(root, 2)
    @test !islastsibling(c1)
    @test islastsibling(c2)
    c3 = addsibling(c2, 3)
    @test lastsibling(c1) == c3
    @test islastsibling(c3)
    @test !islastsibling(c2)

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

    @test depth(root) == 3
    @test depth(c3) == 1

    root1 = deepcopy(root)
    node = collect(root1)[2]
    graftchildren!(root1, node)
    @test isleaf(node)
    @test [c.data for c in root1] == [1,2,3,4,5]
    for c in root1
        @test c.parent == root1
    end
    prunebranch!(node)
    @test [c.data for c in root1] == [1,3,4,5]

    root1 = deepcopy(root)
    chlds = collect(root1)
    p, node = chlds[1], chlds[2]
    @test isleaf(p)
    graftchildren!(p, node)
    @test isleaf(node)
    @test [c.data for c in root1] == [1,2,3]
    @test [c.data for c in p] == [4,5]
    for c in p
        @test c.parent == p
    end

    root1 = deepcopy(root)
    chlds = collect(root1)
    prunebranch!(chlds[end])
    @test [c.data for c in root1] == [1,2]

    root1 = deepcopy(root)
    chlds = collect(root1)
    prunebranch!(chlds[1])
    @test [c.data for c in root1] == [2,3]
    @test_throws ErrorException("cannot prune the root") prunebranch!(root1)

    tree1 = mumtree()
    tree2 = mumtree()
    @test tree1 == tree2
    c = collect(tree1)
    addchild(last(c), "Kid")
    @test tree1 != tree2

    root = Node(1)
    otherroot = Node(2)
    addchild(otherroot, 3)
    addchild(otherroot, 4)
    newc = addchild(root, otherroot)
    @test newc === otherroot
    @test !isleaf(root)
    @test depth(root) == 3
    @test map(x -> x.data, collect(PreOrderDFS(root))) == [1, 2, 3, 4]
    tmp = Node(0)
    @test_throws ErrorException addchild(tmp, otherroot)
    thirdroot = Node(5)
    addchild(thirdroot, 6)
    addchild(thirdroot, 7)
    newc = addchild(root, thirdroot)
    @test newc === thirdroot
    @test map(x -> x.data, collect(PreOrderDFS(root))) == [1, 2, 3, 4, 5, 6, 7]

    @test !islastsibling(otherroot)
    copied_root = copy_subtree(otherroot)
    @test AbstractTrees.isroot(copied_root)
    @test islastsibling(copied_root)
    for (oldchild, newchild) in zip(otherroot, copied_root)
        @test oldchild.parent === otherroot
        @test newchild.parent === copied_root
    end

    leaf = Node(2)
    copied_leaf = copy_subtree(leaf)
    @test isleaf(leaf)
    @test isleaf(copied_leaf)
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
