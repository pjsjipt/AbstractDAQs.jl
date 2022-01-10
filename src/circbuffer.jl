

mutable struct CircMatBuffer{T} <: AbstractVector{T}
    capacity::Int
    width::Int
    first::Int
    length::Int
    buffer::Matrix{T}
end

CircMatBuffer{T}(width, capacity) where {T} =
    CircMatBuffer{T}(capacity, width, 1, 0, zeros(T, width, capacity))

Base.length(x::CircMatBuffer) = x.length
Base.size(x::CircMatBuffer) = (x.length,)
bufwidth(x::CircMatBuffer) = x.width


"""
    empty!(cb::CircMatBuffer)

Reset the buffer.
"""
function Base.empty!(x::CircMatBuffer)
    x.length=0
    x.first = 1
    return x
end

Base.@propagate_inbounds function _buffer_index_checked(cb::CircMatBuffer, i::Int)
    @boundscheck if i < 1 || i > cb.length
        throw(BoundsError(cb, i))
    end
    _buffer_index(cb, i)
end


@inline function _buffer_index(cb::CircMatBuffer, i::Int)
    n = cb.capacity
    idx = cb.first + i - 1
    return ifelse(idx > n, idx - n, idx)
end


"""
    cb[i]

Get the i-th element of CircMatBuffer.

* `cb[1]` to get the element at the front
* `cb[end]` to get the element at the back
"""
@inline Base.@propagate_inbounds function Base.getindex(cb::CircMatBuffer, i::Int)
    view(cb.buffer, :, _buffer_index_checked(cb, i))
end


"""
    cb[i] = data

Store data to the `i`-th element of `CirMatBuffer`.
"""
@inline Base.@propagate_inbounds function Base.setindex!(cb::CircMatBuffer, data, i::Int)
    b = cb[i]
    b .= data
    return cb
end

"""
    pop!(cb::CircMatBuffer)

Remove the element at the back.
"""
@inline function Base.pop!(cb::CircMatBuffer)
    @boundscheck (cb.length == 0) && throw(ArgumentError("array must be non-empty"))
    i = _buffer_index(cb, cb.length)
    cb.length -= 1
    return @inbounds view(cb.buffer, :, i)
end

"""
    push!(cb::CircMatBuffer, data)

Add an element to the back and overwrite front if full.
"""
@inline function Base.push!(cb::CircMatBuffer, data)
    # if full, increment and overwrite, otherwise push
    if cb.length == cb.capacity
        cb.first = (cb.first == cb.capacity ? 1 : cb.first + 1)
    else
        cb.length += 1
    end
    @inbounds view(cb.buffer, :, _buffer_index(cb, cb.length)) .= data
    return cb
end

"""
    `nextbuffer(cb::CircularMatBuffer)`

Return memory block to the next buffer slot.
"""
function nextbuffer(cb::CircMatBuffer)
    # if full, increment and overwrite, otherwise push
    if cb.length == cb.capacity
        cb.first = (cb.first == cb.capacity ? 1 : cb.first + 1)
    else
        cb.length += 1
    end
    return view(cb.buffer, :, _buffer_index(cb, cb.length))
end

"""
    popfirst!(cb::CircMatBuffer)

Remove the element from the front of the `CircMatBuffer`.
"""
function Base.popfirst!(cb::CircMatBuffer)
    @boundscheck (cb.length == 0) && throw(ArgumentError("array must be non-empty"))
    i = cb.first
    cb.first = (cb.first + 1 > cb.capacity ? 1 : cb.first + 1)
    cb.length -= 1
    return @inbounds view(cb.buffer, :, i)
end

"""
    pushfirst!(cb::CircMatBuffer, data)

Insert one or more items at the beginning of CircularBuffer
and overwrite back if full.
"""
function Base.pushfirst!(cb::CircMatBuffer, data)
    # if full, decrement and overwrite, otherwise pushfirst
    cb.first = (cb.first == 1 ? cb.capacity : cb.first - 1)
    if length(cb) < cb.capacity
        cb.length += 1
    end
    @inbounds cb.buffer[:,i] .= data
    return cb
end



"""
    append!(cb::CircMatBuffer, datavec::AbstractMatrix)

Push at most last `capacity` items.
"""
function Base.append!(cb::CircMatBuffer, datavec::AbstractMatrix)
    # push at most last `capacity` items
    n = size(datavec,2)
    for i in max(1, n-capacity(cb)+1):n
        push!(cb, view(datavec,:,i))
    end
    return cb
end


"""
    fill!(cb::CircMatBuffer, data)

Grows the buffer up-to capacity, and fills it entirely.
It doesn't overwrite existing elements.
"""
function Base.fill!(cb::CircMatBuffer, data)
    for i in 1:capacity(cb)-length(cb)
        push!(cb, data)
    end
    return cb
end


Base.eltype(::Type{CircMatBuffer{T}}) where T = T


function Base.convert(::Type{Array}, cb::CircMatBuffer{T}) where {T}
    
    n = length(cb)
    w = bufwidth(cb)
    a = zeros(T, w, n)

    for i in 1:n
        a[:,i] .= view(cb.buffer, :, _buffer_index(cb, i))
    end
    
    return a
end

flatten(cb::CircMatBuffer) = convert(Array, cb)

function flatten!(cb::CircMatBuffer{T}) where {T}

    a = flatten(cb)
    
    for i in 1:length(cb)
        cb.buffer[:,i] .= view(a, :, i)
    end
    cb.first = 1
    return cb
end

"""
    capacity(cb::CircMatBuffer)

Return capacity of CircMatBuffer.
"""
capacity(cb::CircMatBuffer) = cb.capacity


"""
    isfull(cb::CircMatBuffer)

Test whether the buffer is full.
"""
isfull(cb::CircMatBuffer) = length(cb) == cb.capacity


"""
    first(cb::CircMatBuffer)

Get the first element of CircMatBuffer.
"""
Base.@propagate_inbounds function Base.first(cb::CircMatBuffer)
    @boundscheck (cb.length == 0) && throw(BoundsError(cb, 1))
    return view(cb.buffer, :, cb.first)
end

"""
    last(cb::CircMatBuffer)

Get the last element of CircMatBuffer.
"""
Base.@propagate_inbounds function Base.last(cb::CircMatBuffer)
    @boundscheck (cb.length == 0) && throw(BoundsError(cb, 1))
    return view(cb.buffer, :, _buffer_index(cb, cb.length))
end


"""
    resize!(cb::CircMatBuffer, n)

Resize CircMatBuffer to the maximum capacity of n elements.
If n is smaller than the current buffer length, the first n elements will be retained.
"""
function Base.resize!(cb::CircMatBuffer, n::Integer)
    if n != capacity(cb)
        w = bufwidth(cb)
        buf_new = Matrix{eltype(cb)}(undef, w, n)
        len_new = min(length(cb), n)
        for i in 1:len_new
            @inbounds buf_new[i] .= cb[i]
        end

        cb.capacity = n
        cb.first = 1
        cb.length = len_new
        cb.buffer = buf_new
    end
    return cb
end

function Base.resize!(cb::CircMatBuffer, w::Integer, n::Integer)

    if w == bufwidth(cb)
        return resize!(cb, n)
    else
        cb.capacity = n
        cb.length = 0
        cp.first = 1
        cp.buffer = zeros(eltype(cb), w, n)
        return cb
    end
end

