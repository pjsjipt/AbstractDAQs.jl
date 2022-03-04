using Dates
export AbstractMeasData, MeasData, MeasSet
export todatetime, samplingrate

abstract type AbstractMeasData end

struct MeasData{T} <: AbstractMeasData
    "Device that generated the data"
    devname::String
    "Time of data aquisition (ms from epoch)"
    t::Int64
    "Sampling rate (Hz)"
    fs::Float64
    "Data acquired"
    data::T
end

todatetime(d::AbstractMeasData) = DateTime(Dates.UTInstant(Millisecond(d.t)))

samplingrate(d::MeasData) = d.fs

measdata(d::MeasData) = d.data

devname(d::MeasData) = d.devname


