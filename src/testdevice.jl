

mutable struct TestDev <: AbstractDaqDevice
    "Handling of background data acquisition"
    task::DAQTask
    nchans::Int
    
    
end

    
