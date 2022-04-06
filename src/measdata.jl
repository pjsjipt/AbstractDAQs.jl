
export AbstractMeasData, MeasData
export meastime, samplingrate, measdata


abstract type AbstractMeasData end

"""
`MeasData`

Structure to store data acquired from a DAQ device. It also stores metadata related to 
the DAQ device, data acquisition process and daq channels.
"""
struct MeasData{T} <: AbstractMeasData
    "Device that generated the data"
    devname::String
    "Type of device"
    devtype::String
    "Time of data aquisition"
    time::DateTime
    "Sampling rate (Hz)"
    rate::Float64
    "Data acquired"
    data::T
    "Index of each channel"
    chans::Dict{String,Int}
end

#DateTime(Dates.UTInstant(Millisecond(d.t)))
"Convert a DateTime object to ms"
time2ms(t::DateTime) = t.instant.periods.value
"Convert a time in ms to DateTimeObject"
ms2time(t::Int64) = DateTime(Dates.UTInstant{Millisecond}(Millisecond(ms)))

"Device name that acquired the data"
devname(d::MeasData) = d.devname

"Device type that acquired the data"
devtype(d::MeasData) = d.devtype

"When did the data acquisition take place?"
meastime(d::AbstractMeasData) = d.time

"What was the sampling rate of the data acquisition?"
samplingrate(d::MeasData) = d.rate

"Access to the data acquired"
measdata(d::MeasData) = d.data


import Base.getindex

"Access the data in channel name `ch`"
getindex(d::MeasData{T},ch::String) where {T<:AbstractMatrix}=view(d.data,d.chans[ch],:)
"Access the data in channel index `i`"
getindex(d::MeasData{T}, i::Integer) where {T<:AbstractMatrix} = view(d.data, i, :)
"Access the data in channel index `i` at time index `k`"
getindex(d::MeasData{T}, i::Integer,k::Integer) where {T<:AbstractMatrix}= d.data[i,k]
"Access the data in channel name `ch` at time index `k`"
getindex(d::MeasData{T}, ch::String,k::Integer) where {T<:AbstractMatrix}= d.data[d.chans[ch],k]


                                                                           
