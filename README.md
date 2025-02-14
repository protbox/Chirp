chirp is a library for LÖVE that simplifies the process of generating waves (or chiptune sounds). There are 2 core instances to choose from which emulate the NES (band-limited) and Gameboy (wave tables) sound chips. There's also a noise channel.
To set them up, simply do:

```lua
local chirp = require "chirp"

local nes = chirp.new_nes() -- creates a NES instance
local gb = chirp.new_gb() -- creates a Gameboy instance 
local noise = chirp.new_noise() -- creates a noise instance
```

Once this is done, you call `:new_wave` on the instance. Each type has their own parameters. The envelope is a sequence of numbers representing the volume steps, and also controls the duration. It can be used as a kind of ADSR envelope.

```lua
local envelope = { 2, 5, 10, 10, 10, 8, 5, 4, 3, 2, 1, 1, 1 } -- short ramp up, hold at max, then slowly release
-- nes requires a wave_type (square, sawtooth, triangle)
-- duty cycle examples would be 0.125 for 12.5%, 0.25 for 25% and 0.50 for 50%
local c4 = nes:new_wave(wave_type, note, duty_cycle, envelope)

-- gameboy requires a params table which holds the wavetable and volume shift data
local params = {
	wavetable = {
		15, 15, 15, 15, 15, 15, 15, 15,   -- sustained high at start
  		13, 12, 11, 10,  9,  8,  7,  6,   -- gradual dip
   		6,  7,  8,  9, 10, 11, 12, 13,   -- ramp back up
  		15, 15, 15, 15, 15, 15, 15, 15    -- sustained high at end
  	},
	volume_shift = 0 -- 0-3
}

local c4 = gb:new_wave(note, envelope, params)

-- noise just requires the note and envelope
-- with just a single value in the evelope table it will be a quick burst
-- I like to use lower numbers here as noise is quite loud by default
local bang = noise:new_wave(note, { 2 })
```

Chirp supplies the sound data, but you'll need to create a source to make it playable

```lua
local c4 = love.audio.newSource(gb:new_wave(note, envelope, params), "static")
c4:play()
```

It's really that simple.

Here are some basic square wave tables for the gameboy to get you started

```lua
-- 12.5%
local wave_12_5 = {
  15, 15, 15, 15,
   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
   0,  0,  0,  0
}

-- 25%
local wave_25 = {
  15, 15, 15, 15, 15, 15, 15, 15,
   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
}

-- 50%
local wave_50 = {
  15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
}

-- triangle
local triangle = {
    0,  1,  2,  3,  4,  5,  6,  7,
    8,  9, 10, 11, 12, 13, 14, 15,
    15, 14, 13, 12, 11, 10,  9,  8,
    7,  6,  5,  4,  3,  2,  1,  0
}
```