using Test
using Networks

# testing fixtures
fixture = let
    vm = Dict(
        :a => Set([1, 2]),
        :b => Set([1, 3, 4, 5]),
        :c => Set([4, 5, 11, 12]),
        :d => Set([3, 4, 6]),
        :e => Set([2, 6, 9]),
        :f => Set([9, 14, 17]),
        :g => Set([10, 11, 13, 15, 14]),
        :h => Set([12, 13, 16]),
        :j => Set{Int}(),
    )

    em = Dict(
        1 => Set([:a, :b]),
        2 => Set([:a, :e]),
        3 => Set([:d, :b]),
        4 => Set([:b, :d, :c]),
        5 => Set([:b, :c]),
        6 => Set([:d, :e]),
        11 => Set([:c, :g]),
        12 => Set([:c, :h]),
        13 => Set([:g, :h]),
        14 => Set([:g, :f]),
        15 => Set([:g]),
        16 => Set([:h]),
        17 => Set([:f]),
    )

    (;
        vertex_map=vm,
        edge_map=em,
        vertex_type=Symbol,
        edge_type=Int,
        vertices=collect(keys(vm)),
        edges=collect(keys(em)),
        edges_strand=Set{Int}([]),
        edges_open=Set{Int}([15, 16, 17]),
        edges_hyper=Set{Int}([4]),
        vertex_strand=:j,
        new_vertex=(; vertex=:i, edge_set=Set([15, 16, 17])),
        new_edge=(; edge=10, vertex_set=Set([:d, :g])),
        delete_vertex=:h,
        delete_edge=3,
    )
end

# wraps a network to test interface delegation
struct WrapNetwork{G}
    g::G
end

WrapNetwork(v, e) = WrapNetwork(IncidentNetwork(v, e))
Networks.DelegatorTrait(::Networks.Network, ::WrapNetwork) = Networks.DelegateToField{:g}()

# mocks a network to test default implementations of optional methods
struct MockNetwork{V,E,EdgePersistence<:Networks.EdgePersistence}
    g::IncidentNetwork{V,E}
end

MockNetwork(v::V, e::E) where {V,E} = MockNetwork(IncidentNetwork(v, e))
MockNetwork(g::IncidentNetwork{V,E}, ::EP) where {V,E,EP<:Networks.EdgePersistence} = MockNetwork{V,E,EP}(g)
MockNetwork(g::IncidentNetwork) = MockNetwork(g, Networks.EdgePersistence(g))

Networks.ImplementorTrait(::Networks.Network, ::MockNetwork) = Networks.Implements()
Networks.vertices(g::MockNetwork) = vertices(g.g)
Networks.edges(g::MockNetwork) = edges(g.g)
Networks.all_vertices(g::MockNetwork) = vertices(g.g)
Networks.all_edges(g::MockNetwork) = edges(g.g)
Networks.edge_incidents(g::MockNetwork, edge) = edge_incidents(g.g, edge)
Networks.vertex_incidents(g::MockNetwork, vertex) = vertex_incidents(g.g, vertex)
Networks.vertex_type(g::MockNetwork) = vertex_type(g.g)
Networks.edge_type(g::MockNetwork) = edge_type(g.g)

Networks.addvertex!(g::MockNetwork, vertex) = addvertex!(g.g, vertex)
Networks.rmvertex!(g::MockNetwork, vertex) = rmvertex!(g.g, vertex)
Networks.addedge!(g::MockNetwork, edge, vertex_set) = addedge!(g.g, edge, vertex_set)
Networks.rmedge!(g::MockNetwork, edge) = rmedge!(g.g, edge)

Networks.EdgePersistence(::MockNetwork{V,E,EP}) where {V,E,EP} = EP()

@testset"all_vertices" begin
    @testset "$(typeof(network))" for network in [
        IncidentNetwork(fixture.vertex_map, fixture.edge_map),
        WrapNetwork(fixture.vertex_map, fixture.edge_map),
        MockNetwork(fixture.vertex_map, fixture.edge_map),
    ]
        @test issetequal(all_vertices(network), fixture.vertices)
    end
end

@testset "all_edges" begin
    @testset "$(typeof(network))" for network in [
        IncidentNetwork(fixture.vertex_map, fixture.edge_map),
        WrapNetwork(fixture.vertex_map, fixture.edge_map),
        MockNetwork(fixture.vertex_map, fixture.edge_map),
    ]
        @test issetequal(all_edges(network), fixture.edges)
    end
end

@testset "edge_incidents" begin
    @testset "$(typeof(network))" for network in [
        IncidentNetwork(fixture.vertex_map, fixture.edge_map),
        WrapNetwork(fixture.vertex_map, fixture.edge_map),
        MockNetwork(fixture.vertex_map, fixture.edge_map),
    ]
        for (edge, vertex_set) in fixture.edge_map
            @test issetequal(edge_incidents(network, edge), vertex_set)
        end
    end
end

@testset "vertex_incidents" begin
    @testset "$(typeof(network))" for network in [
        IncidentNetwork(fixture.vertex_map, fixture.edge_map),
        WrapNetwork(fixture.vertex_map, fixture.edge_map),
        MockNetwork(fixture.vertex_map, fixture.edge_map),
    ]
        for (vertex, edge_set) in fixture.vertex_map
            @test issetequal(vertex_incidents(network, vertex), edge_set)
        end
    end
end

@testset "vertex_neighbors" begin
    g = IncidentNetwork{Symbol,Int}()
    addvertex!(g, :a)
    addvertex!(g, :b)
    addvertex!(g, :c)
    addedge!(g, 1)
    Networks.link!(g, :a, 1)
    Networks.link!(g, :b, 1)

    @test issetequal(vertex_neighbors(g, :a), Set([:b]))
    @test issetequal(vertex_neighbors(g, :b), Set([:a]))
    @test isempty(vertex_neighbors(g, :c))
end

@testset "edge_neighbors" begin
    g = IncidentNetwork{Symbol,Int}()
    addvertex!(g, :a)
    addvertex!(g, :b)
    addvertex!(g, :c)
    addvertex!(g, :d)

    addedge!(g, 1)
    Networks.link!(g, :a, 1)
    Networks.link!(g, :b, 1)

    addedge!(g, 2)
    Networks.link!(g, :b, 2)
    Networks.link!(g, :c, 2)

    addedge!(g, 3)
    Networks.link!(g, :d, 3)

    @test issetequal(edge_neighbors(g, 1), Set([2]))
    @test issetequal(edge_neighbors(g, 2), Set([1]))
    @test isempty(edge_neighbors(g, 3))
end

@testset "vertex_type" begin
    @testset "$(typeof(network))" for network in [
        IncidentNetwork(fixture.vertex_map, fixture.edge_map),
        WrapNetwork(fixture.vertex_map, fixture.edge_map),
        MockNetwork(fixture.vertex_map, fixture.edge_map),
    ]
        @test vertex_type(network) === fixture.vertex_type
    end
end

@testset "edge_type" begin
    @testset "$(typeof(network))" for network in [
        IncidentNetwork(fixture.vertex_map, fixture.edge_map),
        WrapNetwork(fixture.vertex_map, fixture.edge_map),
        MockNetwork(fixture.vertex_map, fixture.edge_map),
    ]
        @test edge_type(network) === fixture.edge_type
    end
end

@testset "hasvertex" begin
    @testset "$(typeof(network))" for network in [
        IncidentNetwork(fixture.vertex_map, fixture.edge_map),
        WrapNetwork(fixture.vertex_map, fixture.edge_map),
        MockNetwork(fixture.vertex_map, fixture.edge_map),
    ]
        for vertex in fixture.vertices
            @test hasvertex(network, vertex)
        end

        @test !hasvertex(network, fixture.new_vertex.vertex)
    end
end

@testset "hasedge" begin
    @testset "$(typeof(network))" for network in [
        IncidentNetwork(fixture.vertex_map, fixture.edge_map),
        WrapNetwork(fixture.vertex_map, fixture.edge_map),
        MockNetwork(fixture.vertex_map, fixture.edge_map),
    ]
        for edge in fixture.edges
            @test hasedge(network, edge)
        end

        @test !hasedge(network, fixture.new_edge.edge)
    end
end

@testset "nvertices" begin
    @testset "$(typeof(network))" for network in [
        IncidentNetwork(fixture.vertex_map, fixture.edge_map),
        WrapNetwork(fixture.vertex_map, fixture.edge_map),
        MockNetwork(fixture.vertex_map, fixture.edge_map),
    ]
        @test nvertices(network) == length(fixture.vertices)
    end
end

@testset "nedges" begin
    @testset "$(typeof(network))" for network in [
        IncidentNetwork(fixture.vertex_map, fixture.edge_map),
        WrapNetwork(fixture.vertex_map, fixture.edge_map),
        MockNetwork(fixture.vertex_map, fixture.edge_map),
    ]
        @test nedges(network) == length(fixture.edges)
    end
end

@testset "edges_set_strand" begin
    @testset "$(typeof(network))" for network in [
        IncidentNetwork(fixture.vertex_map, fixture.edge_map),
        WrapNetwork(fixture.vertex_map, fixture.edge_map),
        MockNetwork(fixture.vertex_map, fixture.edge_map),
    ]
        @test issetequal(edges_set_strand(network), fixture.edges_strand)
    end
end

@testset "edges_set_open" begin
    @testset "$(typeof(network))" for network in [
        IncidentNetwork(fixture.vertex_map, fixture.edge_map),
        WrapNetwork(fixture.vertex_map, fixture.edge_map),
        MockNetwork(fixture.vertex_map, fixture.edge_map),
    ]
        @test issetequal(edges_set_open(network), fixture.edges_open)
    end
end

@testset "edges_set_hyper" begin
    @testset "$(typeof(network))" for network in [
        IncidentNetwork(fixture.vertex_map, fixture.edge_map),
        WrapNetwork(fixture.vertex_map, fixture.edge_map),
        MockNetwork(fixture.vertex_map, fixture.edge_map),
    ]
        @test issetequal(edges_set_hyper(network), fixture.edges_hyper)
    end
end

@testset "addvertex!" begin
    @testset "$(typeof(network))" for network in [
        IncidentNetwork(deepcopy(fixture.vertex_map), deepcopy(fixture.edge_map)),
        WrapNetwork(deepcopy(fixture.vertex_map), deepcopy(fixture.edge_map)),
        MockNetwork(deepcopy(fixture.vertex_map), deepcopy(fixture.edge_map)),
    ]
        addvertex!(network, fixture.new_vertex.vertex)
        @test hasvertex(network, fixture.new_vertex.vertex)

        # vertex already exists so it should throw an error
        # @test_throws ArgumentError addvertex!(network, fixture.new_vertex.vertex)
    end
end

@testset "addedge!" begin
    @testset "$(typeof(network))" for network in [
        IncidentNetwork(deepcopy(fixture.vertex_map), deepcopy(fixture.edge_map)),
        WrapNetwork(deepcopy(fixture.vertex_map), deepcopy(fixture.edge_map)),
        MockNetwork(deepcopy(fixture.vertex_map), deepcopy(fixture.edge_map)),
    ]
        # TODO

        # addedge!(network, fixture.new_edge.edge, fixture.new_edge.vertex_set)
        # @test hasedge(network, fixture.new_edge.edge)

        # # edge already exists so it should throw an error
        # @test_throws ArgumentError addedge!(network, fixture.new_edge.edge, fixture.new_edge.vertex_set)
    end
end

@testset "rmvertex!" begin
    @testset "IncidentNetwork" begin
        # test stranded vertex removal
        @testset let fixture = deepcopy(fixture)
            network = IncidentNetwork(deepcopy(fixture.vertex_map), deepcopy(fixture.edge_map))

            # test vertex removal
            @test hasvertex(network, fixture.vertex_strand)
            rmvertex!(network, fixture.vertex_strand)
            @test !hasvertex(network, fixture.vertex_strand)

            # vertex does not exist anymore so it should throw an error
            @test_throws ArgumentError rmvertex!(network, fixture.vertex_strand)

            # `IncidentNetwork` has `PersistEdges` trait
            @test all(fixture.edges) do edge
                hasedge(network, edge)
            end
        end

        # test regular vertex removal
        @testset let fixture = deepcopy(fixture)
            network = IncidentNetwork(deepcopy(fixture.vertex_map), deepcopy(fixture.edge_map))

            # test vertex removal
            @test hasvertex(network, fixture.delete_vertex)
            rmvertex!(network, fixture.delete_vertex)
            @test !hasvertex(network, fixture.delete_vertex)

            # vertex does not exist anymore so it should throw an error
            @test_throws ArgumentError rmvertex!(network, fixture.delete_vertex)

            # `IncidentNetwork` has `PersistEdges` trait
            @test all(fixture.edges) do edge
                hasedge(network, edge)
            end
        end
    end

    @testset "WrapNetwork{IncidentNetwork}" begin
        # test stranded vertex removal
        @testset let fixture = deepcopy(fixture)
            network = WrapNetwork(deepcopy(fixture.vertex_map), deepcopy(fixture.edge_map))

            # test vertex removal
            @test hasvertex(network, fixture.vertex_strand)
            rmvertex!(network, fixture.vertex_strand)
            @test !hasvertex(network, fixture.vertex_strand)

            # vertex does not exist anymore so it should throw an error
            @test_throws ArgumentError rmvertex!(network, fixture.vertex_strand)

            # `WrapNetwork{IncidentNetwork}` has `PersistEdges` trait
            @test all(fixture.edges) do edge
                hasedge(network, edge)
            end
        end

        # test regular vertex removal
        @testset let fixture = deepcopy(fixture)
            network = WrapNetwork(deepcopy(fixture.vertex_map), deepcopy(fixture.edge_map))

            # test vertex removal
            @test hasvertex(network, fixture.delete_vertex)
            rmvertex!(network, fixture.delete_vertex)
            @test !hasvertex(network, fixture.delete_vertex)

            # vertex does not exist anymore so it should throw an error
            @test_throws ArgumentError rmvertex!(network, fixture.delete_vertex)

            # `WrapNetwork{IncidentNetwork}` has `PersistEdges` trait
            @test all(fixture.edges) do edge
                hasedge(network, edge)
            end
        end
    end

    @testset "MockNetwork" begin
        @testset "trait = PersistEdges" begin
            # test stranded vertex removal
            @testset let fixture = deepcopy(fixture)
                network = MockNetwork(
                    IncidentNetwork(deepcopy(fixture.vertex_map), deepcopy(fixture.edge_map)), Networks.PersistEdges()
                )

                # test vertex removal
                @test hasvertex(network, fixture.vertex_strand)
                rmvertex!(network, fixture.vertex_strand)
                @test !hasvertex(network, fixture.vertex_strand)

                # vertex does not exist anymore so it should throw an error
                @test_throws ArgumentError rmvertex!(network, fixture.vertex_strand)

                # `PersistEdges` trait: edges are not removed on vertex removal
                @test all(fixture.edges) do edge
                    hasedge(network, edge)
                end
            end

            # test regular vertex removal
            @testset let fixture = deepcopy(fixture)
                network = MockNetwork(
                    IncidentNetwork(deepcopy(fixture.vertex_map), deepcopy(fixture.edge_map)), Networks.PersistEdges()
                )

                # test vertex removal
                @test hasvertex(network, fixture.delete_vertex)
                rmvertex!(network, fixture.delete_vertex)
                @test !hasvertex(network, fixture.delete_vertex)

                # vertex does not exist anymore so it should throw an error
                @test_throws ArgumentError rmvertex!(network, fixture.delete_vertex)

                # `PersistEdges` trait: edges are not removed on vertex removal
                @test all(fixture.edges) do edge
                    hasedge(network, edge)
                end
            end
        end

        # @testset "trait = RemoveEdges" begin
        #     # test stranded vertex removal
        #     @testset let fixture = deepcopy(fixture)
        #         network = MockNetwork(
        #             IncidentNetwork(deepcopy(fixture.vertex_map), deepcopy(fixture.edge_map)), Networks.RemoveEdges()
        #         )

        #         # test vertex removal
        #         @test hasvertex(network, fixture.vertex_strand)
        #         rmvertex!(network, fixture.vertex_strand)
        #         @test !hasvertex(network, fixture.vertex_strand)

        #         # vertex does not exist anymore so it should throw an error
        #         @test_throws ArgumentError rmvertex!(network, fixture.vertex_strand)

        #         # `RemoveEdges` trait: edges are removed on vertex removal
        #         @test all(fixture.edges) do edge
        #             hasedge(network, edge)
        #         end
        #     end

        #     # test regular vertex removal
        #     @testset let fixture = deepcopy(fixture)
        #         network = MockNetwork(
        #             IncidentNetwork(deepcopy(fixture.vertex_map), deepcopy(fixture.edge_map)), Networks.RemoveEdges()
        #         )

        #         # test vertex removal
        #         @test hasvertex(network, fixture.delete_vertex)
        #         rmvertex!(network, fixture.delete_vertex)
        #         @test !hasvertex(network, fixture.delete_vertex)

        #         # vertex does not exist anymore so it should throw an error
        #         @test_throws ArgumentError rmvertex!(network, fixture.delete_vertex)

        #         # `RemoveEdges` trait: edges are removed on vertex removal
        #         @test all(fixture.vertex_map[fixture.delete_vertex]) do edge
        #             !hasedge(network, edge)
        #         end

        #         @test all(setdiff(fixture.edges, fixture.vertex_map[fixture.delete_vertex])) do edge
        #             hasedge(network, edge)
        #         end
        #     end
        # end

        # @testset "trait = PruneEdges" begin
        #     # test stranded vertex removal
        #     @testset let fixture = deepcopy(fixture)
        #         network = MockNetwork(
        #             IncidentNetwork(deepcopy(fixture.vertex_map), deepcopy(fixture.edge_map)), Networks.PruneEdges()
        #         )

        #         # test vertex removal
        #         @test hasvertex(network, fixture.vertex_strand)
        #         rmvertex!(network, fixture.vertex_strand)
        #         @test !hasvertex(network, fixture.vertex_strand)

        #         # vertex does not exist anymore so it should throw an error
        #         @test_throws ArgumentError rmvertex!(network, fixture.vertex_strand)

        #         # `PruneEdges` trait: edges are removed on vertex removal
        #         @test all(fixture.edges) do edge
        #             hasedge(network, edge)
        #         end
        #     end

        #     # test regular vertex removal
        #     @testset let fixture = deepcopy(fixture)
        #         network = MockNetwork(
        #             IncidentNetwork(deepcopy(fixture.vertex_map), deepcopy(fixture.edge_map)), Networks.PruneEdges()
        #         )

        #         # test vertex removal
        #         @test hasvertex(network, fixture.delete_vertex)
        #         rmvertex!(network, fixture.delete_vertex)
        #         @test !hasvertex(network, fixture.delete_vertex)

        #         # vertex does not exist anymore so it should throw an error
        #         @test_throws ArgumentError rmvertex!(network, fixture.delete_vertex)

        #         # `PruneEdges` trait: edges are removed on vertex removal
        #         @test isempty(edges_set_strand(network))

        #         tested_stranded = false
        #         for edge in fixture.vertex_map[fixture.delete_vertex]
        #             cardinality = length(fixture.edge_map[edge])
        #             if cardinality == 1
        #                 @test !hasedge(network, edge)
        #                 tested_stranded = true
        #             else
        #                 @test hasedge(network, edge)
        #             end
        #         end

        #         if !tested_stranded
        #             @warn "Vertex removed on test cannot be stranded"
        #         end
        #     end
        # end
    end
end

@testset "rmedge!" begin
    @testset "IncidentNetwork" begin
        # test regular edge removal
        @testset let fixture = deepcopy(fixture)
            network = IncidentNetwork(deepcopy(fixture.vertex_map), deepcopy(fixture.edge_map))

            # test edge removal
            @test hasedge(network, fixture.delete_edge)
            rmedge!(network, fixture.delete_edge)
            @test !hasedge(network, fixture.delete_edge)

            # edge does not exist anymore so it should throw an error
            @test_throws ArgumentError rmedge!(network, fixture.delete_edge)
        end
    end

    @testset "WrapNetwork{IncidentNetwork}" begin
        # test regular edge removal
        @testset let fixture = deepcopy(fixture)
            network = WrapNetwork(deepcopy(fixture.vertex_map), deepcopy(fixture.edge_map))

            # test edge removal
            @test hasedge(network, fixture.delete_edge)
            rmedge!(network, fixture.delete_edge)
            @test !hasedge(network, fixture.delete_edge)

            # edge does not exist anymore so it should throw an error
            @test_throws ArgumentError rmedge!(network, fixture.delete_edge)
        end
    end
end
