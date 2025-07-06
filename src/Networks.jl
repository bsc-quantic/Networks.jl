module Networks

using DelegatorTraits
import DelegatorTraits: DelegatorTrait, ImplementorTrait

include("Utils.jl")

include("Interfaces/Network.jl")
export Network

export vertices, all_vertices, vertex_at, edge_incidents, vertex_type, hasvertex, nvertices, addvertex!, rmvertex!
export edges, all_edges, edge_at, vertex_incidents, edge_type, hasedge, nedges, addedge!, rmedge!
export edges_set_strand, edges_set_open, edges_set_hyper
export neighbors, vertex_neighbors, edge_neighbors

include("Interfaces/Taggable.jl")
export tags, tag, hastag, tag_at, replace_tag!
export vertex_tags, has_vertex_tag, tag_at_vertex, tag_vertex!, untag_vertex!, replace_vertex_tag!
export edge_tags, has_edge_tag, tag_at_edge, tag_edge!, untag_edge!, replace_edge_tag!

# WARN `Attributeable` is still experimantal, so don't export it yet
include("Interfaces/Attributeable.jl")

include("Components/IncidentNetwork.jl")
export IncidentNetwork

include("Components/SimpleNetwork.jl")
export SimpleNetwork

include("Algorithms/cycles.jl")

end # module Networks
