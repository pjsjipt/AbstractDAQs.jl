# Several devices together

export DeviceSet, MeasDataSet

mutable struct DeviceSet{DevList} <: AbstractDAQ
    "Device name associated to this `DeviceSet`"
    devname::String
    "Index of most relevant measurement device"
    iref::Int
    "List of devices"
    devices::DevList
    "Starting time of data acquisition"
    time::DateTime
    "Map from device name to device index in `devices`."
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

"""
`dev[i]`

Return the `i`-th device of a device set
"""
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

"""
`MeasDataSet(devname, devtype, time, data)`

Stores the data acquired by a `DeviceSet`.
"""
struct MeasDataSet <: AbstractMeasData
    "Device name"
    devname::String
    "Device type (`DeviceSet`)"
    devtype::String
    "Data acquisition time"
    time::DateTime
    "Data acquired by each device in the `DeviceSet`"
    data::OrderedDict{String,AbstractMeasData}
end

"""
`devname(d::MeasDataSet)`

Return the device name that acquired the data.
"""
devname(d::MeasDataSet) = d.devname

"""
`devtype(d::MeasDataSet)`

Return the device type that acquired the data ([`DeviceSet`](@ref) in this case).
"""
devtype(d::MeasDataSet) = d.devtype

"""
`meastime(d::MeasDataSet)`

Return the [`DateTime`](@ref) when the device started to acquire the data from 
a [`DeviceSet`](@ref).
"""
meastime(d::MeasDataSet) = d.time

"""
`d["some/path/to/measurements"]`

Retrieve data acquired stored in a [`MeasDataSet`](@ref).

The data,  in this case, was acquired by several devices that 
make up a [`DeviceSet](@ref). Thus sub-device might be another [`MeasDataSet`](@ref)
or, more commonly, a [`MeasData`](@ref) structure. 

As an example, imagine that the [`DeviceSet`](@ref) is madeup of `dev1` and `dev2` 
devices. 

```
d["dev1"]
``` 

returns the data acquired by `dev1`. To get a specific channel, you can use

```
d["dev1/chanx"]
```

and this will return the value stored by channel `chanx` of `dev1`.

The channel can be specified independently as in the following example:

```
d["dev1", "chanx"]
```

or it can be specified by index:

```
d["dev1", 3]
```

(assuming `chanx` corresponds do channel 3)

In both of last cases, the indexing is forwarded to the `getindex` method for
[`MeasData`](@ref) for data retrieval.

"""
function getindex(d::MeasDataSet, path::String)
    p = split(path, '/')
    dev = p[1]
    if length(p) == 1
        return d.data[dev]
    else
        return d.data[dev][join(p[2:end], '/')]
    end
    
end

function getindex(d::MeasDataSet, path::String, idx...)
    p = split(path, '/')
    dev = p[1]
    dev = p[1]
    if length(p) == 1
        return getindex(d.data[dev], idx...)
    else
        return getindex(d.data[dev], join(p[2:end], '/'), idx...)
    end
end

"""
`daqchannels(d::MeasDataSet)`

Return channel names associated with each device that is acquiring data. 
The device name is prepended to the channel name separated by a '/'.
"""
function daqchannels(d::MeasDataSet)
    chans = String[]
    for (k,v) in d.data
        devchans = daqchannels(v)
        for c in devchans
            push!(chans, k * "/" * c)
        end
    end
    return chans
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
    attributes(g)["devname"] = data.devname
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

                        
        
