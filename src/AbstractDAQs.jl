module AbstractDAQs

export AbstractDAQ, AbstractPressureScanner
export DAQTask, isreading, samplesread, issamplesavailable
export isdaqfinished
export stoptask, stoptask!, cleartask!
export samplingfreq, settiming!
export setdaqthread!, daqthread
export setdaqtask!, daqtask
export daqaddinput, daqacquire, daqacquire!, daqstart
export daqread, daqread!, daqstop, daqdevname

export daqreference, daqzero, daqconfig, daqconfigdev
export numchannels, daqchannels
export CircMatBuffer, bufwidth
export nextbuffer, isfull, isempty, flatten, flatten!, capacity
export DAQConfig, iparameters, fparameters, sparameters
export daqdevip, daqdevmodel, daqdevserialnum, daqdevtag
export savedaqdata, savedaqconfig
export TestDev


abstract type AbstractDAQ end
abstract type AbstractPressureScanner <: AbstractDAQ end

mutable struct DAQConfig
    "Name for referening the device"
    devname::String
    "IP address where the device is located"
    ip::String
    "Model of device"
    model::String
    "Serial number of the device"
    sn::String
    "Storage tag of the device"
    tag::String
    "Integer configuration parameters"
    ipars::Dict{String,Int}
    "Float64  configuration parameters"
    fpars::Dict{String,Float64}
    "String configuration parameters"
    spars::Dict{String,String}
end

"""
`DAQConfig(;devname="", ip="", model="", sn="",tag="")`

Create data structure to store device configuration. 

Hopefuly, with the information stored in this struct, reproducible 
data configuration of the devices can be achieved.
"""
function DAQConfig(;devname="", ip="", model="", sn="",tag="")
    
    fpars = Dict{String,Float64}()
    ipars = Dict{String,Int}()
    spars = Dict{String,String}()
    return DAQConfig(devname, ip, model, sn, tag, ipars, fpars, spars)
end

function DAQConfig(ipars, fpars, spars;devname="", ip="", model="", sn="",tag="")
    
    return DAQConfig(devname, ip, model, sn, tag, ipars, fpars, spars)
end

"Retrieve integer configuration parameter"
iparameters(dconf::DAQConfig, param) = dconf.ipars[param]
"Retrieve string configuration parameter"
sparameters(dconf::DAQConfig, param) = dconf.spars[param]
"Retrieve float configuration parameter"
fparameters(dconf::DAQConfig, param) = dconf.fpars[param]

iparameters(dconf::DAQConfig) = dconf.ipars
sparameters(dconf::DAQConfig) = dconf.spars
fparameters(dconf::DAQConfig) = dconf.fpars

"Retrieve device name"
daqdevname(dconf::DAQConfig) = dconf.devname
"Retrieve device IP address"
daqdevip(dconf::DAQConfig) = dconf.ip
"Retrieve device model"
daqdevmodel(dconf::DAQConfig) = dconf.model
"Retrieve device serial number"
daqdevserialnum(dconf::DAQConfig) = dconf.sn
"Retrieve device tag"
daqdevtag(dconf::DAQConfig) = dconf.tag

iparameters(dev::AbstractDAQ, param) = dev.conf.ipars[param]
sparameters(dev::AbstractDAQ, param) = dev.conf.spars[param]
fparameters(dev::AbstractDAQ, param) = dev.conf.fpars[param]

iparameters(dev::AbstractDAQ) = dev.conf.ipars
sparameters(dev::AbstractDAQ) = dev.conf.spars
fparameters(dev::AbstractDAQ) = dev.conf.fpars

daqdevname(dev::AbstractDAQ) = dev.conf.devname
daqdevip(dev::AbstractDAQ) = dev.conf.ip
daqdevmodel(dev::AbstractDAQ) = dev.conf.model
daqdevserialnum(dev::AbstractDAQ) = dev.conf.sn
daqdevtag(dev::AbstractDAQ) = dev.conf.tag

                


include("daqtask.jl")
include("circbuffer.jl")
include("hdf5io.jl")
include("testdevice.jl")


"""
`daqaddinput(dev, ...)`

Add channels that should be acquired.
"""
daqaddinput(dev::AbstractDAQ)=error("Not implemented for AbstractDAQ")

"""
`daqacquire(dev)`

Start a synchronous data acquisition run.
"""
daqacquire(dev::AbstractDAQ) = error("Not implemented for AbstractDAQ")
daqacquire!(dev::AbstractDAQ) = error("Not implemented for AbstractDAQ")

"""
`daqstart(dev, ...)`

Initiate a data acquisition run asyncrhonously.
"""
daqstart(dev::AbstractDAQ, usethread=false) =
    error("Not implemented for AbstractDAQ")

"""
`daqread(dev)`

Wait to finish the data acquisition run and return the data.
"""
daqread(dev::AbstractDAQ) = error("Not implemented for AbstractDAQ")
daqread!(dev::AbstractDAQ) = error("Not implemented for AbstractDAQ")


"""
`daqstop(dev)`

Stop asynchronous data acquisition.
"""
daqstop(dev::AbstractDAQ) = error("Not implemented for AbstractDAQ")

"""
`daqreference(dev)`

Use a measurement point as a reference. Specific channels can be specified.

"""
daqreference(dev::AbstractDAQ) =error("Not implemented for AbstractDAQ")

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
daqconfig(dev::AbstractDAQ; kw...) =
    error("Not implemented for AbstractDAQ")

"""
`daqconfigdev(dev; kw...)`

Device configuration. 

Does the samething as [`daqconfig`](@ref) but uses the devices terminology and exact
parameters.
"""
daqconfigdev(dev::AbstractDAQ; kw...) = 
    error("Not implemented for AbstractDAQ")

"""
`daqzero(dev)`

Perform a zero calibration of the DAQ device. The exact nature of this zero calibration.
"""
daqzero(dev::AbstractDAQ) =
    error("Not implemented for AbstractDAQ")

"""
`samplesread(dev)`

Return the number of samples read since the beginning of data aquisition.
"""
samplesread(dev::AbstractDAQ) =
    error("Not implemented for AbstractDAQ")

"""
`isreading(dev)`

Returns `true` if data acquisition is ongoing, `false` otherwise.
"""
isreading(dev::AbstractDAQ) = 
    error("Not implemented for AbstractDAQ")

"""
`isdaqfinished(dev)`

Returns true if the device has completed its operations.
"""
isdaqfinished(dev::AbstractDAQ) = 
    error("Not implemented for AbstractDAQ")
"""
`issamplesavailable(dev)`

Are samples available for reading?
"""
issamplesavailable(dev::AbstractDAQ) = 
    error("Not implemented for AbstractDAQ")

"""
`numchannels(dev)`

Number of channels available or configured in the DAQ device.
"""
numchannels(dev::AbstractDAQ) = 
    error("Not implemented for AbstractDAQ")

"""
`daqchannels(dev)`

Returns the DAQ channels available or configured in the DAQ device.
"""
daqchannels(dev::AbstractDAQ) = 
    error("Not implemented for AbstractDAQ")

end
