using DelegatorTraits

# TODO parameterize `EdgePersistence` to allow for different edge persistence strategies
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
DelegatorTraits.ImplementorTrait(::Network, ::IncidentNetwork) = DelegatorTraits.Implements()

# TODO parameterize `EdgePersistence` to allow for different edge persistence strategies
EdgePersistence(::IncidentNetwork) = PersistEdges()

vertices(graph::IncidentNetwork) = keys(graph.vertexmap)
edges(graph::IncidentNetwork) = keys(graph.edgemap)

all_vertices(graph::IncidentNetwork) = keys(graph.vertexmap)
all_edges(graph::IncidentNetwork) = keys(graph.edgemap)

# TODO should we copy the sets to avoid accidental mutation?
incident_vertices(graph::IncidentNetwork, e) = graph.edgemap[e]
incident_edges(graph::IncidentNetwork, v) = graph.vertexmap[v]

function neighbor_vertices(graph::IncidentNetwork, v)
    neighbors = Set{typeof(v)}()
    for edge in incident_edges(graph, v)
        for neighbor in incident_vertices(graph, edge)
            if neighbor != v
                push!(neighbors, neighbor)
            end
        end
    end
    return neighbors
end

function neighbor_edges(graph::IncidentNetwork, e)
    neighbors = Set{typeof(e)}()
    for vertex in incident_vertices(graph, e)
        for neighbor in incident_edges(graph, vertex)
            if neighbor != e
                push!(neighbors, neighbor)
            end
        end
    end
    return neighbors
end

vertex_type(::N) where {N<:IncidentNetwork} = vertex_type(N)
edge_type(::N) where {N<:IncidentNetwork} = edge_type(N)

vertex_type(::Type{IncidentNetwork{V,E}}) where {V,E} = V
edge_type(::Type{IncidentNetwork{V,E}}) where {V,E} = E

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

# TODO parameterize `EdgePersistence` to allow for different edge persistence strategies
function rmvertex!(graph::IncidentNetwork, vertex)
    # isempty(incident_edges(graph, vertex)) || throw(ArgumentError("Vertex $vertex is incident to edges. Unlink edges first."))
    hasvertex(graph, vertex) || throw(ArgumentError("Vertex $vertex does not exist in the graph"))

    # unlink vertex-edge pairs
    for edge in incident_edges(graph, vertex)
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
    # isempty(incident_vertices(graph, edge)) || throw(ArgumentError("Edge $edge is incident to vertices. Unlink vertices first."))
    hasedge(graph, edge) || throw(ArgumentError("Edge $edge does not exist in the graph"))

    # unlink edge-vertex pairs
    for vertex in incident_vertices(graph, edge)
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
