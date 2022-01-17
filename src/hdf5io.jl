using HDF5

"""
`savedaqdata(h5, dev, X; kw...)`

Saves data read by a DAQ device in a HDF5 group

The group where the data will be stored is specified by the parameter `h5`. 

The data is stored under the device name of the daq device (`daqdevname(dev)`).

Other parameters related to the data acquisition can be provided using the key word 
arguments `kw`. They will be stored under the keyword name.

The user should ensure that the data being stored (including attributes) have types
compatible with the HDF5.jl package.

"""
function savedaqdata(h5, dev::AbstractDAQ, X; kw...)

    devname = daqdevname(dev)
    h5[devname] = X
    d = h5[devname]

    for (k, v) in kw
        attributes(d)[string(k)] = v
    end
    return
end


"""
`savedaqconfig(h5, dev::AbstractDAQ; kw...)`

Save device configuration. Stores information contained in the `conf::DAQConfig` 
field of the daq device. Other information can be stored using the keyword parameters
where the keyword names are used as names in the HDF5 files.

The configuration is stored under the device name (`daqdevname(dev)`). User should make
sure that different devices do not have the same name.

The user should ensure that the data being stored ( have types
compatible with the HDF5.jl package.

"""
function savedaqconfig(h5, dev::AbstractDAQ; kw...)

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

    for (k,v) in kw
        g[string(k)] = v
    end
    
    return 
end
