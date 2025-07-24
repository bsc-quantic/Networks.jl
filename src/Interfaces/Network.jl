struct Network <: Interface end

# auxiliar types
abstract type AbstractNetwork end

abstract type AbstractVertex end
struct Vertex{T} <: AbstractVertex
    id::T
end

abstract type AbstractEdge end
struct Edge{T} <: AbstractEdge
    id::T
end

# traits
"""
    EdgePersistence

Trait for edge persitence in a [`Network`](@ref). It defines the behavior of edges when a vertex is removed.
The following traits are defined:

  - `PersistEdges`: edges are **never** removed implicitly.
  - `RemoveEdges`: edges are **always** removed implicitly.
  - `PruneEdges` (default): edges are removed if left stranded (i.e. no other vertex is linked with it).
"""
abstract type EdgePersistence end
struct PersistEdges <: EdgePersistence end
struct RemoveEdges <: EdgePersistence end
struct PruneEdges <: EdgePersistence end

EdgePersistence(graph) = EdgePersistence(graph, DelegatorTrait(Network(), graph))
EdgePersistence(graph, ::DelegateToField) = EdgePersistence(delegator(Network(), graph))
EdgePersistence(graph, ::DontDelegate) = PruneEdges()

"""
    Directedness

Trait for the directedness of a [`Network`](@ref). It defines whether the network is `Directed` or `Undirected`.
"""
abstract type Directedness end
struct Directed <: Directedness end
struct Undirected <: Directedness end
# struct Hybrid <: Directedness end

Directedness(graph) = Directedness(graph, DelegatorTrait(Network(), graph))
Directedness(graph, ::DelegateToField) = Directedness(delegator(Network(), graph))
Directedness(graph, ::DontDelegate) = throw(MethodError(Directedness, (graph,)))

# query methods
function vertices end
function edges end
function neighbors end

function vertex end
function edge end

"""
    all_vertices(graph)

Returns the vertices in the `graph`.
"""
function all_vertices end

"""
    all_edges(graph)

Returns the edges in the `graph`.
"""
function all_edges end

"""
    incident_vertices(graph, e)

Returns the vertices connected by edge `e` in `graph`.
"""
function incident_vertices end
@deprecate edge_incidents(args...; kwargs...) incident_vertices(args...; kwargs...) true

"""
    incident_edges(graph, v)

Returns the edges connected to vertex `v` in `graph`.
"""
function incident_edges end
@deprecate vertex_incidents(args...; kwargs...) incident_edges(args...; kwargs...) true

"""
    neighbor_vertices(graph, v)

Returns the vertices neighboring vertex `v` in the `graph`; i.e. those that share an edge with vertex `v`.
"""
function neighbor_vertices end
@deprecate vertex_neighbors(args...; kwargs...) neighbor_vertices(args...; kwargs...) true

"""
    neighbor_edges(graph, e)

Returns the edges neighboring edge `e` in the `graph`; i.e. those that share a vertex with edge `e`.
"""
function neighbor_edges end
@deprecate edge_neighbors(args...; kwargs...) neighbor_edges(args...; kwargs...) true

# query methods with default implementation
"""
    vertex_type(graph)

Returns the type of vertices in the `graph`. Defaults to `Any`.
"""
function vertex_type end

"""
    edge_type(graph)

Returns the type of edges in the `graph`. Defaults to `Any`.
"""
function edge_type end

"""
    hasvertex(graph, v)

Returns `true` if vertex `v` exists in the `graph`.
"""
function hasvertex end

"""
    hasedge(graph, e)

Returns `true` if edge `e` exists in the `graph`.
"""
function hasedge end

"""
    nvertices(graph)

Returns the number of vertices in the `graph`.
"""
function nvertices end

"""
    nedges(graph)

Returns the number of edges in the `graph`.
"""
function nedges end

function edges_set_strand end
function edges_set_open end
function edges_set_hyper end

function vertex_at end
function edge_at end

# directed methods
"""
    incoming_edges(graph, v)

Returns the edges incoming to vertex `v` in `graph`.
"""
function incoming_edges end

"""
    outgoing_edges(graph, v)

Returns the edges outgoing from vertex `v` in `graph`.
"""
function outgoing_edges end

"""
    source_vertex(graph, g)

Returns the source vertex of edge `e` in `graph`.
"""
function source_vertex end

"""
    destination_vertex(graph, e)

Returns the destination vertex of edge `e` in `graph`.
"""
function destination_vertex end

"""
    predecessor_vertices(graph, v)

Returns the vertices that are predecessors of vertex `v` in `graph`.
"""
function predecessor_vertices end

"""
    successor_vertices(graph, v)

Returns the vertices that are successors of vertex `v` in `graph`.
"""
function successor_vertices end

# mutating methods
"""
    addvertex!(graph, v)

Adds vertex `v` to the `graph`.
"""
function addvertex! end

"""
    addedge!(graph, e)

Adds edge `e` to the `graph`.
"""
function addedge! end

"""
    rmvertex!(graph, v)

Removes vertex `v` from the `graph`.
"""
function rmvertex! end

"""
    rmedge!(graph, e)

Removes edge `e` from the `graph`.
"""
function rmedge! end

"""
    link!(graph, v, e)

Links vertex `v` with edge `e` in the `graph`.
"""
function link! end

"""
    unlink!(graph, v, e)

Unlinks vertex `v` from edge `e` in the `graph`.
"""
function unlink! end

function prune_edges! end

# implementation
## `vertices`
vertices(graph; kwargs...) = vertices(sort_nt(kwargs), graph)
vertices(::NamedTuple{}, graph) = all_vertices(graph)

## `edges`
edges(graph; kwargs...) = edges(sort_nt(kwargs), graph)
edges(::NamedTuple{}, graph) = all_edges(graph)
function edges(::@NamedTuple{set::Symbol}, graph)
    if set == :open
        return edges_set_open(graph)
    elseif set == :strand
        return edges_set_strand(graph)
    elseif set == :hyper
        return edges_set_hyper(graph)
    else
        throw(ArgumentError("Unknown edge set: $set"))
    end
end

## `neighbors`
neighbors(graph; kwargs...) = neighbors(sort_nt(kwargs), graph, v)
neighbors(graph, v::AbstractVertex) = neighbor_vertices(graph, v)
neighbors(kwargs::NamedTuple{(:vertex,)}, graph) = neighbor_vertices(graph, kwargs.v)
neighbors(graph, e::AbstractEdge) = neighbor_edges(graph, e)
neighbors(kwargs::NamedTuple{(:edge,)}, graph) = neighbor_edges(graph, kwargs.e)

## `all_vertices`
all_vertices(graph) = all_vertices(graph, DelegatorTrait(Network(), graph))
all_vertices(graph, ::DelegateToField) = all_vertices(delegator(Network(), graph))
all_vertices(graph, ::DontDelegate) = throw(MethodError(all_vertices, (graph,)))

## `all_edges`
all_edges(graph) = all_edges(graph, DelegatorTrait(Network(), graph))
all_edges(graph, ::DelegateToField) = all_edges(delegator(Network(), graph))
all_edges(graph, ::DontDelegate) = throw(MethodError(all_edges, (graph,)))

## `incident_vertices`
incident_vertices(graph, e) = incident_vertices(graph, e, DelegatorTrait(Network(), graph))
incident_vertices(graph, e, ::DelegateToField) = incident_vertices(delegator(Network(), graph), e)
incident_vertices(graph, e, ::DontDelegate) = throw(MethodError(incident_vertices, (graph, e)))

## `incident_edges`
incident_edges(graph, v) = incident_edges(graph, v, DelegatorTrait(Network(), graph))
incident_edges(graph, v, ::DelegateToField) = incident_edges(delegator(Network(), graph), v)
incident_edges(graph, v, ::DontDelegate) = throw(MethodError(incident_edges, (graph, v)))

## `neighbor_vertices`
neighbor_vertices(graph, v) = neighbor_vertices(graph, v, DelegatorTrait(Network(), graph))
neighbor_vertices(graph, v, ::DelegateToField) = neighbor_vertices(delegator(Network(), graph), v)
function neighbor_vertices(graph, v, ::DontDelegate)
    fallback(neighbor_vertices)
    incident_edges = incident_edges(graph, v)
    neighbors = Set{vertex_type(graph)}()
    for edge in incident_edges
        edge_vertices = incident_vertices(graph, edge)
        for neighbor in edge_vertices
            if neighbor != v
                push!(neighbors, neighbor)
            end
        end
    end
    return neighbors
end

## `neighbor_edges`
neighbor_edges(graph, e) = neighbor_edges(graph, e, DelegatorTrait(Network(), graph))
neighbor_edges(graph, e, ::DelegateToField) = neighbor_edges(delegator(Network(), graph), e)
function neighbor_edges(graph, e, ::DontDelegate)
    fallback(neighbor_edges)
    incident_vertices = incident_vertices(graph, e)
    neighbors = Set{edge_type(graph)}()
    for vertex in incident_vertices
        vertex_edges = incident_edges(graph, vertex)
        for neighbor in vertex_edges
            if neighbor != e
                push!(neighbors, neighbor)
            end
        end
    end
    return neighbors
end

## `vertex_type`
vertex_type(graph) = vertex_type(graph, DelegatorTrait(Network(), graph))
vertex_type(graph, ::DelegateToField) = vertex_type(delegator(Network(), graph))
function vertex_type(graph, ::DontDelegate)
    fallback(vertex_type)
    return Any # mapreduce(typeof, typejoin, vertices(graph))
end

## `edge_type`
edge_type(graph) = edge_type(graph, DelegatorTrait(Network(), graph))
edge_type(graph, ::DelegateToField) = edge_type(delegator(Network(), graph))
function edge_type(graph, ::DontDelegate)
    fallback(edge_type)
    return Any # mapreduce(typeof, typejoin, edges(graph))
end

## `hasvertex`
hasvertex(graph, v) = hasvertex(graph, v, DelegatorTrait(Network(), graph))
hasvertex(graph, v, ::DelegateToField) = hasvertex(delegator(Network(), graph), v)
function hasvertex(graph, v, ::DontDelegate)
    fallback(hasvertex)
    return v in vertices(graph)
end

## `hasedge`
hasedge(graph, e) = hasedge(graph, e, DelegatorTrait(Network(), graph))
hasedge(graph, e, ::DelegateToField) = hasedge(delegator(Network(), graph), e)
function hasedge(graph, e, ::DontDelegate)
    fallback(hasedge)
    return e in edges(graph)
end

## `nvertices`
nvertices(graph) = nvertices(graph, DelegatorTrait(Network(), graph))
nvertices(graph, ::DelegateToField) = nvertices(delegator(Network(), graph))
function nvertices(graph, ::DontDelegate)
    fallback(nvertices)
    return length(vertices(graph))
end

## `nedges`
nedges(graph) = nedges(graph, DelegatorTrait(Network(), graph))
nedges(graph, ::DelegateToField) = nedges(delegator(Network(), graph))
function nedges(graph, ::DontDelegate)
    fallback(nedges)
    return length(edges(graph))
end

## `vertex_at`
vertex_at(graph, tag) = vertex_at(graph, tag, DelegatorTrait(Network(), graph))
vertex_at(graph, tag, ::DelegateToField) = vertex_at(delegator(Network(), graph), tag)
vertex_at(graph, tag, ::DontDelegate) = throw(MethodError(vertex_at, (graph, tag)))

## `edge_at`
edge_at(graph, tag) = edge_at(graph, tag, DelegatorTrait(Network(), graph))
edge_at(graph, tag, ::DelegateToField) = edge_at(delegator(Network(), graph), tag)
edge_at(graph, tag, ::DontDelegate) = throw(MethodError(edge_at, (graph, tag)))

## `edges_set_strand`
edges_set_strand(graph) = edges_set_strand(graph, DelegatorTrait(Network(), graph))
edges_set_strand(graph, ::DelegateToField) = edges_set_strand(delegator(Network(), graph))
function edges_set_strand(graph, ::DontDelegate)
    fallback(edges_set_strand)
    stranded_edges = Set{edge_type(graph)}()
    for edge in edges(graph)
        vertex_set = incident_vertices(graph, edge)
        if length(vertex_set) == 0
            push!(stranded_edges, edge)
        end
    end
    return stranded_edges
end

## `edges_set_open`
edges_set_open(graph) = edges_set_open(graph, DelegatorTrait(Network(), graph))
edges_set_open(graph, ::DelegateToField) = edges_set_open(delegator(Network(), graph))
function edges_set_open(graph, ::DontDelegate)
    fallback(edges_set_open)
    stranded_edges = Set{edge_type(graph)}()
    for edge in edges(graph)
        vertex_set = incident_vertices(graph, edge)
        if length(vertex_set) == 1
            push!(stranded_edges, edge)
        end
    end
    return stranded_edges
end

## `edges_set_hyper`
edges_set_hyper(graph) = edges_set_hyper(graph, DelegatorTrait(Network(), graph))
edges_set_hyper(graph, ::DelegateToField) = edges_set_hyper(delegator(Network(), graph))
function edges_set_hyper(graph, ::DontDelegate)
    stranded_edges = Set{edge_type(graph)}()
    for edge in edges(graph)
        vertex_set = incident_vertices(graph, edge)
        if length(vertex_set) > 2
            push!(stranded_edges, edge)
        end
    end
    return stranded_edges
end

## `incoming_edges`
incoming_edges(graph, v) = incoming_edges(graph, v, DelegatorTrait(Network(), graph))
incoming_edges(graph, v, ::DelegateToField) = incoming_edges(delegator(Network(), graph), v)
incoming_edges(graph, v, ::DontDelegate) = throw(MethodError(incoming_edges, (graph, v)))

## `outgoing_edges`
outgoing_edges(graph, v) = outgoing_edges(graph, v, DelegatorTrait(Network(), graph))
outgoing_edges(graph, v, ::DelegateToField) = outgoing_edges(delegator(Network(), graph), v)
outgoing_edges(graph, v, ::DontDelegate) = throw(MethodError(outgoing_edges, (graph, v)))

## `source_vertex`
source_vertex(graph, e) = source_vertex(graph, e, DelegatorTrait(Network(), graph))
source_vertex(graph, e, ::DelegateToField) = source_vertex(delegator(Network(), graph), e)
source_vertex(graph, e, ::DontDelegate) = throw(MethodError(source_vertex, (graph, e)))

## `destination_vertex`
destination_vertex(graph, e) = destination_vertex(graph, e, DelegatorTrait(Network(), graph))
destination_vertex(graph, e, ::DelegateToField) = destination_vertex(delegator(Network(), graph), e)
destination_vertex(graph, e, ::DontDelegate) = throw(MethodError(destination_vertex, (graph, e)))

### `neighbor_vertices`
neighbor_vertices(graph, v) = neighbor_vertices(graph, v, DelegatorTrait(Network(), graph))
neighbor_vertices(graph, v, ::DelegateToField) = neighbor_vertices(delegator(Network(), graph), v)
neighbor_vertices(graph, v, ::DontDelegate) = throw(MethodError(neighbor_vertices, (graph, v)))

### `neighbor_edges`
neighbor_edges(graph, e) = neighbor_edges(graph, e, DelegatorTrait(Network(), graph))
neighbor_edges(graph, e, ::DelegateToField) = neighbor_edges(delegator(Network(), graph), e)
neighbor_edges(graph, e, ::DontDelegate) = throw(MethodError(neighbor_edges, (graph, e)))

### `predecessor_vertices`
predecessor_vertices(graph, v) = predecessor_vertices(graph, v, DelegatorTrait(Network(), graph))
predecessor_vertices(graph, v, ::DelegateToField) = predecessor_vertices(delegator(Network(), graph), v)
predecessor_vertices(graph, v, ::DontDelegate) = throw(MethodError(predecessor_vertices, (graph, v)))

### `successor_vertices`
successor_vertices(graph, v) = successor_vertices(graph, v, DelegatorTrait(Network(), graph))
successor_vertices(graph, v, ::DelegateToField) = successor_vertices(delegator(Network(), graph), v)
successor_vertices(graph, v, ::DontDelegate) = throw(MethodError(successor_vertices, (graph, v)))

## `addvertex!`
# TODO check if vertex already exists
#   hasvertex(graph, e.vertex) && throw(ArgumentError("Vertex $(e.vertex) already exists in network"))
addvertex!(graph, v) = addvertex!(graph, v, DelegatorTrait(Network(), graph))
addvertex!(graph, v, ::DelegateToField) = addvertex!(delegator(Network(), graph), v)
addvertex!(graph, v, ::DontDelegate) = throw(MethodError(addvertex!, (graph, v)))

## `addedge!`
# TODO check if edge already exists
#   hasedge(graph, e.edge) && throw(ArgumentError("Edge $(e.edge) already exists in network"))
addedge!(graph, e) = addedge!(graph, e, DelegatorTrait(Network(), graph))
addedge!(graph, e, ::DelegateToField) = addedge!(delegator(Network(), graph), e)
addedge!(graph, e, ::DontDelegate) = throw(MethodError(addedge!, (graph, e)))

## `rmvertex!`
# TODO check if vertex exists
#   hasvertex(graph, v) || throw(ArgumentError("Vertex $(v) not found in network"))
rmvertex!(graph, v) = rmvertex!(graph, v, DelegatorTrait(Network(), graph))
rmvertex!(graph, v, ::DelegateToField) = rmvertex!(delegator(Network(), graph), v)
rmvertex!(graph, v, ::DontDelegate) = throw(MethodError(rmvertex!, (graph, v)))

# rmvertex!(graph, v) = rmvertex!(graph, v, EdgePersistence(graph))

# function rmvertex!(graph, v, ::PersistEdges)
#     checkeffect(graph, RemoveVertexEffect(v))
#     rmvertex_inner!(graph, v)

#     # TODO call `unlink!` on the vertex-edge?
#     # - needed for incidence matrix-implementations
#     # - adjacency matrix-implementations cannot process `unlink!` because overlaps with `rmedge!`

#     handle!(graph, RemoveVertexEffect(v))
#     return graph
# end

# function rmvertex!(graph, v, ::RemoveEdges)
#     checkeffect(graph, RemoveVertexEffect(v))

#     # trait is to remove edges on vertex removal
#     for edge in incident_edges(graph, v)
#         rmedge!(graph, edge)
#     end

#     rmvertex_inner!(graph, v)
#     handle!(graph, RemoveVertexEffect(v))
#     return graph
# end

# function rmvertex!(graph, v, ::PruneEdges)
#     checkeffect(graph, RemoveVertexEffect(v))

#     # trait is to remove edges on vertex removal if that leaves them stranded
#     # (i.e. no open indices left)
#     for edge in incident_edges(graph, v)
#         if length(incident_vertices(graph, edge)) == 1
#             rmedge!(graph, edge)
#         end
#     end

#     # TODO call `unlink!` on the vertex-edge?
#     # - needed for incidence matrix-implementations
#     # - adjacency matrix-implementations cannot process `unlink!` because overlaps with `rmedge!`

#     rmvertex_inner!(graph, v)
#     handle!(graph, RemoveVertexEffect(v))
#     return graph
# end

## `rmedge!`
# TODO check if edge exists
# TODO call `unlink!` on the edge?
#   hasedge(graph, e) || throw(ArgumentError("Edge $(e) not found in network"))
rmedge!(graph, e) = rmedge!(graph, e, DelegatorTrait(Network(), graph))
rmedge!(graph, e, ::DelegateToField) = rmedge!(delegator(Network(), graph), e)
rmedge!(graph, e, ::DontDelegate) = throw(MethodError(rmedge!, (graph, e)))

## `link!`
# TODO check if vertex and edge exist
#   hasvertex(graph, e.vertex) || throw(ArgumentError("Vertex $(e.vertex) not found in network"))
#   hasedge(graph, e.edge) || throw(ArgumentError("Edge $(e.edge) not found in network"))
link!(graph, v, e) = link!(graph, v, e, DelegatorTrait(Network(), graph))
link!(graph, v, e, ::DelegateToField) = link!(delegator(Network(), graph), v, e)
link!(graph, v, e, ::DontDelegate) = throw(MethodError(link!, (graph, v, e)))

## `unlink!
# TODO check if vertex and edge exist
#   hasvertex(graph, e.vertex) || throw(ArgumentError("Vertex $(e.vertex) not found in network"))
#   hasedge(graph, e.edge) || throw(ArgumentError("Edge $(e.edge) not found in network"))
unlink!(graph, v, e) = unlink!(graph, v, e, DelegatorTrait(Network(), graph))
unlink!(graph, v, e, ::DelegateToField) = unlink!(delegator(Network(), graph), v, e)
unlink!(graph, v, e, ::DontDelegate) = throw(MethodError(unlink!, (graph, v, e)))

## `prune_edges!`
function prune_edges!(graph)
    for edge in edges_set_strand(graph)
        rmedge!(graph, edge)
    end
    return graph
end
