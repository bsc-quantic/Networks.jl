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
    EdgePersistenceTrait

Trait for edge persitence in a [`Network`](@ref). It defines the behavior of edges when a vertex is removed.
The following traits are defined:

  - `PersistEdges`: edges are **never** removed implicitly.
  - `RemoveEdges`: edges are **always** removed implicitly.
  - `PruneEdges` (default): edges are removed if left stranded (i.e. no other vertex is linked with it).
"""
abstract type EdgePersistenceTrait end
struct PersistEdges <: EdgePersistenceTrait end
struct RemoveEdges <: EdgePersistenceTrait end
struct PruneEdges <: EdgePersistenceTrait end

EdgePersistenceTrait(graph) = EdgePersistenceTrait(graph, DelegatorTrait(Network(), graph))
EdgePersistenceTrait(graph, ::DelegateToField) = EdgePersistenceTrait(delegator(Network(), graph))
EdgePersistenceTrait(graph, ::DontDelegate) = PruneEdges()

# query methods
function vertices end
function edges end

function vertex end
function edge end

function edge_incidents end
function vertex_incidents end

:(Base.copy)

# query methods with default implementation
function vertex_type end
function edge_type end

function hasvertex end
function hasedge end

function nvertices end
function nedges end

function edges_set_strand end
function edges_set_open end
function edges_set_hyper end

# mutating methods
function addvertex! end
function addedge! end
function rmvertex! end
function rmedge! end
function link! end
function unlink! end
function prune_edges! end

# implementation
## `vertices`
vertices(graph) = vertices(graph, DelegatorTrait(Network(), graph))
vertices(graph, ::DelegateToField) = vertices(delegator(Network(), graph))
vertices(graph, ::DontDelegate) = throw(MethodError(vertices, (graph,)))

## `edges`
edges(graph) = edges(graph, DelegatorTrait(Network(), graph))
edges(graph, ::DelegateToField) = edges(delegator(Network(), graph))
edges(graph, ::DontDelegate) = throw(MethodError(edges, (graph,)))

## `edge_incidents`
edge_incidents(graph, e) = edge_incidents(graph, e, DelegatorTrait(Network(), graph))
edge_incidents(graph, e, ::DelegateToField) = edge_incidents(delegator(Network(), graph), e)
edge_incidents(graph, e, ::DontDelegate) = throw(MethodError(edge_incidents, (graph, e)))

## `vertex_incidents`
vertex_incidents(graph, v) = vertex_incidents(graph, v, DelegatorTrait(Network(), graph))
vertex_incidents(graph, v, ::DelegateToField) = vertex_incidents(delegator(Network(), graph), v)
vertex_incidents(graph, v, ::DontDelegate) = throw(MethodError(vertex_incidents, (graph, v)))

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

## `edges_set_strand`
edges_set_strand(graph) = edges_set_strand(graph, DelegatorTrait(Network(), graph))
edges_set_strand(graph, ::DelegateToField) = edges_set_strand(delegator(Network(), graph))
function edges_set_strand(graph, ::DontDelegate)
    fallback(edges_set_strand)
    stranded_edges = Set{edge_type(graph)}()
    for edge in edges(graph)
        vertex_set = edge_incidents(graph, edge)
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
        vertex_set = edge_incidents(graph, edge)
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
        vertex_set = edge_incidents(graph, edge)
        if length(vertex_set) > 2
            push!(stranded_edges, edge)
        end
    end
    return stranded_edges
end

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

# rmvertex!(graph, v) = rmvertex!(graph, v, EdgePersistenceTrait(graph))

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
#     for edge in vertex_incidents(graph, v)
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
#     for edge in vertex_incidents(graph, v)
#         if length(edge_incidents(graph, edge)) == 1
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
