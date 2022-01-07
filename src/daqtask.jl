
mutable struct DAQTask{T}
    "Number of elements `T` that can be stored in th buffer (frame length)"
    nw::Int
    "Buffer size - number of frames that can be stored"
    nt::Int
    "Index to the starting data position"
    phead::Int
    "Index of the last data position"
    pnext::Int
    "Is the buffer full?"
    pfull::Bool
    "Number of frames read"
    nread::Int
    "Is the device reading frames?"
    isreading::Bool
    "Stop data acquisition?"
    stop::Bool
    "Are we using threads?"
    thrd::Bool
    "Initial time, end time (ns) and number of frames"
    timing::NTuple{3, UInt64}
    "Actual buffer where wach column corresponds to a frame"
    buf::Matrix{T}
    "Minimum buffer length"
    minbuflen::Int
    "`Task` object executing the data acquisition"
    task::Task
    DAQTask{T}() where {T} = new(0,0,1,0,false,0,false,false,false,
                                 (UInt64(0),UInt64(0),UInt64(0)),
                                 zeros(T,0,0), 1, Task(()->0))
end


"""
`buflen(tsk)`

Returns the number of frames that can be stored in the buffer.
"""
buflen(dtsk::DAQTask) = dtsk.nt

"""
`bufwidth(tsk)`

Maximum length of each frame in the buffer.
"""
bufwidth(dtsk::DAQTask) = dtsk.nw

"""
`buffer(tsk)`

Return the buffer of the task.
"""
buffer(dtsk::DAQTask) = dtsk.buf

"""
`buffer(tsk,i)`

Return the buffer of the task for the i-th frame.
"""
buffer(dtsk::DAQTask, i) = view(dtsk.buf, :, i)


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
`minbufsize(tsk)`

Minimum number of frames in the buffer.

"""
minbufsize(tsk) = tsk.minbuflen

"""
`setminbufsize!(tsk, len)`

Set the minimum number of frames that a buffer can have.
"""
setminbufsize!(tsk, len) = tsk.minbuflen = len



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
    task.phead = 1
    task.pnext = 0
    task.pfull = false
    if zeroit
        task.buf .= 0
    end
    return
end


"""
    `resizebuffer!(tsk, [nw, [nt]]; dec=false)`

Resize the buffer with space for `nt` frames `nw` long each.
If `nw` is not provided, use the actual one. 

If `nt` is smaller than the actual buffer length, only resize it if `dec==false`. 

See [`clearbuffer!`](@ref) to clear the buffer.
"""
function resizebuffer!(task::DAQTask{T}, nw, nt; dec=false) where {T}
    
    if nw != task.nw
        task.buf = zeros(T, nw, nt)
        task.nw = nw
        task.nt = nt
    elseif nt > task.nt
        task.buf = zeros(T, nw, nt)
        task.nt = nt
    elseif dec && nt < task.nt
        task.buf =  zeros(T, nw, nt)
        task.nt = nt
    end
    
end

function resizebuffer!(task::DAQTask{T}, nt; dec=false) where {T}
    if nt > task.nt
        task.buf = zeros(T, task.nw, nt)
    elseif dec && nt < task.nt # Decrease the size
        task.buf = zeros(T, task.nw, nt)
    end
end


        

resizebuffer!(task::DAQTask{T}) where {T} =
    resizebuffer!(task, minbuflen(task), bufwidth(task))

setdaqthread!(task::DAQTask, thrdstatus=false) = task.thrd=thrdstatus
daqthread(task::DAQTask) = task.thrd


setdaqtask!(task::DAQTask, jtsk::Task) = task.task = jtsk
daqtask(task::DAQTask) = task.task


"""
    `initbuffer!(task)`

Initialize the task for data acquisition.

"""
function initbuffer!(task::DAQTask)
    task.phead = 1
    task.pnext = 0
    task.pfull = false
    task.nread = 0
    task.isreading = false
    task.stop = false
    task.thrd = false
    task.timing = (UInt64(0), UInt64(1), UInt64(1))
    
end

"""
    `nextbuffer(task)`

Returns the next slot in the buffer. The buffer is assumed to be circular so that
 new data will overwrite older data.
"""
function nextbuffer!(task::DAQTask)
    if task.pnext == task.nt
        task.pfull = true
    end
    
    task.pnext = (task.pnext % task.nt) + 1

    if task.pfull
        task.phead = (task.phead % task.nt) + 1
    end
    
    return buffer(task, task.pnext)
end

"""
    `rewindbuffer!(task)`

The last acquired frame may have been comprimised. Remove it.
There might be some problem in this function. For now I will do the minimal
effort
"""
function rewindbuffer!(task::DAQTask)
    if task.pnext != 1
        task.pnext -= 1
    else
        task.pnext = task.nt
    end
end

"""
    `samplingfreq(task)`

    Returns the measured sampling frequency achieved during data acquisition

"""
samplingfreq(task::DAQTask) = task.timing[3] / (1e-9 * (task.timing[2] - task.timing[1]))

settiming!(task, t1, t2, n) = task.timing = (UInt64(t1), UInt64(t2), UInt64(n))





