using HDF5

function savedaqdata(h5, devname, X, fs)

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
    
    g["iparameters_names"] = keys(iparameters(dev))
    g["iparameters"] = values(iparameters(dev))

    g["sparameters_names"] = keys(sparameters(dev))
    g["sparameters"] = values(sparameters(dev))
    
    g["fparameters_names"] = keys(fparameters(dev))
    g["fparameters"] = values(fparameters(dev))

    g["daqchannels"] = daqchannels(dev)
    return 
end
