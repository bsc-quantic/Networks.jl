# NOTE taken from Graphs.jl, but modified to work with Networks.jl
function cycle_basis(g, root=nothing)
    T = vertex_type(g)
    cycles = Vector{Vector{T}}()

    # shortcut
    nvertices(g) == 0 && return cycles
    gnodes = Set(vertices(g))
    r::T = isnothing(root) ? pop!(gnodes) : root

    while true
        stack = [r]
        pred = Dict(r => r)
        keys_pred = Set([r])
        used = Dict(r => T[])
        keys_used = Set([r])
        while !isempty(stack)
            z = pop!(stack)
            zused = used[z]
            for nbr in vertex_neighbors(g, z)
                if !in(nbr, keys_used)
                    pred[nbr] = z
                    push!(keys_pred, nbr)
                    push!(stack, nbr)
                    used[nbr] = [z]
                    push!(keys_used, nbr)
                elseif nbr == z
                    push!(cycles, [z])
                elseif !in(nbr, zused)
                    pn = used[nbr]
                    cycle = [nbr, z]
                    p = pred[z]
                    while !in(p, pn)
                        push!(cycle, p)
                        p = pred[p]
                    end
                    push!(cycle, p)
                    push!(cycles, cycle)
                    push!(used[nbr], z)
                end
            end
        end
        setdiff!(gnodes, keys_pred)
        isempty(gnodes) && break
        r = pop!(gnodes)
    end
    return cycles
end

# TODO simplecycles?
