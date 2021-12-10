module AbstractDAQ

export AbstractDaqDevice
export DAQTask, isreading, samplesread, samplesavailable, buffer
export resizebuffer!, clearbuffer!, setdaqthread!, daqthread
export setdaqtask!, daqtask
export daqaddinput

export TestDev
    
abstract type AbstractDaqDevice end

include("daqtask.jl")
include("testdevice.jl")

daqaddinput(dev::AbstractDaqDevice, ...) = error("Not implemented for AbstractDaqDevice")
end
