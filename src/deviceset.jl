# Several devices together

export DeviceSet

mutable struct DeviceSet{DevList} <: AbstractDAQ
    devname::String
    iref::Int
    devices::DevList
    time::DateTime
    devdict::Dict{String,Int}
end


function DeviceSet(dname, devices::DevList, iref=1) where {DevList}

    devdict = Dict{String,Int}()
    ndev = length(devices)
    for (i, dev) in enumerate(devices)
        devdict[devname(dev)] = i
    end
    
    return DeviceSet(dname, iref, devices, now(), devdict)
end


    

function daqstart(devs::DeviceSet)
    devs.time = now()
    for dev in devs.devices
        daqstart(dev)
    end
    return
end


function daqread(devs::DeviceSet)
    data = Dict{String,AbstractMeasData}()
    
    for dev in devs.devices
        d = daqread(dev)
        data[devname(d)] = d
    end
    return data, devs.time
end

function daqacquire(devs::DeviceSet)
    daqstart(devs)
    return daqread(devs)
end

samplesread(devs::DeviceSet) = samplesread(devs.devices[devs.iref])
isreading(devs::DeviceSet) = isreading(dev.devices[devs.iref])
isdaqfinished(devs::DeviceSet) = isdaqfinished(dev.devices[devs.iref])
issamplesavailable(devs::DeviceSet)=issamplesavailable(devs.devices[devs.iref])


    
function savedaqdata(h5, devs::DeviceSet, data)
    g = create_group(h5, devname(devs))
    attributes(g)["type"] = "DeviceSet"
    attributes(g)["devices"] = collect(keys(data))
    attributes(g)["time"] = time2ms(devs.time)
    for (k,v) in data
        savedaqdata(g, v)
    end
end

function savedaqconfig(h5, devs::DeviceSet)

    ndevs = length(devs.devices)
    g = create_group(h5, devname(devs))
    for dev in devs.devices
        savedaqconfig(g, dev)
    end
end

                        
        
