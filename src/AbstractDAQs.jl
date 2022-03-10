module AbstractDAQs

export AbstractDAQ, AbstractPressureScanner
export DAQTask, isreading, samplesread, issamplesavailable
export isdaqfinished
export stoptask, stoptask!, cleartask!
export samplingrate, settiming!
export setdaqthread!, daqthread
export setdaqtask!, daqtask
export daqaddinput, daqacquire, daqacquire!, daqstart
export daqread, daqread!, daqstop, devname, devtype

export daqreference, daqzero, daqconfig, daqconfigdev
export numchannels, daqchannels
export CircMatBuffer, bufwidth
export nextbuffer, isfull, isempty, flatten, flatten!, capacity
export DAQConfig, iparameters, fparameters, sparameters
export daqdevip, daqdevmodel, daqdevserialnum, daqdevtag
export savedaqdata, savedaqconfig
export TestDev

using Dates

"Abstract type to handle any kind of device"
abstract type AbstractDevice end

"Abstract type to handle data acquisition devices"
abstract type AbstractDAQ <: AbstractDevice end

"Abstract type to handle pressure scanners"
abstract type AbstractPressureScanner <: AbstractDAQ end


"Returns the type of device"
devtype(dev) = string(typeof(dev))

"""
`devname(dev::AbstractDevice)`

The device name is a string that is used to refer to a specific device.

This string is used when saving data and post processing.
"""
devname(dev::AbstractDevice) = dev.devname

include("utils.jl")
include("daqconfig.jl")
include("daqtask.jl")
include("circbuffer.jl")
include("measdata.jl")
include("hdf5io.jl")
include("interface.jl")
include("deviceset.jl")
include("testdevice.jl")
end
