local chirp = require "chirp"

local notes = {
	[1] = love.audio.newSource(chirp.new_wave("square", "C5", 0.25), "static"),
	[2] = love.audio.newSource(chirp.new_wave("square", "D5", 0.25), "static"),
	[3] = love.audio.newSource(chirp.new_wave("square", "E5", 0.25), "static"),
	[4] = love.audio.newSource(chirp.new_wave("square", "F#5", 0.25), "static"),
	[5] = love.audio.newSource(chirp.new_wave("square", "G5", 0.25), "static"),
	[6] = love.audio.newSource(chirp.new_wave("square", "A5", 0.25), "static"),
	[7] = love.audio.newSource(chirp.new_wave("square", "B5", 0.25), "static"),

	[8] = love.audio.newSource(chirp.new_wave("triangle", "C3"), "static"),
	[9] = love.audio.newSource(chirp.new_wave("triangle", "D3"), "static"),
	[10] = love.audio.newSource(chirp.new_wave("triangle", "E3"), "static"),
	[11] = love.audio.newSource(chirp.new_wave("triangle", "F#3"), "static"),
	[12] = love.audio.newSource(chirp.new_wave("triangle", "G3"), "static"),
	[13] = love.audio.newSource(chirp.new_wave("triangle", "A3"), "static"),
	[14] = love.audio.newSource(chirp.new_wave("triangle", "B3"), "static"),

	-- noise is pretty loud, so I'm lowering it to 0.2
	[15] = love.audio.newSource(chirp.new_wave("noise", "C7", false, 0.2), "static"),
	[16] = love.audio.newSource(chirp.new_wave("noise", "D7", false, 0.2), "static"),
	[17] = love.audio.newSource(chirp.new_wave("noise", "E7", false, 0.2), "static"),
	[18] = love.audio.newSource(chirp.new_wave("noise", "F#7", false, 0.2), "static"),
	[19] = love.audio.newSource(chirp.new_wave("noise", "G7", false, 0.2), "static"),
	[20] = love.audio.newSource(chirp.new_wave("noise", "A7", false, 0.2), "static"),
	[21] = love.audio.newSource(chirp.new_wave("noise", "B7", false, 0.2), "static"),
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