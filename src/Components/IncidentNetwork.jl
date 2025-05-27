using DelegatorTraits

# TODO parameterize `EdgePersistenceTrait` to allow for different edge persistence strategies
struct IncidentNetwork{V,E} <: AbstractNetwork
    vertexmap::Dict{V,Set{E}}
    edgemap::Dict{E,Set{V}}

    IncidentNetwork{V,E}() where {V,E} = new{V,E}(Dict{V,Set{E}}(), Dict{E,Set{V}}())
    IncidentNetwork{V,E}(vertexmap, edgemap) where {V,E} = new{V,E}(copy(vertexmap), copy(edgemap))
end

function IncidentNetwork(vertexmap::Dict{V,Set{E}}, edgemap::Dict{E,Set{V}}) where {V,E}
    IncidentNetwork{V,E}(vertexmap, edgemap)
end

function Base.copy(graph::IncidentNetwork{V,E}) where {V,E}
    vertexmap = Dict{V,Set{E}}(v => copy(es) for (v, es) in graph.vertexmap)
    edgemap = Dict{E,Set{V}}(e => copy(vs) for (e, vs) in graph.edgemap)
    return IncidentNetwork{V,E}(vertexmap, edgemap)
end

# Network implementation
ImplementorTrait(::Network, ::IncidentNetwork) = Implements()

# TODO parameterize `EdgePersistenceTrait` to allow for different edge persistence strategies
EdgePersistenceTrait(::IncidentNetwork) = PersistEdges()

vertices(graph::IncidentNetwork) = keys(graph.vertexmap)
edges(graph::IncidentNetwork) = keys(graph.edgemap)

# TODO should we copy the sets to avoid accidental mutation?
edge_incidents(graph::IncidentNetwork, e) = graph.edgemap[e]
vertex_incidents(graph::IncidentNetwork, v) = graph.vertexmap[v]

vertex_type(::IncidentNetwork{V,E}) where {V,E} = V
edge_type(::IncidentNetwork{V,E}) where {V,E} = E

hasvertex(graph::IncidentNetwork, v) = haskey(graph.vertexmap, v)
hasedge(graph::IncidentNetwork, e) = haskey(graph.edgemap, e)

nvertices(graph::IncidentNetwork) = length(graph.vertexmap)
nedges(graph::IncidentNetwork) = length(graph.edgemap)

function edges_set_strand(graph::IncidentNetwork{V,E}) where {V,E}
    stranded_edges = Set{E}()
    for (edge, vertex_set) in pairs(graph.edgemap)
        if isempty(vertex_set)
            push!(stranded_edges, edge)
        end
    end
    return stranded_edges
end

function edges_set_open(graph::IncidentNetwork{V,E}) where {V,E}
    stranded_edges = Set{E}()
    for (edge, vertex_set) in pairs(graph.edgemap)
        if length(vertex_set) == 1
            push!(stranded_edges, edge)
        end
    end
    return stranded_edges
end

function edges_set_hyper(graph::IncidentNetwork{V,E}) where {V,E}
    stranded_edges = Set{E}()
    for (edge, vertex_set) in pairs(graph.edgemap)
        if length(vertex_set) > 2
            push!(stranded_edges, edge)
        end
    end
    return stranded_edges
end

function addvertex!(graph::IncidentNetwork{V,E}, vertex) where {V,E}
    hasvertex(graph, vertex) && return graph
    graph.vertexmap[vertex] = Set{E}()
    return graph
end

# TODO parameterize `EdgePersistenceTrait` to allow for different edge persistence strategies
function rmvertex!(graph::IncidentNetwork, vertex)
    # isempty(vertex_incidents(graph, vertex)) || throw(ArgumentError("Vertex $vertex is incident to edges. Unlink edges first."))
    hasvertex(graph, vertex) || throw(ArgumentError("Vertex $vertex does not exist in the graph"))

    # unlink vertex-edge pairs
    for edge in vertex_incidents(graph, vertex)
        unlink!(graph, vertex, edge)
    end

    # remove vertex
    delete!(graph.vertexmap, vertex)
    return graph
end

# TODO make special case for `edge::SimpleEdge` or so (i.e. `edge` contains information about its vertices), so it automatically links them
function addedge!(graph::IncidentNetwork{V,E}, edge) where {V,E}
    hasedge(graph, edge) && return graph
    graph.edgemap[edge] = Set{V}()
    return graph
end

function rmedge!(graph::IncidentNetwork, edge)
    # isempty(edge_incidents(graph, edge)) || throw(ArgumentError("Edge $edge is incident to vertices. Unlink vertices first."))
    hasedge(graph, edge) || throw(ArgumentError("Edge $edge does not exist in the graph"))

    # unlink edge-vertex pairs
    for vertex in edge_incidents(graph, edge)
        unlink!(graph, vertex, edge)
    end

    # remove edge
    delete!(graph.edgemap, edge)
    return graph
end

function link!(graph::IncidentNetwork, vertex, edge)
    push!(graph.vertexmap[vertex], edge)
    push!(graph.edgemap[edge], vertex)
end

function unlink!(graph::IncidentNetwork, vertex, edge)
    delete!(graph.vertexmap[vertex], edge)
    delete!(graph.edgemap[edge], vertex)
end
