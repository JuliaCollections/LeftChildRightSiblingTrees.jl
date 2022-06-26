
AbstractTrees.nodetype(::Type{<:Node{T}}) where T = Node{T}
AbstractTrees.NodeType(::Type{<:Node{T}}) where T = HasNodeType()

AbstractTrees.parent(node::Node) = node.parent ≡ node ? nothing : node.parent

AbstractTrees.ParentLinks(::Type{<:Node{T}}) where T = StoredParents()
AbstractTrees.SiblingLinks(::Type{<:Node{T}}) where T = StoredSiblings()

AbstractTrees.children(node::Node) = node

function AbstractTrees.nextsibling(node::Node)
    ns = node.sibling
    return node ≡ ns ? nothing : ns
end

AbstractTrees.nodevalue(node::Node) = node.data
