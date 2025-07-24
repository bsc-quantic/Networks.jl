# Interfaces

Networks.jl uses [DelegatorTraits.jl](https://github.com/bsc-quantic/DelegatorTraits.jl) for method delegation: a type wrapping a `Network` implementor can "inherit" (in reality, delegate) its method definitions by just declaring:

```julia
DelegatorTraits.DelegatorTrait(::Network, ::MyWrapperType) = DelegatorTraits.DelegateToField{:the_field_name}()
```

Using [`DelegatorTraits.jl`](https://github.com/bsc-quantic/DelegatorTraits.jl) is completely optional and you can still do method delegation manually.

## Network

The `Network` interface abstracts a network or graph. Unlike other graph interfaces, `Network` considers edges as first-class objects and not just as
relations of vertices. This allows for a more relaxed abstraction where self-loops, open-edges, multi-edges and hyper-edges are allowed.
A type implementing the `Network` interface must implement the following methods:

| Required method           | Description                                      |
| :------------------------ | :----------------------------------------------- |
| `all_vertices(g)`         | Returns the list of vertices                     |
| `all_edges(g)`            | Returns the list of edges                        |
| `incident_vertices(g, e)` | Returns the vertices connected by edge `e`       |
| `incident_edges(g, v)`    | Returns the edges conected to vertex `v`         |
| `neighbor_vertices(g, v)` | Returns the vertices neighboring vertex `v`      |
| `neighbor_edges(g, e)`    | Returns the edges neighboring edge `e`           |
| `Directedness(::Type{G})` | Returns the directedness trait of graph type `G` |

### Optional methods

The following methods have a default implementation or their implementation is optional.

| Method              | When should this method be defined?                  | Default definition    | Brief description                                      |
| :------------------ | :--------------------------------------------------- | :-------------------- | :----------------------------------------------------- |
| `vertex_type(g)`    | If your vertex type is type-stable                   | `Any`                 | Returns the type used for representing a vertex        |
| `edge_type(g)`      | If your edge type is type-stable                     | `Any`                 | Returns the type used for representing an edge         |
| `hasvertex(g, v)`   | If there is a more performant way                    | `v in vertices(g)`    | Returns `true` if vertex `v` is present in network `g` |
| `hasedge(g, e)`     | If there is a more performant way                    | `e in edges(g)`       | Returns `true` if edge `e` is present in network `e`   |
| `nvertices(g)`      | If there is a more performant way                    | `length(vertices(g))` | Returns the number of vertices present in the network  |
| `nedges(g)`         | If there is a more performant way                    | `length(edges(g))`    | Returns the number of edges present in the network     |
| `vertex_at(g, tag)` | If your type has some other way to refer to a vertex | _(undefined)_         | Returns the vertex related to `tag`                    |
| `edge_at(g, tag)`   | If your type has some other way to refer to an edge  | _(undefined)_         | Returns the edge related to `tag`                      |

### Directed methods

If your `Network` implementation represents a directed graph, the following methods are required:

!!! warning

    Directedness on hypergraphs is not well-defined. It is such an edge case, that we have decide to don't support it explicitly for the time being.

| Required method              | Description                                       |
| :--------------------------- | :------------------------------------------------ |
| `incoming_edges(g, v)`       | Returns the edges incoming to vertex `v`          |
| `outgoing_edges(g, v)`       | Returns the vertices outgoing from vertex `v`     |
| `source_vertex(g, e)`        | Returns the source vertex of edge `e`             |
| `destination_vertex(g, e)`   | Returns the destination vertex of edge `e`        |
| `predecessor_vertices(g, v)` | Returns the vertices that are predecessors of `v` |
| `successor_vertices(g, v)`   | Returns the vertices that are successors of `v`   |

### Mutating methods

| Method            | Brief description                               |
| :---------------- | :---------------------------------------------- |
| `addvertex!(g,v)` | Adds vertex `v` to network `g`                  |
| `addedge!(g,e)`   | Adds edge `e` to network `g`                    |
| `rmvertex!(g,v)`  | Removes vertex `v` from network `g`             |
| `rmedge!(g,e)`    | Removes edge `e` from network `g`               |
| `link!(g,v,e)`    | Declares that edge `e` connects to vertex `v`   |
| `unlink!(g,v,e)`  | Undeclares that edge `e` connects to vertex `v` |

The [`EdgePersistence`](@ref Networks.EdgePersistence) trait defines the behavior of edges when a vertex is removed. It currently has 3 traits:

- `PersistEdges`: edges are **never** removed implicitly
- `RemoveEdges`: edges are **always** removed implicitly
- `PruneEdges`: edges are removed if left stranded (i.e. no other vertex is linked with it) (default)

## Taggable

WIP

## Attributeable

WIP
