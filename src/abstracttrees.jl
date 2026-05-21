
"""
    ChildIterator(node)

A lightweight iterator over the direct children of `node`. This is the value
returned by `AbstractTrees.children`; iterating it yields each child `Node`.
"""
struct ChildIterator{T}
    parent::Node{T}
end

Base.IteratorSize(::Type{<:ChildIterator}) = Base.SizeUnknown()
Base.eltype(::Type{ChildIterator{T}}) where T = Node{T}

Base.iterate(iter::ChildIterator) = iterate(iter.parent)
Base.iterate(iter::ChildIterator, state::Node) = iterate(iter.parent, state)

AbstractTrees.nodetype(::Type{<:Node{T}}) where T = Node{T}
AbstractTrees.NodeType(::Type{<:Node{T}}) where T = HasNodeType()

AbstractTrees.parent(node::Node) = node.parent ≡ node ? nothing : node.parent

AbstractTrees.ParentLinks(::Type{<:Node{T}}) where T = StoredParents()
AbstractTrees.SiblingLinks(::Type{<:Node{T}}) where T = StoredSiblings()

AbstractTrees.children(node::Node) = ChildIterator(node)

function AbstractTrees.nextsibling(node::Node)
    ns = node.sibling
    return node ≡ ns ? nothing : ns
end

AbstractTrees.nodevalue(node::Node) = node.data
