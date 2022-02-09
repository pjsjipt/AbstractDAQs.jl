
mutable struct DAQConfig
    "Name for referening the device"
    devname::String
    "IP address where the device is located"
    ip::String
    "Model of device"
    model::String
    "Serial number of the device"
    sn::String
    "Storage tag of the device"
    tag::String
    "Integer configuration parameters"
    ipars::Dict{String,Int}
    "Float64  configuration parameters"
    fpars::Dict{String,Float64}
    "String configuration parameters"
    spars::Dict{String,String}
end

"""
`DAQConfig(;devname="", ip="", model="", sn="",tag="")`

Create data structure to store device configuration. 

Hopefuly, with the information stored in this struct, reproducible 
data configuration of the devices can be achieved.
"""
function DAQConfig(;devname="", ip="", model="", sn="",tag="")
    
    fpars = Dict{String,Float64}()
    ipars = Dict{String,Int}()
    spars = Dict{String,String}()
    return DAQConfig(devname, ip, model, sn, tag, ipars, fpars, spars)
end

function DAQConfig(ipars, fpars, spars;devname="", ip="", model="", sn="",tag="")
    
    return DAQConfig(devname, ip, model, sn, tag, ipars, fpars, spars)
end

"Retrieve integer configuration parameter"
iparameters(dconf::DAQConfig, param) = dconf.ipars[param]
"Retrieve string configuration parameter"
sparameters(dconf::DAQConfig, param) = dconf.spars[param]
"Retrieve float configuration parameter"
fparameters(dconf::DAQConfig, param) = dconf.fpars[param]

iparameters(dconf::DAQConfig) = dconf.ipars
sparameters(dconf::DAQConfig) = dconf.spars
fparameters(dconf::DAQConfig) = dconf.fpars

"Retrieve device name"
devname(dconf::DAQConfig) = dconf.devname
"Retrieve device IP address"
daqdevip(dconf::DAQConfig) = dconf.ip
"Retrieve device model"
daqdevmodel(dconf::DAQConfig) = dconf.model
"Retrieve device serial number"
daqdevserialnum(dconf::DAQConfig) = dconf.sn
"Retrieve device tag"
daqdevtag(dconf::DAQConfig) = dconf.tag


iparameters(dev::AbstractDAQ, param) = dev.conf.ipars[param]
sparameters(dev::AbstractDAQ, param) = dev.conf.spars[param]
fparameters(dev::AbstractDAQ, param) = dev.conf.fpars[param]

iparameters(dev::AbstractDAQ) = dev.conf.ipars
sparameters(dev::AbstractDAQ) = dev.conf.spars
fparameters(dev::AbstractDAQ) = dev.conf.fpars

devname(dev::AbstractDAQ) = dev.conf.devname
daqdevip(dev::AbstractDAQ) = dev.conf.ip
daqdevmodel(dev::AbstractDAQ) = dev.conf.model
daqdevserialnum(dev::AbstractDAQ) = dev.conf.sn
daqdevtag(dev::AbstractDAQ) = dev.conf.tag

