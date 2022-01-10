module AbstractDAQ

export AbstractDaqDevice
export DAQTask, isreading, samplesread, issamplesavailable
export stoptask, stoptask!, cleartask!
export samplingfreq, settiming!
export setdaqthread!, daqthread
export setdaqtask!, daqtask
export daqaddinput, daqacquire, daqacquire!, daqstart, daqread, daqread!, daqstop
export daqreference, daqzero, daqconfig
export numchannels, daqchannels
export CircMatBuffer, bufwidth
export nextbuffer, isfull, isempty, flatten, flatten!, capacity

export TestDev
    
abstract type AbstractDaqDevice end

include("daqtask.jl")
include("circbuffer.jl")

include("testdevice.jl")


"""
`daqaddinput(dev, ...)`

Add channels that should be acquired.
"""
daqaddinput(dev::AbstractDaqDevice)=error("Not implemented for AbstractDaqDevice")

"""
`daqacquire(dev)`

Start a synchronous data acquisition run.
"""
daqacquire(dev::AbstractDaqDevice) = error("Not implemented for AbstractDaqDevice")
daqacquire!(dev::AbstractDaqDevice) = error("Not implemented for AbstractDaqDevice")

"""
`daqstart(dev, ...)`

Initiate a data acquisition run asyncrhonously.
"""
daqstart(dev::AbstractDaqDevice, usethread=false) =
    error("Not implemented for AbstractDaqDevice")

"""
`daqread(dev)`

Wait to finish the data acquisition run and return the data.
"""
daqread(dev::AbstractDaqDevice) = error("Not implemented for AbstractDaqDevice")
daqread!(dev::AbstractDaqDevice) = error("Not implemented for AbstractDaqDevice")


"""
`daqstop(dev)`

Stop asynchronous data acquisition.
"""
daqstop(dev::AbstractDaqDevice) = error("Not implemented for AbstractDaqDevice")

"""
`daqreference(dev)`

Use a measurement point as a reference. Specific channels can be specified.

"""
daqreference(dev::AbstractDaqDevice) =error("Not implemented for AbstractDaqDevice")

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


daqzero(dev::AbstractDaqDevice) =
    error("Not implemented for AbstractDaqDevice")

samplesread(dev::AbstractDaqDevice) =
    error("Not implemented for AbstractDaqDevice")

isreading(dev::AbstractDaqDevice) = 
    error("Not implemented for AbstractDaqDevice")

issamplesavailable(dev::AbstractDaqDevice) = 
    error("Not implemented for AbstractDaqDevice")

numchannels(dev::AbstractDaqDevice) = 
    error("Not implemented for AbstractDaqDevice")

daqchannels(dev::AbstractDaqDevice) = 
    error("Not implemented for AbstractDaqDevice")

end
