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
    # Two trees built separately from the same recipe hold equal data in the
    # same arrangement, so they are equivalent, but they are not the same object.
    @test isequiv(tree1, tree2)
    @test tree1 != tree2
    @test tree1 == tree1
    c = collect(tree1)
    addchild(last(c), "Kid")
    # Growing one tree leaves the other behind, so they are no longer equivalent.
    @test !isequiv(tree1, tree2)

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

    # `children` returns a distinct iterator type rather than the node itself (issue #6)
    ch = AbstractTrees.children(root)
    @test ch isa LeftChildRightSiblingTrees.ChildIterator
    @test eltype(ch) === Node{Int}
    @test map(x->x.data, collect(ch)) == [1,2,3]
    @test isempty(collect(AbstractTrees.children(c1)))
end

@testset "node identity vs. equivalence" begin
    # `==` on nodes reports identity: a node equals only itself.
    a = Node(1)
    b = Node(1)
    @test a == a
    @test a != b
    @test !isequal(a, b)

    # Because equality is identity, equivalent-but-distinct trees are distinct
    # keys in a Dict or Set.
    addchild(a, 2)
    addchild(b, 2)
    @test isequiv(a, b)
    d = Dict(a => "a", b => "b")
    @test length(d) == 2
    @test d[a] == "a" && d[b] == "b"

    # `isequiv` compares trees by shape and by the data at each node.
    c = Node(1); addchild(c, 99)            # same shape as `a`, different leaf data
    @test !isequiv(a, c)
    e = Node(1); addchild(e, 2); addchild(e, 3)   # an extra child relative to `a`
    @test !isequiv(a, e)
    @test isequiv(a, a)
end

@testset "graftchildren! with a childless source" begin
    # Moving the children of a leaf means moving nothing: the destination is
    # unchanged and the source keeps its place and its parent.
    root = Node(0)
    keeper = addchild(root, 1)
    branch = addchild(root, 2)
    leafy = addchild(branch, 3)
    graftchildren!(root, leafy)
    @test [c.data for c in root] == [1, 2]
    @test [c.data for c in branch] == [3]
    @test leafy.parent === branch
    @test isleaf(leafy)
end

@testset "prunebranch! targets the requested node" begin
    # A sibling holding the same data must not be mistaken for the target.
    root = Node(0)
    firstchild = addchild(root, 7)
    victim = addchild(root, 7)
    addchild(root, 9)
    prunebranch!(victim)
    @test [c.data for c in root] == [7, 9]
    @test collect(root)[1] === firstchild

    # The target is found even when an earlier sibling carries equal data.
    root = Node(0)
    addchild(root, 1)
    survivor = addchild(root, 5)
    addchild(root, 3)
    victim = addchild(root, 5)
    prunebranch!(victim)
    @test [c.data for c in root] == [1, 5, 3]
    @test collect(root)[2] === survivor
end

@testset "operations do not assume data equals itself" begin
    # `NaN` is not equal to itself, so tree queries and construction must rely
    # on object identity rather than on comparing data.
    r = Node(NaN)
    @test isroot(r)
    @test isleaf(r)
    @test islastsibling(r)

    child = addchild(r, 1.0)
    @test !isleaf(r)
    @test !isroot(child)
    @test child.parent === r
    @test [c.data for c in r] == [1.0]
end
