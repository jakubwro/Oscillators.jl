module Oscillators

using Unitful
import Unitful: Frequency, Hz, kHz, 𝐓, s

samplerate = 48000Hz

abstract type AbstractOscillator end

function maxstable(samplerate::Frequency)
    return samplerate / 2 #TODO: this is not the correct formula
end

function checkstability(frequency::Frequency, samplerate::Frequency)
    if frequency >= maxstable(samplerate)
        error("Oscillator is unstable: $(frequency) is to high for $(samplerate) sample rate. The maximum stable frequency is $(maxstable(samplerate))")
    end
end

mutable struct SineOscillator{T<:AbstractFloat} <: AbstractOscillator
    previous::T
    sample::T
    cosine::T
end

function SineOscillator(frequency::Frequency{T}, amplitude::Complex{T}) where {T<:AbstractFloat}
    checkstability(frequency, samplerate)

    magnitude = abs(amplitude)
    phase = angle(amplitude)

    step = 2 * pi * frequency / samplerate
    previous = magnitude * sin(phase)
    sample = magnitude * sin(phase + step)
    cosine = cos(step)

    return SineOscillator{typeof(step)}(previous, sample, cosine)
end

function SineOscillator(frequency::Frequency{T}, amplitude::T) where {T<:AbstractFloat}
    return SineOscillator(frequency, complex(amplitude))
end

function oscillate!(osc::SineOscillator{T}) where {T<:AbstractFloat}
    nextsample = 2 * osc.sample * osc.cosine - osc.previous
    osc.previous, osc.sample = osc.sample, nextsample
    return nextsample
end

struct VectorOscillator{T<:AbstractFloat}
    oscs::Vector{SineOscillator{T}}
end

function oscillate!(osc::VectorOscillator{T}) where {T<:AbstractFloat}
    sum(oscillate!.(osc.oscs))
end

end