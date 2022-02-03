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
`daqconfig(dev; rate, nsamples, time, avg=1)`

Generic configuration of data acquisition. Different devices might
have other capabilities and different terminologies. To use the device specific
parameters and terminology, use function [`daqconfigdev`](@ref). 

In this generic interface, the following keyword parameters are allowed:

 * `rate` or `dt` (only one of them)
    - `rate` Sampling rate in Hz
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



