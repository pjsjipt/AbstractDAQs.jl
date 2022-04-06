using HDF5

"""
`savedaqdata(h5, X::MeasData; kw...)`


Saves data read by a DAQ device in a HDF5 group

The group where the data will be stored is specified by the parameter `h5`. 

The data is stored under the device name of the daq device (`devname(dev)`).

Other parameters related to the data acquisition can be provided using the key word 
arguments `kw`. They will be stored under the keyword name.

The user should ensure that the data being stored (including attributes) have types
compatible with the HDF5.jl package.

"""
function savedaqdata(h5, X::MeasData; kw...)
    dname = devname(X)
    h5[dname] = measdata(X)
    d = h5[dname]
    attributes(d)["devname"] = dname
    attributes(d)["devtype"] = devtype(X)
    attributes(d)["time"] = AbstractDAQs.time2ms(meastime(X))
    attributes(d)["rate"] = samplingrate(X)
    attributes(d)["chans"] = collect(keys(X.chans))
    
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

function readdaqdata_dev(h, dtype, attr)

    if "devname" ∈ attr
        dname = read(attributes(h)["devname"])
    else
        dname = "unknown"
    end

    if "time" ∈ attr
        t = ms2time(read(attributes(h)["time"]))
    else
        t = now()
    end
    
    if "rate" ∈ attr
        rate = read(attributes(h)["rate"])
    elseif "fs" ∈ attr
        rate = read(attributes(h)["fs"])
    else
        rate = 1.0
    end

    data = read(h)

    nchans = size(data,1)
    
    if "chans" ∈ attr
        chans = read(attributes(h)["chans"])
    else
        chans = "C" .* string.(1:nchans)
    end

    ch = OrderedDict{String,Int}()
    for (i,c) in enumerate(chans)
        ch[c] = i
    end
    
    return MeasData(dname, dtype, t, rate, data, ch)
end

function readdaqdata_devset(h, dtype, attr)

    if !("devices" ∈ attr)
        error("There should be a 'devices' attribute in HDF5 file for it to be a valid MeasDataSet object")
    else
        devices = read(attributes(h)["devices"])
    end
        
    if "devname" ∈ attr
        dname = read(attributes(h)["devname"])
    else
        dname = "unknown"
    end
    
    if "time" ∈ attr
        t = ms2time(read(attributes(h)["time"]))
    else
        t = now()
    end

    data = OrderedDict{String,MeasData}()

    for dev in devices
        data[dev] = readdaqdata(h[dev])
    end
    
    
    return MeasDataSet(dname, dtype, t, data)
end


"""
`readdaqdata(h)`

Reads data acquisition data from a HDF5 file located at `h`. It will recognize
whether the data is a `MeasData` or `MeasDataSet` and act accordingly.

"""
function readdaqdata(h)

    attr = collect(keys(attributes(h)))
    
    if "devtype" ∈ attr
        dtype = read(attributes(h)["devtype"])
    elseif "type" ∈ attr
        dtype = read(attributes(h)["type"])
    else
        error("HDF5 section NOT and MeasData! No 'devtype' attribute!")
    end

    if dtype == "DeviceSet"
        return readdaqdata_devset(h, dtype, attr)
    else
        return readdaqdata_dev(h, dtype, attr)
    end

end
