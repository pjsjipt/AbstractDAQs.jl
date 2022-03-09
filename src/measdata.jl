
export AbstractMeasData, MeasData
export meastime, samplingrate, measdata, measinfo


abstract type AbstractMeasData end

struct MeasData{T,Info} <: AbstractMeasData
    "Device that generated the data"
    devname::String
    "Type of device"
    devtype::String
    "Time of data aquisition"
    time::DateTime
    "Sampling rate (Hz)"
    fs::Float64
    "Data acquired"
    data::T
    "Other information"
    info::Info
    "Index of each channel"
    chans::Dict{String,Int}
end

#DateTime(Dates.UTInstant(Millisecond(d.t)))

time2ms(t::DateTime) = t.instant.periods.value
ms2time(t::Int64) = DateTime(Dates.UTInstant{Millisecond}(Millisecond(ms)))

devname(d::MeasData) = d.devname

devtype(d::MeasData) = d.devtype

meastime(d::AbstractMeasData) = d.time

samplingrate(d::MeasData) = d.fs

measdata(d::MeasData) = d.data

measinfo(d::MeasData) = d.info

import Base.getindex
getindex(d::MeasData{T,I},ch::String) where {T<:AbstractMatrix,I} = d.data[d.chans[ch],:]
getindex(d::MeasData{T,I}, i::Integer) where {T<:AbstractMatrix,I} = d.data[i,:]
getindex(d::MeasData{T,I}, i::Integer,k::Integer) where {T<:AbstractMatrix,I}= d.data[i,k]


                                                                           
