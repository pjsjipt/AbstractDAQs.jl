# Several devices together

using Dates

mutable struct DeviceSet
    devlst::Vector{AbstractDAQ}
    measlst::Vector{Vector{Int}}
end


DeviceSet(devs...) = DeviceSet(AbstractDAQ[d for d in devs], collect(1:length(devs)))

function startmeasurement(devs::DeviceSet, level=1, usethread=true)

    idx = devs.measlst[level]

    t = now()
    for i in idx
        daqstart(devs.devlst[i], usethread=usethread)
    end

    return t
end

function readmeasurement(devs::DeviceSet, level=1)

    idx = devs.measlst[level]
    data = Any[]
    for i in idx
        x,fs = daqread(devs.devlst[i])
        push!(data, (x,fs))
    end

    return data
end

function acquiremeasurement(devs::DeviceSer, level=1, usethread=true)

    t = startmeasurement(devs, level, usethread)
    data = readmeasurement(devs, level)

    return t, data
end

    
function savemeasdata(h5, t, meas, devs::DeviceSet, level=1)
    
end

                        
        
