module LeftChildRightSiblingTrees

# See `abstracttrees.jl` for the only dependency of this package

export Node,
    addchild,
    addsibling,
    depth,
    graftchildren!,
    isroot,
    isleaf,
    islastsibling,
    lastsibling,
    prunebranch!

mutable struct Node{T}
    data::T
    parent::Node{T}
    child::Node{T}
    sibling::Node{T}

    """
        root = Node(data)

    Construct a disconnected node, which can serve as the root of a new tree.
    `root.data` holds `data`.
    """
    function Node{T}(data) where T
        n = new{T}(data)
        n.parent = n
        n.child = n
        n.sibling = n
        n
    end

    """
        node = Node(data, parent::Node)

    Construct a `node` with `parent` as its parent node. `node.data` stores `data`.
    Node that this does *not* update any links in, e.g., `parent`'s other children.

    For a higher-level interface, see [`addchild`](@ref).
    """
    function Node{T}(data, parent::Node) where T
        n = new{T}(data, parent)
        n.child = n
        n.sibling = n
        n
    end
end
Node(data::T) where {T} = Node{T}(data)
Node(data, parent::Node{T}) where {T} = Node{T}(data, parent)

"""
    node = lastsibling(child)

Return the last sibling of `child`.
"""
function lastsibling(sib::Node)
    newsib = sib.sibling
    while !islastsibling(sib)
        sib = newsib
        newsib = sib.sibling
    end
    sib
end

"""
    node = addsibling(oldersib, data)

Append a new "youngest" sibling, storing `data` in `node`. `oldersib` must be
the previously-youngest sibling (see [`lastsibling`](@ref)).
"""
function addsibling(oldersib::Node{T}, data) where T
    if oldersib.sibling != oldersib
        error("Truncation of sibling list")
    end
    youngersib = Node(data, oldersib.parent)
    oldersib.sibling = youngersib
    youngersib
end

"""
    node = addchild(parent::Node, data)

Create a new child of `parent`, storing `data` in `node.data`.
This adjusts all links to ensure the integrity of the tree.
"""
function addchild(parent::Node{T}, data) where T
    newc = Node(data, parent)
    prevc = parent.child
    if prevc == parent
        parent.child = newc
    else
        prevc = lastsibling(prevc)
        prevc.sibling = newc
    end
    newc
end

"""
    isroot(node)

Returns `true` if `node` is the root of a tree (meaning, it is its own parent).
"""
isroot(n::Node) = n == n.parent

"""
    islastsibling(node)

Returns `true` if `node` is the last sibling
"""
islastsibling(n::Node) = n === n.sibling

"""
    isleaf(node)

Returns `true` if `node` has no children.
"""
isleaf(n::Node) = n == n.child

makeleaf!(n::Node) = n.child = n

makelastsibling!(n::Node) = n.sibling = n

Base.show(io::IO, n::Node) = print(io, "Node(", n.data, ')')

# Iteration over children
# for c in parent
#     # do something
# end
Base.IteratorSize(::Type{<:Node}) = Base.SizeUnknown()
Base.eltype(::Type{Node{T}}) where T = Node{T}

function Base.iterate(n::Node, state::Node = n.child)
    n === state && return nothing
    return state, islastsibling(state) ? n : state.sibling
end

# To support Base.pairs
struct PairIterator{T}
    parent::Node{T}
end
Base.pairs(node::Node) = PairIterator(node)
Base.IteratorSize(::Type{<:PairIterator}) = Base.SizeUnknown()

function Base.iterate(iter::PairIterator, state::Node=iter.parent.child)
    iter.parent === state && return nothing
    return state=>state, islastsibling(state) ? iter.parent : state.sibling
end

function showedges(io::IO, parent::Node, printfunc = identity)
    str = printfunc(parent.data)
    if str != nothing
        if isleaf(parent)
            println(io, str, " has no children")
        else
            print(io, str, " has the following children: ")
            for c in parent
                print(io, printfunc(c.data), "    ")
            end
            print(io, "\n")
            for c in parent
                showedges(io, c, printfunc)
            end
        end
    end
end
showedges(parent::Node) = showedges(stdout, parent)

depth(node::Node) = depth(node, 1)
function depth(node::Node, d)
    childd = d + 1
    for c in node
        d = max(d, depth(c, childd))
    end
    return d
end

"""
    graftchildren!(dest, src)

Move the children of `src` to become children of `dest`.
`src` becomes a leaf node.
"""
function graftchildren!(dest, src)
    for c in src
        c.parent = dest
    end
    if isleaf(dest)
        dest.child = src.child
    else
        lastsib = lastsibling(dest.child)
        lastsib.sibling = src.child
    end
    makeleaf!(src)
    return dest
end

"""
    prunebranch!(node)

Eliminate `node` and all its children from the tree.
"""
function prunebranch!(node)
    isroot(node) && error("cannot prune the root")
    p = node.parent
    if p.child == node
        # `node` is the first child of p
        if islastsibling(node)
            makeleaf!(p)   # p is now a leaf
        else
            p.child = node.sibling
        end
    else
        # `node` is a middle or last child of p
        child = p.child
        sib = child.sibling
        while sib != node
            @assert sib != child
            child = sib
            sib = child.sibling
        end
        if islastsibling(sib)
            # node is the last child of p, just truncate
            makelastsibling!(child)
        else
            # skip over node
            child.sibling = sib.sibling
        end
    end
    return p
end

include("abstracttrees.jl")

end # module
