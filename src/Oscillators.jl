module Oscillators

abstract type AbstractOscillator end

struct SineOscillator{T<:AbstractFloat} <: AbstractOscillator
    previous::T
    sample::T
    cosine::T
end

samplerate = 48000

function SineOscillator(frequency)
   
    if frequency >= samplerate / 2 #TODO:  this is not the correct formula
        error("unstable oscillation. $(frequency) Hz is to high for $(samplerate) Hz sample rate")
    end

    step = 2 * pi * frequency / samplerate
    sample = sin(step) # step - step^3/factorial(3) + step^5/factorial(5)
    cosine = cos(step) #1 - step^2/(factorial(2)) + step^4/factorial(4)

    return SineOscillator{typeof(step)}(0, sample, cosine)
end

function oscillate(osc::SineOscillator)
    nextsample = 2 * osc.sample * osc.cosine - osc.previous
    return SineOscillator(osc.sample, nextsample, osc.cosine)
end

function sample(osc::SineOscillator)
    return osc.sample
end

struct FastSpectralOscillator <: AbstractOscillator
    P::Vector{Float64}
    S::Vector{Float64}
    C::Vector{Float64}
end

function FastSpectralOscillator(spectrum::Vector{Float64})

    steps = 2 .* pi .* spectrum ./ samplerate
    S = sin.(steps) # step - step^3/factorial(3) + step^5/factorial(5)
    C = cos.(steps) #1 - step^2/(factorial(2)) + step^4/factorial(4)

    return SpectralOscillator(zeros(length(spectrum)), S, C)
end

function oscillate(osc::FastSpectralOscillator)
    nextsample = 2 .* osc.S .* osc.C .- osc.P
    return FastSpectralOscillator(osc.S, nextsample, osc.C)
end

function sample(osc::FastSpectralOscillator)
    return sum(osc.S)
end

struct SpectralOscillator{T} <: AbstractOscillator where {T<:AbstractFloat}
    sines::Vector{SineOscillator{T}}
end

function SpectralOscillator(spectrum::Vector)
    return SpectralOscillator(SineOscillator.(spectrum))
end

function oscillate(osc::SpectralOscillator)
    return oscillate.(osc.sines)
end

function sample(osc::SpectralOscillator)
    return sum(sample.(osc))
end

end