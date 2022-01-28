
mutable struct DAQTask
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
    "`Task` object executing the data acquisition"
    task::Task
    """
    `DAQTasq`
    
    Creates a structure that handles asynchronous data acquisition.

    This structure stores the number of samples read and the general state of data 
    acquisition. It also provides timing measurements so that sampling frequency
    can estimated.

    """
    DAQTask() = new(0,false,false,false, (UInt64(0),UInt64(0),UInt64(0)), Task(()->0))
end




"""
`isreading(tsk)`

Is the daq device currently acquiring data?

See [`samplesread`](@ref) to see the number of samples already read.
"""
isreading(task::DAQTask) = task.isreading

samplesread(task::DAQTask) = task.nread


"""
`cleartask!(task)`

Clear the buffer. Set the DAQTask parameters to null state. 
"""
function cleartask!(task::DAQTask)
    isreading(task) && error("Can not clear a task while it is reading!")
    
    task.isreading = false # Let's make sure...
    task.stop = false
    task.thrd = false
    task.nread = 0
    return
end



setdaqthread!(task::DAQTask, thrdstatus=false) = task.thrd=thrdstatus
daqthread(task::DAQTask) = task.thrd


setdaqtask!(task::DAQTask, jtsk::Task) = task.task = jtsk
daqtask(task::DAQTask) = task.task

stoptask(task::DAQTask) = task.stop
stoptask!(task::DAQTask, s=true) = task.stop = s



"""
    `samplingrate(task)`

    Returns the measured sampling rateuency achieved during data acquisition

"""
samplingrate(task::DAQTask) = task.timing[3] / (1e-9 * (task.timing[2] - task.timing[1]))

"""
`settiming!(task, t1, t2, n)`

Updates timing information on current data acquisition

 * `task` The `DAQTask` object
 * `t1` Initial time of data acquisition
 * `t2` Last time of data acquisition
 * `n` Number of samples read between `t1` and `t2`

"""
settiming!(task, t1, t2, n) = task.timing = (UInt64(t1), UInt64(t2), UInt64(n))





