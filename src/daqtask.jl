


mutable struct DAQTask{T} 
    "Is the daq device acquiring data?"
    isreading::Bool
    "Should the daq device stop acquiring data"
    stop::Bool
    "Is the data acquisition using Julia managed threads?"
    thrd::Bool
    "Number of samples already read"
    nread::Int
    "Current index in the buffer"
    idx::Int
    "Buffer to store data"
    buffer::Matrix{T}
    "Minimum number of frames that can be stored in the buffer"
    minbuflen::Int
    "Flag that can be used to communicate information"
    flag::Int
    "Julia task (@async or @spawn)"
    task::Task
    DAQTask{T}() where {T}  = new(false, false, false, 0, 0, zeros(T,0,0), 1, 0)
    DAQTask{T}(bwidth::Integer, blen::Integer) where {T} = new(false, false, false, 0, 0,
                                                               zeros(T, bwidth,blen),
                                                               blen, 0)
end


"""
`isreading(tsk)`

Is the daq device currently acquiring data?

See [`samplesread`](@ref) to see the number of samples already read.
"""
isreading(task::DAQTask) = task.isreading

"""
`samplesread(tsk)`

Return the number of samples already read.

See [`isreading`](@ref) to determine if reading is going on.
"""
samplesread(task::DAQTask) = task.nread


issamplesavailable(task::DAQTask) = task.nread > 0
"""
`buffer(tsk)`

Return the buffer of the task.
"""
buffer(task::DAQTask) = task.buffer

"""
`buffer(tsk,i)`

Return the buffer of the task for the i-th frame.
"""
buffer(task::DAQTask, i) = view(task.buffer, :, i)


"""
`bufsize(tsk)`

Returns the number of frames that can be stored in the buffer.
"""
bufsize(tsk) = size(tsk.buffer,2)

"""
`bufwidth(tsk)`

Maximum length of each frame in the buffer.
"""
bufwidth(tsk) = size(tsk.buffer,1)

"""
`minbufsize(tsk)`

Minimum number of frames in the buffer.

"""
minbufsize(tsk) = minbuflen


"""
`setminbufsize!(tsk, len)`

Set the minimum number of frames that a buffer can have.
"""
setminbufsize!(tsk, len) = tsk.minbufsize = len

"""
    `resizebuffer!(tsk, [buflen, [fsize]])`

Resize the buffer with space for `buflen` frames `fsize` long each.
If `fsize` is not provided, use the actual one. 

If `buflen` is smaller than the actual buffer length, keep it. If this argument is 
not provided, return to the default size `task.buflen` with present `fsize`.

See [`clearbuffer!`](@ref) to clear the buffer.
"""
function resizebuffer!(task::DAQTask{T}, buflen, fsize) where {T}
    nr,nc = size(task.buffer)

    buflen = max(buflen, minbufsize(task))
    if nr == fsize
        resizebuffer!(task, buflen)
    else
        task.buffer = zeros(T, nr, buflen)
        clearbuffer!(task, false)
    end
    
end

function resizebuffer!(task::DAQTask{T}, buflen) where {T}
    buflen = max(buflen, minbufsize(task))
    nr, nc = size(task.buffer)
    if buflen > nc
        task.buffer = zeros(T, nr, buflen)
        clearbuffer!(task, false)
    end
    return
end


resizebuffer!(task::DAQTask{T}) where {T} = resizebuffer!(task, minbuflen(task), bufwidth(task))


"""
`clearbuffer!(task, zeroit)`

Clear the buffer. Set the DAQTask parameters to null state. 
To actually zero the buffer as well, use argument `zeroit=true`.
"""
function clearbuffer!(task::DAQTask, zeroit=true)
    isreading(task) && error("Can not clear a task while it is reading!")
    
    task.isreading = false # Let's make sure...
    task.stop = false
    task.thrd = false
    task.nread = 0
    task.idx = 0

    if zeroit
        task.buffer .= 0
    end
    return
end


taskflag(task::DAQTask) = task.flag
settaskflag!(task::DAQTask, flg) = task.flag=flg

setdaqthread!(task::DAQTask, thrdstatus=false) = task.thrd=thrdstatus
daqthread(task::DAQTask) = task.thrd


setdaqtask!(task::DAQTask, jtsk::Task) = task.task = jtsk
daqtask(task::DAQTask) = task.task

function incidx!(task)
    task.idx = (task.idx % size(task.buffer,2)) + 1
    task.nread += 1
    return task.idx
end

