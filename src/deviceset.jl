# Several devices together

export DeviceSet

mutable struct DeviceSet{DevList} <: AbstractDAQ
    devname::String
    iref::Int
    devices::DevList
    devdict::Dict{String,Int}
end


function DeviceSet(dname, devices::DevList, iref=1) where {DevList}

    devdict = Dict{String,Int}()
    ndev = length(devices)
    for (i, dev) in enumerate(devices)
        devdict[devname(dev)] = i
    end
    
    return DeviceSet(dname, iref, devices, devdict)
end


    

function daqstart(devs::DeviceSet)
    for dev in devs.devices
        daqstart(dev)
    end
    return
end


function daqread(devs::DeviceSet)
    data = Any[]
    
    for dev in devs.devices
        d = daqread(dev)
        push!(data, d)
    end
    return data
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
    ndevs = length(devs.devices)
    g = create_group(h5, devname(devs))
    attributes(g)["type"] = "DeviceSet"
    attributes(g)["devices"] = devname.(devs.devices)
    for i in 1:ndevs
        savedaqdata(g, devs.devices[i], data[i][1]; fs=data[i][2])
    end
end

function savedaqconfig(h5, devs::DeviceSet)

    ndevs = length(devs.devices)
    g = create_group(h5, devname(devs))
    for dev in devs.devices
        savedaqconfig(g, dev)
    end
end

                        
        
