# This file provides support for the AbstractTrees interface.

using AbstractTrees

# Traits
Base.eltype(::Type{<:TreeIterator{Node{T}}}) where T = Node{T}
Base.IteratorEltype(::Type{<:TreeIterator{Node{T}}}) where T = Base.HasEltype()
Base.parent(node::Node, state::Node) = state.parent

AbstractTrees.parentlinks(::Type{Node{T}}) where T = AbstractTrees.StoredParents()
AbstractTrees.siblinglinks(::Type{Node{T}}) where T = AbstractTrees.StoredSiblings()
AbstractTrees.rootstate(node::Node) = node
AbstractTrees.children(node::Node) = node
function AbstractTrees.nextsibling(tree::Node, state::Node)
    ns = state.sibling
    return state === ns ? nothing : ns
end
AbstractTrees.printnode(io::IO, node::Node) = print(io, node.data)
