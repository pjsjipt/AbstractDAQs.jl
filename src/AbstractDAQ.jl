module AbstractDAQ

export AbstractDaqDevice
export DAQTask, isreading, samplesread, samplesavailable, buffer
export resizebuffer!, clearbuffer!, setdaqthread!, daqthread
export setdaqtask!, daqtask

export TestDev
    
abstract type AbstractDaqDevice end

include("daqtask.jl")
include("testdevice.jl")

end
