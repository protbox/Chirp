local chirp = require "chirp"

-- simulates a 25% duty cycle
local wave_25 = {
  15, 15, 15, 15, 15, 15, 15, 15,
   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
}

-- simulates a 12.5% duty cycle
local wave_12_5 = {
  15, 15, 15, 15,
   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
   0,  0,  0,  0
}

-- iconic bass sound
local fat_bass = {
  15, 15, 15, 15, 15, 15, 15, 15,   -- sustained high at start
  13, 12, 11, 10,  9,  8,  7,  6,   -- gradual dip
   6,  7,  8,  9, 10, 11, 12, 13,   -- ramp back up
  15, 15, 15, 15, 15, 15, 15, 15    -- sustained high at end
}

-- simulates a square wave
local wave_50 = {
  15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
}

local first_tbl = { waveform = wave_50, volume_shift = 1 }
local bass_tbl = { waveform = fat_bass, volume_shift = 0 }

local nes = chirp.new_nes()
local gb = chirp.new_gb()
local noise = chirp.new_noise()

local seq = {1, 4, 8, 10, 10, 10, 10, 10, 10, 10, 10, 6, 4, 1, 1, 1, 1, 1}
local bass_seq = {10, 8, 0}
-- noise is really loud by default
local noise_seq = {2, 0}

local notes = {
	[1] = love.audio.newSource(nes:new_wave("square", "C4", 0.50, seq), "static"),
	[2] = love.audio.newSource(nes:new_wave("square", "D4", 0.50, seq), "static"),
	[3] = love.audio.newSource(nes:new_wave("square", "E4", 0.50, seq), "static"),
	[4] = love.audio.newSource(nes:new_wave("square", "F#4", 0.50, seq), "static"),
	[5] = love.audio.newSource(nes:new_wave("square", "G4", 0.50, seq), "static"),
	[6] = love.audio.newSource(nes:new_wave("square", "A4", 0.50, seq), "static"),
	[7] = love.audio.newSource(nes:new_wave("square", "B4", 0.50, seq), "static"),

	[8] = love.audio.newSource(gb:new_wave("C2", bass_seq, bass_tbl), "static"),
	[9] = love.audio.newSource(gb:new_wave("D2", bass_seq, bass_tbl), "static"),
	[10] = love.audio.newSource(gb:new_wave("E2", bass_seq, bass_tbl), "static"),
	[11] = love.audio.newSource(gb:new_wave("F#2", bass_seq, bass_tbl), "static"),
	[12] = love.audio.newSource(gb:new_wave("G2", bass_seq, bass_tbl), "static"),
	[13] = love.audio.newSource(gb:new_wave("A2", bass_seq, bass_tbl), "static"),
	[14] = love.audio.newSource(gb:new_wave("B2", bass_seq, bass_tbl), "static"),

	[15] = love.audio.newSource(noise:new_wave("C7", noise_seq), "static"),
	[16] = love.audio.newSource(noise:new_wave("D7", noise_seq), "static"),
	[17] = love.audio.newSource(noise:new_wave("E7", noise_seq), "static"),
	[18] = love.audio.newSource(noise:new_wave("F#7", noise_seq), "static"),
	[19] = love.audio.newSource(noise:new_wave("G7", noise_seq), "static"),
	[20] = love.audio.newSource(noise:new_wave("A7", noise_seq), "static"),
	[21] = love.audio.newSource(noise:new_wave("B7", noise_seq), "static"),
}

local keys = {
	-- 25%
	z = 1,
	x = 2,
	c = 3,
	v = 4,
	b = 5,
	n = 6,
	m = 7,

	-- triangle
	a = 8,
	s = 9,
	d = 10,
	f = 11,
	g = 12,
	h = 13,
	j = 14,

	-- noise
	q = 15,
	w = 16,
	e = 17,
	r = 18,
	t = 19,
	y = 20,
	u = 21
}

function love.keypressed(key, sc)
	if keys[sc] then
		notes[keys[sc]]:play()
	end
end

function love.keyreleased(key, sc)
	if keys[sc] then
		notes[keys[sc]]:stop()
	end
end