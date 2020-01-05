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

## Credits

This existed as an internal component of
[ProfileView](https://github.com/timholy/ProfileView.jl)
since its inception until it was split out as an independent package.
