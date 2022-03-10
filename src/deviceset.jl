# Several devices together

export DeviceSet

mutable struct DeviceSet{DevList} <: AbstractDAQ
    devname::String
    iref::Int
    devices::DevList
    time::DateTime
    devdict::Dict{String,Int}
end

"""
`DeviceSet(dname, devices::DevList, iref=1)`

Create a meta device that handles data acquisition from several independent interfaces.

The `devices` argument specifies the individual DAQ devices that are used. It could
be a tuple (recommended) or a vector of AbstractDAQ.

The argument `iref` corresponds to the reference device (if it exists). 
This reference device is simply the device that is used when checking if data acquisition 
is ongoing or how many samples have been read.
"""
function DeviceSet(dname, devices::DevList, iref=1) where {DevList}

    devdict = Dict{String,Int}()
    ndev = length(devices)
    for (i, dev) in enumerate(devices)
        devdict[devname(dev)] = i
    end
    
    return DeviceSet(dname, iref, devices, now(), devdict)
end


    
"""
`daqstart(devs::DeviceSet)`

Start asynchrohous data acquisition on every device.
"""
function daqstart(devs::DeviceSet)
    devs.time = now()
    for dev in devs.devices
        daqstart(dev)
    end
    return
end

"""
`daqread(devs::DeviceSet)`

Read the data from every device in `DeviceSet`. It stores this data in a dictionary
where the key is the device name and the value is the data.
"""
function daqread(devs::DeviceSet)
    data = Dict{String,AbstractMeasData}()
    
    for dev in devs.devices
        d = daqread(dev)
        data[devname(d)] = d
    end
    return data, devs.time
end

"""
`daqacquire(devs::DeviceSet)`

Execute a synchronous data acquisition of every device.
"""
function daqacquire(devs::DeviceSet)
    daqstart(devs)
    return daqread(devs)
end


samplesread(devs::DeviceSet) = samplesread(devs.devices[devs.iref])
isreading(devs::DeviceSet) = isreading(dev.devices[devs.iref])
isdaqfinished(devs::DeviceSet) = isdaqfinished(dev.devices[devs.iref])
issamplesavailable(devs::DeviceSet)=issamplesavailable(devs.devices[devs.iref])


"""
`savedaqdata(h5, devs::DeviceSet, data)`

Save the acquired data to a path inside a HDF5 file. It will save the data of each of the 
devices.
"""    
function savedaqdata(h5, devs::DeviceSet, data)
    g = create_group(h5, devname(devs))
    attributes(g)["type"] = "DeviceSet"
    attributes(g)["devices"] = collect(keys(data))
    attributes(g)["time"] = time2ms(devs.time)
    for (k,v) in data
        savedaqdata(g, v)
    end
end

"""
`savedaqconfig(h5, devs::DeviceSet)`

Saves the configuration of a `DeviceSet`. This configuration corresponds to the 
configuration of each devince in `devs::DeviceSet`.
"""
function savedaqconfig(h5, devs::DeviceSet)

    ndevs = length(devs.devices)
    g = create_group(h5, devname(devs))
    for dev in devs.devices
        savedaqconfig(g, dev)
    end
end

                        
        
