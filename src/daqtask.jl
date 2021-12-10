


mutable struct DAQTask #{DAQ <: AbstractDaqDevice}
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
    buffer::Matrix{UInt8}
    "Number of frames that can be stored in the buffer"
    buflen::Int
    "Flag that can be used to communicate information"
    flag::Int
    "Julia task (@async or @spawn)"
    task::Task
    DAQTask() = new(false, false, false, 0, 0, zeros(UInt8,0,0), 0, 0)
    DAQTask(bwidth::Integer, blen::Integer) = new(false, false, false, 0, 0,
                                                  zeros(UInt8, bwidth,blen),
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


samplesavailable(task::DAQTask) = task.nread > 0
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
    `resizebuffer!(tsk, [buflen, [fsize]])`

Resize the buffer with space for `buflen` frames `fsize` long each.
If `fsize` is not provided, use the actual one. 

If `buflen` is smaller than the actual buffer length, keep it. If this argument is 
not provided, return to the default size `task.buflen` with present `fsize`.

See [`clearbuffer!`](@ref) to clear the buffer.
"""
function resizebuffer!(task::DAQTask, buflen, fsize)
    nr,nc = size(task.buffer)

    if nr == fsize
        resizebuffer!(task, buflen)
    else
        task.buffer = zeros(UInt8, nr, buflen)
        clearbuffer!(task, false)
    end
    
end

function resizebuffer!(task::DAQTask, buflen)

    nr, nc = size(task.buffer)
    if buflen > nc
        task.buffer = zeros(UInt8, nr, buflen)
        clearbuffer!(task, false)
    end
    return
end


resizebuffer!(task::DAQTask) = resizebuffer!(task, task.buflen, size(task.buffer,1))


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
    task.nred = 0
    task.idx = 0

    if zeroit
        task.buffer .= 0
    end
    return
end


taskflag(task::DAQTask) = task.flag
settaskflag(task::DAQTask, flg) = task.flag=flg

setdaqthread!(task::DAQTask, thrdstatus=false) = task.thrd=thrdstatus
daqthread(task::DAQTask) = task.thrd


setdaqtask!(task::DAQTask, jtsk::Task) = task.task = jtsk
daqtask(task::DAQTask) = task.task
