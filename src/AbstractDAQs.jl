module AbstractDAQs

export AbstractDAQ, AbstractPressureScanner
export DAQTask, isreading, samplesread, issamplesavailable
export isdaqfinished
export stoptask, stoptask!, cleartask!
export samplingrate, settiming!
export setdaqthread!, daqthread
export setdaqtask!, daqtask
export daqaddinput, daqacquire, daqacquire!, daqstart
export daqread, daqread!, daqstop, daqdevname

export daqreference, daqzero, daqconfig, daqconfigdev
export numchannels, daqchannels
export CircMatBuffer, bufwidth
export nextbuffer, isfull, isempty, flatten, flatten!, capacity
export DAQConfig, iparameters, fparameters, sparameters
export daqdevip, daqdevmodel, daqdevserialnum, daqdevtag
export savedaqdata, savedaqconfig
export TestDev


abstract type AbstractDAQ end
abstract type AbstractPressureScanner <: AbstractDAQ end

include("daqconfig.jl")
include("daqtask.jl")
include("circbuffer.jl")
include("hdf5io.jl")
include("interface.jl")
include("testdevice.jl")

end
