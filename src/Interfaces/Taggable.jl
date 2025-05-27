struct Taggable <: Interface end

# traits
# WARN experimental
abstract type TagKind end
struct VertexTagKind <: TagKind end
struct EdgeTagKind <: TagKind end

function tag_kind end
tag_kind(_::T) where {T} = tag_kind(T)

# TODO is this correct?
tag_kind(::Type{<:AbstractVertex}) = VertexTagKind()
tag_kind(::Type{<:AbstractEdge}) = EdgeTagKind()

# dispatching methods
# WARN experimental
function tags end
function tag end
function hastag end
function tag_at end
function replace_tag! end

# query methods
function vertex_tags end
function edge_tags end

function has_vertex_tag end
function has_edge_tag end

function vertex_at end
function edge_at end

function tag_at_vertex end
function tag_at_edge end

# mutating methods
function tag_vertex! end
function tag_edge! end
function untag_vertex! end
function untag_edge! end
function replace_vertex_tag! end
function replace_edge_tag! end

# implementation
## TODO `tags`
## TODO `tag`

## `hastag`
hastag(graph, tag) = hastag(graph, tag, TagKind(tag))
hastag(graph, tag, ::VertexTagKind) = has_vertex_tag(graph, tag)
hastag(graph, tag, ::EdgeTagKind) = has_edge_tag(graph, tag)

## `tag_at`
### TODO add methods based on trait instead of abstract type?
tag_at(graph, v::AbstractVertex) = tag_at_vertex(graph, v)
tag_at(graph, e::AbstractEdge) = tag_at_edge(graph, e)

## `replace_tag!`
replace_tag!(graph, old, new) = replace_tag!(graph, old, new, TagKind(old), TagKind(new))
replace_tag!(graph, old, new, ::VertexTagKind, ::VertexTagKind) = replace_vertex_tag!(graph, old, new)
replace_tag!(graph, old, new, ::EdgeTagKind, ::EdgeTagKind) = replace_edge_tag!(graph, old, new)
replace_tag!(graph, old, new, ::TagKind, ::TagKind) = throw(MethodError(replace_tag!, (graph, old, new)))

## `vertex_tags`
vertex_tags(graph) = vertex_tags(graph, DelegatorTrait(Taggable(), graph))
vertex_tags(graph, ::DelegateToField) = vertex_tags(delegator(Taggable(), graph))
vertex_tags(graph, ::DontDelegate) = throw(MethodError(vertex_tags, (graph,)))

## `edge_tags`
edge_tags(graph) = edge_tags(graph, DelegatorTrait(Taggable(), graph))
edge_tags(graph, ::DelegateToField) = edge_tags(delegator(Taggable(), graph))
edge_tags(graph, ::DontDelegate) = throw(MethodError(edge_tags, (graph,)))

## `has_vertex_tag`
has_vertex_tag(graph, tag) = has_vertex_tag(graph, tag, DelegatorTrait(Taggable(), graph))
has_vertex_tag(graph, tag, ::DelegateToField) = has_vertex_tag(delegator(Taggable(), graph), tag)
has_vertex_tag(graph, tag, ::DontDelegate) = throw(MethodError(has_vertex_tag, (graph, tag)))

## `has_edge_tag`
has_edge_tag(graph, tag) = has_edge_tag(graph, tag, DelegatorTrait(Taggable(), graph))
has_edge_tag(graph, tag, ::DelegateToField) = has_edge_tag(delegator(Taggable(), graph), tag)
has_edge_tag(graph, tag, ::DontDelegate) = throw(MethodError(has_edge_tag, (graph, tag)))

## `vertex_at`
vertex_at(graph, tag) = vertex_at(graph, tag, DelegatorTrait(Taggable(), graph))
vertex_at(graph, tag, ::DelegateToField) = vertex_at(delegator(Taggable(), graph), tag)
vertex_at(graph, tag, ::DontDelegate) = throw(MethodError(vertex_at, (graph, tag)))

## `edge_at`
edge_at(graph, tag) = edge_at(graph, tag, DelegatorTrait(Taggable(), graph))
edge_at(graph, tag, ::DelegateToField) = edge_at(delegator(Taggable(), graph), tag)
edge_at(graph, tag, ::DontDelegate) = throw(MethodError(edge_at, (graph, tag)))

## `tag_at_vertex`
tag_at_vertex(graph, vertex) = vertex_at_vertex(graph, vertex, DelegatorTrait(Taggable(), graph))
tag_at_vertex(graph, vertex, ::DelegateToField) = tag_at_vertex(delegator(Taggable(), graph), vertex)
tag_at_vertex(graph, vertex, ::DontDelegate) = throw(MethodError(tag_at_vertex, (graph, vertex)))

## `tag_at_edge`
tag_at_edge(graph, edge) = vertex_at_vertex(graph, edge, DelegatorTrait(Taggable(), graph))
tag_at_edge(graph, edge, ::DelegateToField) = tag_at_edge(delegator(Taggable(), graph), edge)
tag_at_edge(graph, edge, ::DontDelegate) = throw(MethodError(tag_at_edge, (graph, edge)))

## `tag_vertex!`
tag_vertex!(graph, vertex, tag) = tag_vertex!(graph, vertex, tag, DelegatorTrait(Taggable(), graph))
tag_vertex!(graph, vertex, tag, ::DelegateToField) = tag_vertex!(delegator(Taggable(), graph), vertex, tag)
tag_vertex!(graph, vertex, tag, ::DontDelegate) = throw(MethodError(tag_vertex!, (graph, vertex, tag)))

## `tag_edge!`
tag_edge!(graph, edge, tag) = tag_edge!(graph, edge, tag, DelegatorTrait(Taggable(), graph))
tag_edge!(graph, edge, tag, ::DelegateToField) = tag_edge!(delegator(Taggable(), graph), edge, tag)
tag_edge!(graph, edge, tag, ::DontDelegate) = throw(MethodError(tag_edge!, (graph, edge, tag)))

## `untag_vertex!`
untag_vertex!(graph, tag) = untag_vertex!(graph, tag, DelegatorTrait(Taggable(), graph))
untag_vertex!(graph, tag, ::DelegateToField) = untag_vertex!(delegator(Taggable(), graph), tag)
untag_vertex!(graph, tag, ::DontDelegate) = throw(MethodError(untag_vertex!, (graph, tag)))

## `untag_edge!`
untag_edge!(graph, tag) = untag_edge!(graph, tag, DelegatorTrait(Taggable(), graph))
untag_edge!(graph, tag, ::DelegateToField) = untag_edge!(delegator(Taggable(), graph), tag)
untag_edge!(graph, tag, ::DontDelegate) = throw(MethodError(untag_edge!, (graph, tag)))

## `replace_vertex_tag!`
replace_vertex_tag!(graph, old, new) = replace_vertex_tag!(graph, old, new, DelegatorTrait(Taggable(), graph))
replace_vertex_tag!(graph, old, new, ::DelegateToField) = replace_vertex_tag!(delegator(Taggable(), graph), old, new)
replace_vertex_tag!(graph, old, new, ::DontDelegate) = throw(MethodError(replace_vertex_tag!, (graph, old, new)))

## `replace_edge_tag!`
replace_edge_tag!(graph, old, new) = replace_edge_tag!(graph, old, new, DelegatorTrait(Taggable(), graph))
replace_edge_tag!(graph, old, new, ::DelegateToField) = replace_edge_tag!(delegator(Taggable(), graph), old, new)
replace_edge_tag!(graph, old, new, ::DontDelegate) = throw(MethodError(replace_edge_tag!, (graph, old, new)))
