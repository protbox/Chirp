local chirp = {}

-- I should probably move these somewhere else so they can be modified easier
local noise_lfsr = 1 -- initial seed
local table_size = 2048 -- for square wave band limiting
local sample_rate = 44100

local function build_bandlimited_pulse_for_frequency(duty, freq, sample_rate, table_size)
    local nyquist = sample_rate / 2
    local k_max = math.floor(nyquist / freq)
    if k_max < 1 then
        k_max = 1
    end

    local wave = {}
    for i=1, table_size do
        wave[i] = 0
    end

    for i=1, table_size do
        local t = (i-1) / table_size
        local sum = 0

        for k=1, k_max do
            local ak = (2 / (k * math.pi)) * math.sin(k * math.pi * duty)
            sum = sum + ak * math.sin(2 * math.pi * k * t)
        end
        wave[i] = sum
    end

    local max_amp = 0
    for i=1, table_size do
        local a = math.abs(wave[i])
        if a > max_amp then
            max_amp = a
        end
    end
    if max_amp > 0 then
        for i=1, table_size do
            wave[i] = wave[i] / max_amp
        end
    end

    return wave
end

local function build_bandlimited_sawtooth_for_frequency(freq, sample_rate, table_size)
    local nyquist = sample_rate / 2
    local k_max = math.floor(nyquist / freq)
    if k_max < 1 then
        k_max = 1
    end

    local wave = {}
    for i = 1, table_size do
        wave[i] = 0
    end

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
        if a > max_amp then
            max_amp = a
        end
    end
    if max_amp > 0 then
        for i = 1, table_size do
            wave[i] = wave[i] / max_amp
        end
    end

    return wave
end

local function clamp_sample(v)
    if v > 1 then return 1
    elseif v < -1 then return -1
    end
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

-- converts notes like C5, D#4, etc to frequencies
local function note_to_frequency(note)
    local letter, accidental, octave = note:match("([A-G])([#b]?)(%d+)")
    if not letter or not octave then
        error("Invalid note format: " .. tostring(note))
    end
    octave = tonumber(octave)
    local key = letter .. accidental
    local semitone = note_map[key]
    if semitone == nil then
        error("Invalid note: " .. tostring(note))
    end

    local midi_note = (octave + 1) * 12 + semitone

    return 440 * 2^((midi_note - 69) / 12)
end

-- standard duty cycles similar to that of the NES would be like:
-- 0.50 for 50% (square)
-- 0.25 for 25%
-- 0.125 for 12.5%

function chirp.new_wave(t, key, duty_cycle, volume)
	assert(key ~= nil, "chirp.new_wave expects at least a wave type and a key")

	local wt = "wt_" .. t
	if not chirp[wt] then
		error("No such wave type:" .. wt)
	end

	if t == "square" and not duty_cycle then
		error("Square was requested, but no duty cycle was passed")
	end

	return chirp.generate_waveform(t, note_to_frequency(key), duty_cycle or false, volume or 0.8)
end

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

-- hey mike, can we pls has bit operators in luajit
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

function chirp.generate_waveform(wave_type, frequency, duty_cycle, duration, volume)
    local duration = duration or 1
    local sr = sample_rate
    local total_samples = math.floor(duration * sr)
    local sound_data = love.sound.newSoundData(total_samples, sr, 16, 1)

    local dt = frequency / sr
    local phase = 0

    local vol = volume or 0.8 -- 1 is a bit loud, imho

    local wave_table = nil
    if wave_type == "square" then
        wave_table = build_bandlimited_pulse_for_frequency(duty_cycle, frequency, sr, table_size)
    elseif wave_type == "sawtooth" then
        wave_table = build_bandlimited_sawtooth_for_frequency(frequency, sr, table_size)
    end

    for i = 0, total_samples - 1 do
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
        if phase >= 1 then
            phase = phase - 1
        end
    end

    return sound_data
end

return chirp