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


"""
`daqaddinput(dev, ...)`

Add channels that should be acquired.
"""
daqaddinput(dev::AbstractDaqDevice, ...) = error("Not implemented for AbstractDaqDevice")

"""
`daqacquire(dev)`

Start a synchronous data acquisition run.
"""
daqacquire(dev::AbstractDaqDevice) = error("Not implemented for AbstractDaqDevice")

"""
`daqstart(dev, ...)`

Initiate a data acquisition run asyncrhonously.
"""
daqstart(dev::AbstraceDaqDevice, ...) = error("Not implemented for AbstractDaqDevice")

"""
`daqread(dev)`

Wait to finish the data acquisition run and return the data.
"""
daqread(dev::AbstraceDaqDevice) = error("Not implemented for AbstractDaqDevice")

"""
`daqstop(dev)`

Stop asynchronous data acquisition.
"""
daqstop(dev::AbstraceDaqDevice) = error("Not implemented for AbstractDaqDevice")

"""
`daqreference(dev)`

Use a measurement point as a reference. Specific channels can be specified.

"""
daqreference(dev::AbstractDaqDevice, ichans) =error("Not implemented for AbstractDaqDevice")

"""
`daqconfig(dev, freq, nsamples, time, avg)`

Generic configuration of data acquisition. 

 * `freq` Keyword argument specifying sampling frequency
 * `nsamples` Number of samples to be read. If 0, use parameter `time`
 * `time` Time in seconds during which data must be acquired. If zero, use `nsamples`
 * `avg` Number of samples that should be read and averaged for each sample.

"""
daqconfig(dev::AbstractDaqDevice; freq, nsamples=0, time=0, avg=1) =
    error("Not implemented for AbstractDaqDevice")
end
