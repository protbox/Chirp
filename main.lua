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

-- gameboy example
local notes = {
	[1] = love.audio.newSource(chirp.new_wave("gameboy", "C4", 0.125, 1, 1, first_tbl), "static"),
	[2] = love.audio.newSource(chirp.new_wave("gameboy", "D4", 0.125, 1, 1, first_tbl), "static"),
	[3] = love.audio.newSource(chirp.new_wave("gameboy", "E4", 0.125, 1, 1, first_tbl), "static"),
	[4] = love.audio.newSource(chirp.new_wave("gameboy", "F#4", 0.125, 1, 1, first_tbl), "static"),
	[5] = love.audio.newSource(chirp.new_wave("gameboy", "G4", 0.125, 1, 1, first_tbl), "static"),
	[6] = love.audio.newSource(chirp.new_wave("gameboy", "A4", 0.125, 1, 1, first_tbl), "static"),
	[7] = love.audio.newSource(chirp.new_wave("gameboy", "B4", 0.125, 1, 1, first_tbl), "static"),

	[8] = love.audio.newSource(chirp.new_wave("gameboy", "C2", nil, 1, 1, bass_tbl), "static"),
	[9] = love.audio.newSource(chirp.new_wave("gameboy", "D2", nil, 1, 1, bass_tbl), "static"),
	[10] = love.audio.newSource(chirp.new_wave("gameboy", "E2", nil, 1, 1, bass_tbl), "static"),
	[11] = love.audio.newSource(chirp.new_wave("gameboy", "F#2", nil, 1, 1, bass_tbl), "static"),
	[12] = love.audio.newSource(chirp.new_wave("gameboy", "G2", nil, 1, 1, bass_tbl), "static"),
	[13] = love.audio.newSource(chirp.new_wave("gameboy", "A2", nil, 1, 1, bass_tbl), "static"),
	[14] = love.audio.newSource(chirp.new_wave("gameboy", "B2", nil, 1, 1, bass_tbl), "static"),

	-- noise is pretty loud, so I'm lowering it to 0.2
	[15] = love.audio.newSource(chirp.new_wave("noise", "C7", nil, 1, 0.2), "static"),
	[16] = love.audio.newSource(chirp.new_wave("noise", "D7", nil, 1, 0.2), "static"),
	[17] = love.audio.newSource(chirp.new_wave("noise", "E7", nil, 1, 0.2), "static"),
	[18] = love.audio.newSource(chirp.new_wave("noise", "F#7", nil, 1, 0.2), "static"),
	[19] = love.audio.newSource(chirp.new_wave("noise", "G7", nil, 1, 0.2), "static"),
	[20] = love.audio.newSource(chirp.new_wave("noise", "A7", nil, 1, 0.2), "static"),
	[21] = love.audio.newSource(chirp.new_wave("noise", "B7", nil, 1, 0.2), "static"),
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