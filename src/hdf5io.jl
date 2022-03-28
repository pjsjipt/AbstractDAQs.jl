using HDF5

"""
`savedaqdata(h5, dev::AbstractDAQ, X; kw...)`
`savedaqdata(h5, X::MeasData; kw...)`


Saves data read by a DAQ device in a HDF5 group

The group where the data will be stored is specified by the parameter `h5`. 

The data is stored under the device name of the daq device (`devname(dev)`).

Other parameters related to the data acquisition can be provided using the key word 
arguments `kw`. They will be stored under the keyword name.

The user should ensure that the data being stored (including attributes) have types
compatible with the HDF5.jl package.

"""
function keepsavedaqdata(h5, dev::AbstractDAQ, X; kw...)

    dname = devname(dev)
    h5[dname] = X
    d = h5[dname]

    for (k, v) in kw
        attributes(d)[string(k)] = v
    end
    return
end

function savedaqdata(h5, dev::AbstractDAQ, X::MeasData; kw...)
    dname = devname(X)
    h5[dname] = measdata(X)
    d = h5[dname]
    attributes(d)["devname"] = dname
    attributes(d)["devtype"] = devtype(X)
    attributes(d)["time"] = AbstractDAQs.time2ms(meastime(X))
    attributes(d)["fs"] = samplingrate(X)
    attributes(d)["info"] = X.info
    attributes(d)["chans"] = collect(keys(X.chans))[sortperm(collect(values(X.chans)))]
    
    for (k,v) in kw
        attributes(d)[string(k)] = v
    end
    return
end


function savedaqdata(h5, X::MeasData; kw...)
    dname = devname(X)
    h5[dname] = measdata(X)
    d = h5[dname]
    attributes(d)["devname"] = dname
    attributes(d)["devtype"] = devtype(X)
    attributes(d)["time"] = AbstractDAQs.time2ms(meastime(X))
    attributes(d)["fs"] = samplingrate(X)
    attributes(d)["info"] = X.info
    attributes(d)["chans"] = collect(keys(X.chans))[sortperm(collect(values(X.chans)))]
    
    for (k,v) in kw
        attributes(d)[string(k)] = v
    end
    return
end

"""
`savedaqconfig(h5, dev::AbstractDAQ; kw...)`

Save device configuration. Stores information contained in the `conf::DAQConfig` 
field of the daq device. Other information can be stored using the keyword parameters
where the keyword names are used as names in the HDF5 files.

The configuration is stored under the device name (`devname(dev)`). User should make
sure that different devices do not have the same name.

The user should ensure that the data being stored ( have types
compatible with the HDF5.jl package.

"""
function savedaqconfig(h5, dev::AbstractDAQ; kw...)

    device = string(typeof(dev))
    dname = devname(dev)
    g = create_group(h5, dname)
    g["device"] = device
    g["devname"] = dname
    g["ip"] = daqdevip(dev)
    g["model"] = daqdevmodel(dev)
    g["sn"] = daqdevserialnum(dev)
    g["tag"] = daqdevtag(dev)
    
    g["iparameters_names"] = collect(keys(iparameters(dev)))
    g["iparameters"] = collect(values(iparameters(dev)))

    g["sparameters_names"] = collect(keys(sparameters(dev)))
    g["sparameters"] = collect(values(sparameters(dev)))
    
    g["fparameters_names"] = collect(keys(fparameters(dev)))
    g["fparameters"] = collect(values(fparameters(dev)))

    g["daqchannels"] = daqchannels(dev)

    for (k,v) in kw
        g[string(k)] = v
    end
    
    return 
end
