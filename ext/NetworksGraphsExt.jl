module NetworksGraphsExt

using Networks
using Networks: AbstractNetwork
using Graphs: Graphs
using DelegatorTraits
using Bijections

# generic interface compatibility
Graphs.nv(g::AbstractNetwork) = nvertices(g)
Graphs.ne(g::AbstractNetwork) = nedges(g)

Networks.nvertices(g::Graphs.AbstractGraph) = Graphs.nv(g)
Networks.nedges(g::Graphs.AbstractGraph) = Graphs.ne(g)

# adaptation of Networks.jl to Graphs.jl
struct SimpleAdaptedEdge{T<:Integer,E}
    src::T
    dst::T
    network_edge::E
end

Graphs.src(e::SimpleAdaptedEdge) = e.src
Graphs.dst(e::SimpleAdaptedEdge) = e.dst
Networks.edge(e::SimpleAdaptedEdge) = e.network_edge

# `T` is the Graphs.jl vertex type, `V` is the Networks.jl vertex type
const GraphVertexBijection{T,V} = Bijection{T,V,Dict{T,V},Dict{V,T}}

struct GraphsAdaptorNetwork{T<:Integer,N<:AbstractNetwork,V} <: Graphs.AbstractGraph{T}
    network::N
    vertexmap::GraphVertexBijection{T,V}

    # TODO assert no hyperedges
end

function GraphsAdaptorNetwork{T}(g::AbstractNetwork) where {T}
    vertexmap = GraphVertexBijection{T,vertex_type(g)}(
        Dict{T,vertex_type(g)}(i => v for (i, v) in enumerate(vertices(g)))
    )
    @show vertex_type(g) typeof(vertexmap)
    return GraphsAdaptorNetwork{T,typeof(g),vertex_type(g)}(g, vertexmap)
end

GraphsAdaptorNetwork(g::AbstractNetwork, T=Int) = GraphsAdaptorNetwork{T}(g)

Base.convert(::Type{Graphs.AbstractGraph{T}}, g::AbstractNetwork) where {T} = GraphsAdaptorNetwork{T}(g)

## `Network` interface implementation
DelegatorTraits.DelegatorTrait(::Networks.Network, ::GraphsAdaptorNetwork) = DelegatorTraits.DelegateToField{:network}()

# override to avoid infinite recursion
Networks.nvertices(g::GraphsAdaptorNetwork) = nvertices(g.network)
Networks.nedges(g::GraphsAdaptorNetwork) = nedges(g.network)

## `AbstractGraph` interface implementation
Base.eltype(::Type{GraphsAdaptorNetwork{T}}) where {T} = T
Graphs.edgetype(g::GraphsAdaptorNetwork) = SimpleAdaptedEdge{eltype(g),edge_type(g)}

Graphs.ne(g::GraphsAdaptorNetwork) = nedges(g)
Graphs.nv(g::GraphsAdaptorNetwork) = nvertices(g)

Graphs.vertices(g::GraphsAdaptorNetwork) = collect(keys(g.vertexmap))
Graphs.has_vertex(g::GraphsAdaptorNetwork, v) = haskey(g.vertexmap, v)

function Graphs.edges(g::GraphsAdaptorNetwork)
    Iterators.map(all_edges(g)) do e
        src, dst = edge_incidents(g, e)
        SimpleAdaptedEdge{eltype(g),edge_type(g)}(g.vertexmap(src), g.vertexmap(dst), e)
    end
end

# TODO should we also check that `src` and `dst` are valid vertices?
Graphs.has_edge(g::GraphsAdaptorNetwork, e::SimpleAdaptedEdge) = hasedge(g, edge(e))
function Graphs.has_edge(g::GraphsAdaptorNetwork, src, dst)
    !isempty(vertex_incidents(g, g.vertexmap[src]) ∩ vertex_incidents(g, g.vertexmap[dst]))
end

# TODO fix when directedness arrives
Graphs.is_directed(g::GraphsAdaptorNetwork) = false
Graphs.outneighbors(g::GraphsAdaptorNetwork, v) = Graphs.inneighbors(g, v)
function Graphs.inneighbors(g::GraphsAdaptorNetwork, v)
    _edges = vertex_incidents(g, g.vertexmap[v])
    neighbors = Set{eltype(g)}()
    for e in _edges
        src, dst = edge_incidents(g, e)
        push!(neighbors, g.vertexmap(src))
        push!(neighbors, g.vertexmap(dst))
    end

    # remove itself
    # TODO keep it if self-loop?
    delete!(neighbors, v)
    return neighbors
end

Base.zero(::Type{GraphsAdaptorNetwork{T,N}}) where {T,N} = GraphsAdaptorNetwork{T}(N())

end
