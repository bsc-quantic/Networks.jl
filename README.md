# Networks.jl

[![CI](https://github.com/bsc-quantic/Networks.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/bsc-quantic/Networks.jl/actions/workflows/CI.yml)
[![Documentation: stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://bsc-quantic.github.io/Networks.jl/)
[![Documentation: dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://bsc-quantic.github.io/Networks.jl/dev/)

> [!WARNING]
>  Networks.jl is still experimental, and the API can change. 

Networks.jl is a work-in-progress, alternative graph library in Julia. Designed to overcome the limitations of [Graphs.jl](https://github.com/JuliaGraphs/Graphs.jl) when custom graphs, hyperedges, multi-edges, or arbitrary vertex types are needed.

## Motivation

During the development of [Tenet.jl](https://github.com/bsc-quantic/Tenet.jl), several requirements arose that are not covered by [Graphs.jl](https://github.com/JuliaGraphs/Graphs.jl):

- Support for hyperedges, open edges, and multi-edges
- Graph types based on the incidence matrix
- Automatic method delegation for wrapping graph types, based on [DelegatorTraits.jl](https://github.com/bsc-quantic/DelegatorTraits.jl)
- Vertices of any type, not just `Integer`s
- Interfaces that are extensible and better decoupled from concrete implementations

### The Edge entity

One of the biggest differences between the `AbstractGraph` and `Network` interfaces is that for `Network`, an edge is its own entity; i.e. an edge can be just an identifier like a UUID instead of a relation between two other objects.

This choice makes a `Network` a more abstract interface than `AbstractGraph`, where the description of a graph is not forced to be based on adjacency matrices.

## Basic Example

Let's start by creating an `IncidentNetwork`, which implements a `Network` using a incidence matrix representation.
The first type parameterizes the vertex type, while the second one parameterizes the edge type.

```julia
julia> g = IncidentNetwork{Symbol, Int}();

julia> vertex_type(g)
Symbol

julia> edge_type(g)
Int64
```

Unlike [Graphs.jl](https://github.com/JuliaGraphs/Graphs.jl), you must explicitly pass the vertex to add it to a network.

```julia
julia> addvertex!(g, :a);

julia> addvertex!(g, :b);

julia> addvertex!(g, :c);

julia> vertices(g)
KeySet for a Dict{Symbol, Set{Int64}} with 3 entries. Keys:
  :a
  :b
  :c
```

Edges are independent entities in an `IncidentNetwork`, so you must add it and then relate it to the vertices.

```julia
julia> addedge!(g, 1);

julia> edges(g)
KeySet for a Dict{Int64, Set{Symbol}} with 1 entry. Keys:
  1

julia> Networks.link!(g, :a, 1);
julia> Networks.link!(g, :b, 1);
julia> Networks.link!(g, :c, 1);
```

In order to query the vertices connected by an edge, use `incident_vertices`:

```julia
julia> incident_vertices(g, 1)
Set{Symbol} with 3 elements:
  :a
  :b
  :c
```

... and to query the edges connected to a vertex, use `incident_edges`:

```julia
julia> incident_edges(g, :a)
Set{Int64} with 1 element:
  1
```
