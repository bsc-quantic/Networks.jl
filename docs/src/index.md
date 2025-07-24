# Networks.jl

Networks.jl is a work-in-progress, alternative graph library in Julia. Designed to overcome the limitations of [Graphs.jl](https://github.com/JuliaGraphs/Graphs.jl) when custom graphs, hyperedges, multi-edges, or arbitrary vertex types are needed.

## Motivation

During the development of [Tenet.jl](https://github.com/bsc-quantic/Tenet.jl), several requirements arose that are not covered by [Graphs.jl](https://github.com/JuliaGraphs/Graphs.jl):

- Support for hyperedges, open edges, and multi-edges
- Graph types based on the incidence matrix
- Automatic method delegation for wrapping graph types, based on [DelegatorTraits.jl](https://github.com/bsc-quantic/DelegatorTraits.jl)
- Allowing vertices of any type, not just integers
- Interfaces that are extensible and better decoupled from concrete implementations

### The Edge entity

One of the biggest differences between the `AbstractGraph` and `Network` interfaces is that for `Network`, an edge is its own entity; i.e. an edge can be just an identifier like a UUID instead of a relation between two other objects.

This choice makes a `Network` a more abstract interface than `AbstractGraph`, where the description of a graph is not forced to be based on adjacency matrices.

## Basic Example

```@setup example
using Networks
```

Let's start by creating an `IncidentNetwork`, which implements a `Network` using a incidence matrix representation.
The first type parameterizes the vertex type, while the second one parameterizes the edge type.

```@repl example
g = IncidentNetwork{Symbol, Int}()
vertex_type(g)
edge_type(g)
```

Unlike [Graphs.jl](https://github.com/JuliaGraphs/Graphs.jl), you must explicitly pass the vertex to add it to a network.

```@repl example
addvertex!(g, :a)
addvertex!(g, :b)
addvertex!(g, :c)
vertices(g)
```

Edges are independent entities in an `IncidentNetwork`, so you must add it and then relate it to the vertices.

```@repl example
addedge!(g, 1)
edges(g)

Networks.link!(g, :a, 1)
Networks.link!(g, :b, 1)
Networks.link!(g, :c, 1)
```

In order to query the vertices connected by an edge, use `incident_vertices`:

```@repl example
incident_vertices(g, 1)
```

... and to query the edges connected to a vertex, use `incident_vertices`:

```@repl example
incident_edges(g, :a)
```
