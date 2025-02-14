local chirp = {}

local noise_lfsr = 1        -- initial seed for noise
local table_size = 2048     -- for band-limited tables
local sample_rate = 44100

local function clamp_sample(v)
    if v > 1 then return 1
    elseif v < -1 then return -1 end
    return v
end

local note_map = {
    C  = 0, ["C#"] = 1, ["Db"] = 1,
    D  = 2, ["D#"] = 3, ["Eb"] = 3,
    E  = 4,
    F  = 5, ["F#"] = 6, ["Gb"] = 6,
    G  = 7, ["G#"] = 8, ["Ab"] = 8,
    A  = 9, ["A#"] = 10, ["Bb"] = 10,
    B  = 11
}

local function note_to_frequency(note)
    local letter, accidental, octave = note:match("([A-G])([#b]?)(%d+)")
    if not letter or not octave then error("Invalid note format: " .. tostring(note)) end
    octave = tonumber(octave)
    local key = letter .. accidental
    local semitone = note_map[key]
    if semitone == nil then error("Invalid note: " .. tostring(note)) end
    local midi_note = (octave + 1) * 12 + semitone
    return 440 * 2^((midi_note - 69) / 12)
end

local function build_bandlimited_pulse_for_frequency(duty, freq, sample_rate, table_size)
    local nyquist = sample_rate / 2
    local k_max = math.floor(nyquist / freq)
    if k_max < 1 then k_max = 1 end

    local wave = {}
    for i = 1, table_size do wave[i] = 0 end

    for i = 1, table_size do
        local t = (i-1) / table_size
        local sum = 0
        for k = 1, k_max do
            local ak = (2 / (k * math.pi)) * math.sin(k * math.pi * duty)
            sum = sum + ak * math.sin(2 * math.pi * k * t)
        end
        wave[i] = sum
    end

    local max_amp = 0
    for i = 1, table_size do
        local a = math.abs(wave[i])
        if a > max_amp then max_amp = a end
    end
    if max_amp > 0 then
        for i = 1, table_size do wave[i] = wave[i] / max_amp end
    end
    return wave
end

local function build_bandlimited_sawtooth_for_frequency(freq, sample_rate, table_size)
    local nyquist = sample_rate / 2
    local k_max = math.floor(nyquist / freq)
    if k_max < 1 then k_max = 1 end

    local wave = {}
    for i = 1, table_size do wave[i] = 0 end

    for i = 1, table_size do
        local t = (i - 1) / table_size
        local sum = 0
        for k = 1, k_max do
            local ak = (2 / (k * math.pi)) * ((-1)^(k+1))
            sum = sum + ak * math.sin(2 * math.pi * k * t)
        end
        wave[i] = sum
    end

    local max_amp = 0
    for i = 1, table_size do
        local a = math.abs(wave[i])
        if a > max_amp then max_amp = a end
    end
    if max_amp > 0 then
        for i = 1, table_size do wave[i] = wave[i] / max_amp end
    end
    return wave
end

-- wave generators
function chirp.wt_triangle(phase)
    local steps = 16
    local half_phase = 0.5
    local step_size = 2 / steps
    if phase < half_phase then
        local prog = phase / half_phase
        return -1 + math.floor(prog * steps) * step_size
    else
        local prog = (phase - half_phase) / half_phase
        return 1 - math.floor(prog * steps) * step_size
    end
end

function chirp.wt_noise()
    local bit0 = bit.band(noise_lfsr, 1)
    local bit1 = bit.band(bit.rshift(noise_lfsr, 1), 1)
    local feedback = bit.band(bit.bxor(bit0, bit1), 1)
    noise_lfsr = bit.rshift(noise_lfsr, 1)
    noise_lfsr = bit.bor(noise_lfsr, bit.lshift(feedback, 14))
    return (bit0 == 1) and 1 or -1
end

function chirp.wt_square(phase, wave_table, table_size)
    local idx = math.floor(phase * table_size) + 1
    return wave_table[idx]
end

function chirp.wt_sawtooth(phase, wave_table, table_size)
    local idx = math.floor(phase * table_size) + 1
    return wave_table[idx]
end

-- helper functions
local function get_envelope_info(envelope)
    local num_steps = #envelope
    local default_step_duration = 0.1  -- each envelope step lasts 0.1 seconds
    local total_duration = num_steps * default_step_duration
    return total_duration, default_step_duration, num_steps
end

local function interp_envelope(t, envelope, step_duration)
    local num_steps = #envelope
    local index = math.floor(t / step_duration)
    if index >= num_steps - 1 then
        return envelope[num_steps] / 10
    end
    local alpha = (t - index * step_duration) / step_duration
    local current_val = envelope[index + 1]
    local next_val = envelope[index + 2]
    return ((1 - alpha) * current_val + alpha * next_val) / 10
end

--------------------------------------------------------------------------------
-- NES (supports "square", "sawtooth", "triangle", "noise")
--------------------------------------------------------------------------------
function chirp.new_nes()
    local nes = { sample_rate = sample_rate }
    
    function nes:new_wave(wave_type, key, duty_cycle, envelope)
        assert(key, "NES:new_wave requires a note key")
        local freq = note_to_frequency(key)
        local total_duration, step_duration, num_steps = get_envelope_info(envelope)
        local sr = self.sample_rate
        local total_samples = math.floor(total_duration * sr)
        local sound_data = love.sound.newSoundData(total_samples, sr, 16, 1)
        local dt = freq / sr
        local phase = 0
        
        local wave_table = nil
        if wave_type == "square" then
            if not duty_cycle then error("NES:new_wave: duty_cycle required for square wave") end
            wave_table = build_bandlimited_pulse_for_frequency(duty_cycle, freq, sr, table_size)
        elseif wave_type == "sawtooth" then
            wave_table = build_bandlimited_sawtooth_for_frequency(freq, sr, table_size)
        end

        for i = 0, total_samples - 1 do
            local t = i / sr
            local vol = interp_envelope(t, envelope, step_duration)
            local sample_val = 0

            if wave_type == "square" then
                sample_val = chirp.wt_square(phase, wave_table, table_size)
            elseif wave_type == "sawtooth" then
                sample_val = chirp.wt_sawtooth(phase, wave_table, table_size)
            elseif wave_type == "triangle" then
                sample_val = chirp.wt_triangle(phase)
            elseif wave_type == "noise" then
                sample_val = chirp.wt_noise()
            else
                sample_val = 0
            end

            sample_val = clamp_sample(sample_val * vol)
            sound_data:setSample(i, sample_val)
            phase = phase + dt
            if phase >= 1 then phase = phase - 1 end
        end

        return sound_data
    end
    
    return nes
end

--------------------------------------------------------------------------------
-- GAMEBOY
--------------------------------------------------------------------------------
function chirp.new_gb()
    local gb = { sample_rate = sample_rate }
    
    function gb:new_wave(key, envelope, params)
        assert(key, "GB:new_wave requires a note key")
        local freq = note_to_frequency(key)
        local total_duration, step_duration, num_steps = get_envelope_info(envelope)
        local sr = self.sample_rate
        local total_samples = math.floor(total_duration * sr)
        local sound_data = love.sound.newSoundData(total_samples, sr, 16, 1)
        local dt = freq / sr
        local phase = 0
        
        assert(params and params.waveform and #params.waveform >= 32, "GB:new_wave requires a waveform table with at least 32 samples")
        local waveform = params.waveform
        local volume_shift = params.volume_shift or 0
        
        for i = 0, total_samples - 1 do
            -- old stepped based volume change
            --[[local t = i / sr
            local step_index = math.min(num_steps, math.floor(t / step_duration) + 1)
            local vol = envelope[step_index] / 10]]
            local t = i / sr
            local vol = interp_envelope(t, envelope, step_duration)
            local sample_index = math.floor(phase * 32) % 32
            local sample = waveform[sample_index + 1] or 0
            sample = math.floor(sample / (2 ^ volume_shift))
            sample = (sample - 8) / 8
            sample = clamp_sample(sample * vol)
            sound_data:setSample(i, sample)
            phase = phase + dt
            if phase >= 1 then phase = phase - 1 end
        end
        return sound_data
    end
    
    return gb
end

--------------------------------------------------------------------------------
-- NOISE
--------------------------------------------------------------------------------
function chirp.new_noise()
    local noise_inst = { sample_rate = sample_rate }
    
    function noise_inst:new_wave(key, envelope)
        assert(key, "Noise:new_wave requires a note key")
        local freq = note_to_frequency(key)
        local total_duration, step_duration, num_steps = get_envelope_info(envelope)
        local sr = self.sample_rate
        local total_samples = math.floor(total_duration * sr)
        local sound_data = love.sound.newSoundData(total_samples, sr, 16, 1)
        local dt = freq / sr
        local noise_phase = 0
        local noise_sample = chirp.wt_noise()
        
        for i = 0, total_samples - 1 do
            local t = i / sr
            local step_index = math.min(num_steps, math.floor(t / step_duration) + 1)
            local vol = envelope[step_index] / 10
            if noise_phase >= 1 then
                noise_sample = chirp.wt_noise()
                noise_phase = noise_phase - 1
            end
            local sample_val = clamp_sample(noise_sample * vol)
            sound_data:setSample(i, sample_val)
            noise_phase = noise_phase + dt
        end
        return sound_data
    end
    
    return noise_inst
end

return chirp
