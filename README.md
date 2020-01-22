# LeftChildRightSiblingTrees

A [left child, right sibling tree](https://en.wikipedia.org/wiki/Left-child_right-sibling_binary_tree)
(frequently abbreviated as "LCRS")
is a rooted tree data structure that allows a parent node to have multiple child nodes.
Rather than maintain a list of children (which requires one array per node),
instead it is represented as a binary tree, where the "left" branch is the first child,
whose "right" branch points to its first sibling.

Concretely, suppose a particular node, `A`, has 3 children, `a`, `b`, and `c`. Then:

- `a`, `b`, and `c` link to `A` as their parent.
- `A` links `a` as its child (via `A`'s left branch); `a` links `b` as its sibling
  (via `a`'s right branch), and `b` links `c` as its sibling (via `b`'s right branch).
- `A`'s right branch would link to any of its siblings (e.g., `B`), if they exist.
- Any missing links (e.g., `c` does not have a sibling) link back to itself
  (`c.sibling == c`).

## Tradeoffs

An LCRS tree is typically more memory efficient than an equivalent multi-way tree
representation that uses an array to store the children of each node.
However, for certain tasks it can be less performant, because some operations that modify
the tree structure require iterating over all the children of a node.

## Demo
### Creating a Tree

Can `addchild` or `addsibling`.
```julia
julia> using LeftChildRightSiblingTrees

julia> mum = Node("Mum");

julia> me = addchild(mum, "Me");

julia> son = addchild(me, "Son");

julia> daughter = addchild(me, "Daughter");

julia> brother = addsibling(me, "Brother");  # equivalent: to `addchild(mum, "Brother")`
```

### Querying about nodes:

```julia
julia> lastsibling(me)
Node(Brother)

julia> isroot(mum)
true

julia> isleaf(me)
false

julia> isleaf(daughter)
true
```

### Iterating the Tree/Nodes
Iteration goes through all (direct) children.
The `.data` field holds the information put in the tree.
we can use this to draw a simple visualization of the tree via recursion.

```julia
julia> for child in mum
           println(child)
       end
Node(Me)
Node(Brother)

julia> function showtree(node, indent=0)
           println("\t"^indent, node.data)
           for child in node
               showtree(child, indent + 1)
           end
       end
showtree (generic function with 2 methods)

julia> showtree(mum)
Mum
        Me
                Son
                Daughter
        Brother
```

LeftChildRightSiblingTrees also has a built in function for showing this kind of info:
```julia
julia> LeftChildRightSiblingTrees.showedges(mum)
Mum has the following children: Me    Brother
Me has the following children: Son    Daughter
Son has no children
Daughter has no children
Brother has no children
```

## Manipulating the tree

See the docstrings for `graftchildren!` and `prunebranch!`.

## Credits

This existed as an internal component of
[ProfileView](https://github.com/timholy/ProfileView.jl)
since its inception until it was split out as an independent package.
