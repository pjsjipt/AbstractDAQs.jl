module AbstractDAQ

export AbstractDaqDevice, AbstractPressureScanner
export DAQTask, isreading, samplesread, issamplesavailable
export stoptask, stoptask!, cleartask!
export samplingfreq, settiming!
export setdaqthread!, daqthread
export setdaqtask!, daqtask
export daqaddinput, daqacquire, daqacquire!, daqstart, daqread, daqread!, daqstop
export daqreference, daqzero, daqconfig, daqconfigdev
export numchannels, daqchannels
export CircMatBuffer, bufwidth
export nextbuffer, isfull, isempty, flatten, flatten!, capacity

export TestDev
    
abstract type AbstractDaqDevice end
abstract type AbstractPressureScanner <: AbstractDaqDevice end

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

Generic configuration of data acquisition. Different devices might
have other capabilities and different terminologies. To use the device specific
parameters and terminology, use function [`daqconfigdev`](@ref). 

In this generic interface, the following keyword parameters are allowed:

 * `freq` or `dt` (only one of them)
    - `freq` Sampling frequency in Hz
    - `dt` Sampling time in s
 * `nsamples` or `time` (only one of them) 
    - `nsamples` Number of samples to be read. 0 usually means continous reading
    - `time` sampling time in seconds
 * `avg` Number of samples that should be read and averaged for each output.
 * `trigger` An integer specifying the trigger type 0 - internal trigger, other values depend on the specific device.
"""
daqconfig(dev::AbstractDaqDevice; kw...) =
    error("Not implemented for AbstractDaqDevice")

"""
`daqconfigdev(dev; kw...)`

Device configuration. 

Does the samething as [`daqconfig`](@ref) but uses the devices terminology and exact
parameters.
"""
daqconfigdev(dev::AbstractDaqDevice; kw...) = 
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
