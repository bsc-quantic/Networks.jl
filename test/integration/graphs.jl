using Test
using Networks
using Graphs: Graphs

network = Networks.IncidentNetwork{Symbol,Int}()
addvertex!(network, :a)
addvertex!(network, :b)
addvertex!(network, :c)

addedge!(network, 1)
Networks.link!(network, :a, 1)
Networks.link!(network, :b, 1)

addedge!(network, 2)
Networks.link!(network, :b, 2)
Networks.link!(network, :c, 2)

addedge!(network, 3)
Networks.link!(network, :c, 3)
Networks.link!(network, :a, 3)

g = convert(Graphs.AbstractGraph{Int}, network)

@test Graphs.nv(g) == 3
@test Graphs.ne(g) == 3

@test issetequal(all_vertices(g), [:a, :b, :c])
@test issetequal(Graphs.vertices(g), [1, 2, 3])
@test Graphs.has_vertex(g, 1)
@test Graphs.has_vertex(g, 2)
@test Graphs.has_vertex(g, 3)
@test !Graphs.has_vertex(g, 4)

@test issetequal(map(Networks.edge, Graphs.edges(g)), all_edges(g))
@test issetequal(all_edges(g), [1, 2, 3])

@test Graphs.is_directed(g) == false

@test issetequal(Graphs.inneighbors(g, 1), [2, 3])
@test issetequal(Graphs.inneighbors(g, 2), [1, 3])
@test issetequal(Graphs.inneighbors(g, 3), [1, 2])
@test issetequal(Graphs.outneighbors(g, 1), [2, 3])
@test issetequal(Graphs.outneighbors(g, 2), [1, 3])
@test issetequal(Graphs.outneighbors(g, 3), [1, 2])
