using HDF5

function savedaqdata(h5, dev, X, fs)

    devname = daqdevname(dev)
    h5[devname] = X
    d = h5[devname]
    attributes(d)["fs"] = fs

    return
end


function savedaqconfig(h5, dev)

    devname = daqdevname(dev)
    g = create_group(h5, devname)
    g["devname"] = devname
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
    return 
end
