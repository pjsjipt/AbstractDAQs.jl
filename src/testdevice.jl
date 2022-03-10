

mutable struct TestDev <: AbstractDAQ
    devname::String
    nchans::Int
    channames::Vector{String}
    reading::Bool
    rate::Float64
    nsamples::Int
    freq::Float64
    noise::Float64
    t1::UInt64
    E::Matrix{Float64}
    tsk::Task
    time::DateTime
end


"""
`TestDev(devname, nchans; channames="E")`

Creates a test device, useful for testing stuff.
"""
function TestDev(devname, nchans; channames="E")

    nz = ceil(Int, log10(nchans + 1000*eps(Float64(nchans))))
    nz = max(nz,1)
    if isa(channames, AbstractString) || isa(channames, Symbol)
        chn = string(channames) .* numstring.(1:nchans, nz)
    elseif length(channames != nchans)
        throw(DomainError(nchans, "`channames` should have length 1 or equal to `nchans`"))
    else
        chn = string.(channames)
    end

    return TestDev(devname, nchans, chn, false, 1000.0,
                   1, 1.0, 0.01, 0, zeros(0,0), Task(_->1), now())
end

numchannels(dev::TestDev) = dev.nchans
daqchannels(dev::TestDev) = dev.channames


function daqaddinput(dev::TestDev, chans; names="E")
    nchans = length(chans)
    
    nz = ceil(Int, log10(nchans + 1000*eps(Float64(nchans))))
    nz = max(nz,1)
    if isa(names, AbstractString) || isa(names, Symbol)
        chn = string(names) .* numstring.(1:nchans, nz)
    elseif length(names != nchans)
        throw(DomainError(nchans, "`names` should have length 1 or equal to `nchans`"))
    else
        chn = string.(names)
    end

    dev.nchans = nchans
    dev.channames = chn

    return
end

function daqconfig(dev::TestDev; kw...)

    if haskey(kw, :rate) && haskey(kw, :dt)
        error("Parameters `rate` and `dt` can not be specified simultaneously!")
    elseif haskey(kw, :rate) || haskey(kw, :dt)
        if haskey(kw, :rate)
            rate = kw[:rate]
        else
            dt = kw[:dt]
            rate = 1.0 / dt
        end
    else
        error("Either `rate` or `dt` should be specified!")
    end
    
    
    if haskey(kw, :nsamples) && haskey(kw, :time)
        error("Parameters `nsamples` and `time` can not be specified simultaneously!")
    elseif haskey(kw, :nsamples) || haskey(kw, :time)
        if haskey(kw, :nsamples)
            nsamples = kw[:nsamples]
        else
            tt = kw[:time]
            nsamples = round(Int, tt * rate)
        end
    else
        error("Either `nsamples` or `time` should be specified")
    end

    dev.rate = rate
    dev.nsamples = nsamples

    # Allocate the buffer:
    dev.E = zeros(dev.nchans, nsamples)
    return
end


function filldata!(dev)
    nchans = dev.nchans
    nt = dev.nsamples

    dev.E .= randn(nchans, nt) .* dev.noise
    f = dev.freq
    fs = dev.rate
    for i in 1:nt
        x = sin(2π*f * (i-1)/fs)
        for k in 1:nchans
            dev.E[k,i] += x
        end
    end
    
end

function readtestsamples(dev::TestDev)

    dev.reading = true
    ttot = dev.nsamples / dev.rate
    dev.t1 = time_ns()
    sleep(ttot)
    filldata!(dev)
    dev.reading = false
    
end

function daqacquire(dev::TestDev)
    readtestsamples(dev)
    return dev.E, dev.rate
end


function daqstart(dev::TestDev, usethread=true)
    t =  @async readtestsamples(dev)
    dev.tsk = t
    return t
end

function daqread(dev::TestDev)

    #if !istaskdone(dev.tsk) && istaskstarted(dev.tsk)
    #    wait(dev.tsk)
    #end
    wait(dev.tsk)
    #println("waiting")

    return dev.E, dev.rate
end


isreading(dev::TestDev) = dev.reading
samplesread(dev::TestDev) =
    min(dev.nsamples, round(Int, (time_ns()-dev.t1)*1e-9 * dev.rate))
isdaqfinished(dev::TestDev) = !dev.reading


    
