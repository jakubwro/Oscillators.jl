module Oscillators

abstract type AbstractOscillator end

samplerate = 48000

struct SineOscillator <: AbstractOscillator
    previous::Float64
    sample::Float64
    cosine::Float64

    function SineOscillator(frequency)
        if frequency > samplerate / 2
            error("unstable oscillation")
        end

        sample = 2 * pi * frequency / samplerate #sin
        cosine = 1 - sample^2 / 2 #cos

        return new(0, sample, cosine)
    end
end

function oscilate(osc::SineOscillator)
    nextsample = 2 * osc.sample * osc.cosine - osc.previous
    return SineOscillator(osc.sample, nextsample, osc.cosine)
end

function sample(osc::SineOscillator)
    return osc.sample
end

# struct CompositeOscillator
#     oscillators::Vector{AbstractOscillator}
# end

# function oscilate(osc::CompositeOscillator)
#     return CompositeOscillator(oscilate.(osc.oscillators))
# end

# function sample(osc::CompositeOscillator)
#     return sum(sample.(osc.oscillators)) / length(osc.oscillators)
# end

# struct QuadratureOscilator <: AbstractOscilator
#     step::ComplexF64
#     amplitude::Complex{Float64}

#     function QuadratureOscilator(frequency, amplitude)
#         dx = 2 * pi * frequency / 48000.0
#         step = (1 - dx^2) + dx * im
#         return new(step, amplitude)
#     end
# end

# function oscilate(osc::QuadratureOscilator)
#     return QuadratureOscilator(osc.step, osc.amplitude * osc.step)
# end

# function sample(osc::QuadratureOscilator)
#     return imag(osc.amplitude)
# end

end