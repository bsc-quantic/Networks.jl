struct Attributeable <: Interface end

# TODO should we have a `unsetattr!` or `deleteattr!` method?

# NOTE the API has been designed to have dynamic attrs that can be saved in a `Dict{Symbol,Any}`, but there should be
# nothing holding back to have static attributes. perhaps for type-stability we may need to use a `AttrKey{T}` type on
# which to dispatch or have a `AttributeTypeTrait` with `StaticAttribute` and `DynamicAttribute` traits.

# dispatching methods
function attrs end
function getattr end
function setattr! end
function hasattr end

# query methods
function attrs_global end
function attrs_vertex end
function attrs_edge end

function getattr_global end
function getattr_vertex end
function getattr_edge end

function hasattr_global end
function hasattr_vertex end
function hasattr_edge end

# mutating methods
function setattr_global! end
function setattr_vertex! end
function setattr_edge! end

function delattr_global! end
function delattr_vertex! end
function delattr_edge! end

# implementation
## `attrs`
attrs(tn) = attrs_global(tn)
attrs(tn, vertex::AbstractVertex) = attrs_vertex(tn, vertex)
attrs(tn, edge::AbstractEdge) = attrs_edge(tn, edge)

## `getattr`
getattr(tn, key) = getattr_global(tn, key)
getattr(tn, vertex::AbstractVertex, key) = getattr_vertex(tn, vertex, key)
getattr(tn, edge::AbstractEdge, key) = getattr_edge(tn, edge, key)

getattr(tn, key, default) = hasattr(tn, key) ? getattr(tn, key) : default
getattr(tn, vertex::AbstractVertex, key, default) = hasattr(tn, vertex, key) ? getattr(tn, vertex, key) : default
getattr(tn, edge::AbstractEdge, key, default) = hasattr(tn, edge, key) ? getattr(tn, edge, key) : default

## `setattr!`
setattr!(tn, key, value) = setattr_global!(tn, key, value)
setattr!(tn, vertex::AbstractVertex, key, value) = setattr_vertex!(tn, vertex, key, value)
setattr!(tn, edge::AbstractEdge, key, value) = setattr_edge!(tn, edge, key, value)

## `hasattr`
hasattr(tn, key) = hasattr_global(tn, key)
hasattr(tn, vertex::AbstractVertex, key) = hasattr_vertex(tn, vertex, key)
hasattr(tn, edge::AbstractEdge, key) = hasattr_vertex(tn, edge, key)

## `attrs_global`
attrs_global(tn) = attrs_global(tn, delegates(Attributeable(), tn))
attrs_global(tn, ::DelegateToField) = attrs_global(delagate(Attributeable(), tn))
attrs_global(tn, ::DontDelegate) = throw(MethodError(attrs_global, (tn,)))

## `attrs_vertex`
attrs_vertex(tn, vertex) = attrs_vertex(tn, vertex, delegates(Attributeable(), tn))
attrs_vertex(tn, vertex, ::DelegateToField) = attrs_vertex(delegate(Attributeable(), tn), vertex)
attrs_vertex(tn, vertex, ::DontDelegate) = throw(MethodError(attrs_vertex, (tn, vertex)))

## `attrs_edge`
attrs_edge(tn, edge) = attrs_edge(tn, edge, delegates(Attributeable(), tn))
attrs_edge(tn, edge, ::DelegateToField) = attrs_edge(delegate(Attributeable(), tn), edge)
attrs_edge(tn, edge, ::DontDelegate) = throw(MethodError(attrs_edge, (tn, edge)))

## `getattr_global`
getattr_global(tn, key) = getattr_global(tn, key, delegates(Attributeable(), tn))
getattr_global(tn, key, ::DelegateToField) = getattr_global(delegate(Attributeable(), tn), key)
function getattr_global(tn, key, ::DontDelegate)
    fallback(getattr_global)
    return getindex(attrs_global(tn), key)
end

## `getattr_vertex`
getattr_vertex(tn, vertex, key) = getattr_vertex(tn, vertex, key, delegates(Attributeable(), tn))
getattr_vertex(tn, vertex, key, ::DelegateToField) = getattr_vertex(delegate(Attributeable(), tn), vertex, key)
function getattr_vertex(tn, vertex, key, ::DontDelegate)
    fallback(getattr_vertex)
    return getindex(attrs_vertex(tn, vertex), key)
end

## `getattr_edge`
getattr_edge(tn, edge, key) = getattr_edge(tn, edge, key, delegates(Attributeable(), tn))
getattr_edge(tn, edge, key, ::DelegateToField) = getattr_edge(delegate(Attributeable(), tn), edge, key)
function getattr_edge(tn, edge, key, ::DontDelegate)
    fallback(getattr_edge)
    return getindex(attrs_edge(tn, edge), key)
end

## `hasattr_global`
hasattr_global(tn, key) = hasattr_global(tn, key, delegates(Attributeable(), tn))
hasattr_global(tn, key, ::DelegateToField) = hasattr_global(delegate(Attributeable(), tn), key)
function hasattr_global(tn, key, ::DontDelegate)
    fallback(hasattr_global)
    return haskey(attrs_global(tn), key)
end

## `hasattr_vertex`
hasattr_vertex(tn, vertex, key) = hasattr_vertex(tn, vertex, key, delegates(Attributeable(), tn))
hasattr_vertex(tn, vertex, key, ::DelegateToField) = hasattr_vertex(delegate(Attributeable(), tn), vertex, key)
function hasattr_vertex(tn, vertex, key, ::DontDelegate)
    fallback(hasattr_vertex)
    return haskey(attrs_vertex(tn, vertex), key)
end

## `hasattr_edge`
hasattr_edge(tn, edge, key) = hasattr_edge(tn, edge, key, delegates(Attributeable(), tn))
hasattr_edge(tn, edge, key, ::DelegateToField) = hasattr_edge(delegate(Attributeable(), tn), edge, key)
function hasattr_edge(tn, edge, key, ::DontDelegate)
    fallback(hasattr_edge)
    return haskey(attrs_edge(tn, edge), key)
end

## `setattr_global!`
setattr_global!(tn, key, value) = setattr_global!(tn, key, value, delegates(Attributeable(), tn))
setattr_global!(tn, key, value, ::DelegateToField) = setattr_global!(delegate(Attributeable(), tn), key, value)
setattr_global!(tn, key, value, ::DontDelegate) = throw(MethodError(setattr_global!, (tn, key, value)))

## `setattr_vertex!`
# TODO check if the vertex exists
#   hasvertex(tn, e.vertex) || throw(ArgumentError("Vertex $(e.vertex) not found in network"))
setattr_vertex!(tn, vertex, key, value) = setattr_vertex!(tn, vertex, key, value, delegates(Attributeable(), tn))
function setattr_vertex!(tn, vertex, key, value, ::DelegateToField)
    setattr_vertex!(delegate(Attributeable(), tn), vertex, key, value)
end
setattr_vertex!(tn, vertex, key, value, ::DontDelegate) = throw(MethodError(setattr_vertex!, (tn, vertex, key, value)))

## `setattr_edge!`
# TODO check if the edge exists
#   hasedge(tn, e.edge) || throw(ArgumentError("Edge $(e.edge) not found in network"))
setattr_edge!(tn, edge, key, value) = setattr_edge!(tn, edge, key, value, delegates(Attributeable(), tn))
setattr_edge!(tn, edge, key, value, ::DelegateToField) = setattr_edge!(delegate(Attributeable(), tn), edge, key, value)
setattr_edge!(tn, edge, key, value, ::DontDelegate) = throw(MethodError(setattr_edge!, (tn, edge, key, value)))

## `delattr_global!`
delattr_global!(tn, key) = delattr_global!(tn, key, delegates(Attributeable(), tn))
delattr_global!(tn, key, ::DelegateToField) = delattr_global!(delegate(Attributeable(), tn), key)
delattr_global!(tn, key, ::DontDelegate) = throw(MethodError(delattr_global!, (tn, key)))

## `delattr_vertex!`
delattr_vertex!(tn, vertex, key) = delattr_vertex!(tn, vertex, key, delegates(Attributeable(), tn))
delattr_vertex!(tn, vertex, key, ::DelegateToField) = delattr_vertex!(delegate(Attributeable(), tn), vertex, key)
delattr_vertex!(tn, vertex, key, ::DontDelegate) = throw(MethodError(delattr_vertex!, (tn, vertex, key)))

## `delattr_edge!`
delattr_edge!(tn, edge, key) = delattr_edge!(tn, edge, key, delegates(Attributeable(), tn))
delattr_edge!(tn, edge, key, ::DelegateToField) = delattr_edge!(delegate(Attributeable(), tn), edge, key)
delattr_edge!(tn, edge, key, ::DontDelegate) = throw(MethodError(delattr_edge!, (tn, edge, key)))
