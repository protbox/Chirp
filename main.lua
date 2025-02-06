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
	[14] = love.audio.newSource(chirp.new_wave("triangle", "B3"), "static")
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
	j = 14
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