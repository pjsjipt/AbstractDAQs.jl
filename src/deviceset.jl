# Several devices together

export DeviceSet, MeasDataSet

mutable struct DeviceSet{DevList} <: AbstractDAQ
    devname::String
    iref::Int
    devices::DevList
    time::DateTime
    devdict::OrderedDict{String,Int}
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

    devdict = OrderedDict{String,Int}()
    ndev = length(devices)
    for (i, dev) in enumerate(devices)
        devdict[devname(dev)] = i
    end
    
    return DeviceSet(dname, iref, devices, now(), devdict)
end

import Base.getindex
getindex(dev::DeviceSet, i) = dev.devices[i]
function getindex(devset::DeviceSet, dname::AbstractString)
    for dev in devset.devices
        if devname(dev) == dname
            return dev
        end
    end

    # If we got here, this the actuator doesn't exist
    # throw an exception:
    throw(KeyError(dname))
end


struct MeasDataSet <: AbstractMeasData
    devname::String
    devtype::String
    time::DateTime
    data::OrderedDict{String,AbstractMeasData}
end

devname(d::MeasDataSet) = d.devname
devtype(d::MeasDataSet) = d.devtype

    
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
    data = OrderedDict{String,MeasData}()
    
    for dev in devs.devices
        d = daqread(dev)
        data[devname(d)] = d
    end
    
    return MeasDataSet(devname(devs), "DeviceSet", devs.time, data)
end

"""
`daqacquire(devs::DeviceSet)`

Execute a synchronous data acquisition of every device.
"""
function daqacquire(devs::DeviceSet)
    daqstart(devs)
    return daqread(devs)
end

#import Base.getindex
#Base.getindex
samplesread(devs::DeviceSet) = samplesread(devs.devices[devs.iref])
isreading(devs::DeviceSet) = isreading(dev.devices[devs.iref])
isdaqfinished(devs::DeviceSet) = isdaqfinished(dev.devices[devs.iref])
issamplesavailable(devs::DeviceSet)=issamplesavailable(devs.devices[devs.iref])


"""
`savedaqdata(h5, devs::DeviceSet, data)`

Save the acquired data to a path inside a HDF5 file. It will save the data of each of the 
devices.
"""    
function savedaqdata(h5, devs::DeviceSet{T}, data; kw...) where {T}
    g = create_group(h5, devname(devs))
    attributes(g)["devtype"] = "DeviceSet"
    attributes(g)["devices"] = collect(keys(data))
    attributes(g)["time"] = time2ms(devs.time)
    for (k,v) in kw
        attributes(g)[string(k)] = v
    end

    for (k,v) in data
        savedaqdata(g, v)
    end
end


"""
`savedaqdata(h5, devs::DeviceSet, data)`

Save the acquired data to a path inside a HDF5 file. It will save the data of each of the 
devices.
"""    
function savedaqdata(h5, data::MeasDataSet; kw...) where {T}
    g = create_group(h5, data.devname)
    attributes(g)["devname"] = dev.devname
    attributes(g)["devtype"] = "DeviceSet"
    attributes(g)["devices"] = collect(keys(data.data))
    attributes(g)["time"] = time2ms(data.time)
    for (k,v) in kw
        attributes(g)[string(k)] = v
    end

    for (k,v) in data.data
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

                        
        
