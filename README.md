chirp is a library for LÖVE that simplifies the process of generating band-limited waves (square and sawtooth). It can also generate a 16-step triangle and noise.

It only has one function right now, which is `new_wave`. To use it, you'd do something like:

```lua
local chirp = require "chirp"

local c5_square = chirp.new_wave("square", "C5", 0.125) -- generates a NES-like 12.5% pulse sound data
local as4_sawtooth = chirp.new_wave("sawtooth", "A#4") -- no other wave types require a duty cycle
local g2_triangle = chirp.new_wave("triangle", "G2")
local d7_noise = chirp.new_wave("noise", "D2", false, 0.2) -- false for duty cycle, 0.2 for volume, because noise is very loud by default

-- to make them play, simply pass the sound data into love.audio.newSource
local c5_square_src = love.audio.newSource(c5_square)
c5_square_src:play()
```

If you're looking to emulate the NES sound, your typical duty cycles will be:
- 0.125 for 12.5%
- 0.25 for 25%
- 0.50 for 50%

Chirp is also capable of "gameboy" wave generation. With this type, you need to supply an addition parameter table containing the wave table data (32 numbers from 0-15) and a volume shift (0-3). It looks like this.

```lua
-- wave table to simulate the iconic "fat bass" sound where it dips in the middle then ramps back up
local fat_bass = {
  15, 15, 15, 15, 15, 15, 15, 15,
  13, 12, 11, 10,  9,  8,  7,  6,
   6,  7,  8,  9, 10, 11, 12, 13,
  15, 15, 15, 15, 15, 15, 15, 15
}

local mybass_c4 = chirp.new_wave("gameboy", "C4", nil, 1, 1, { wavetable = fat_bass, volume_shift = 0 })
```

And that's it! For reference, here are some basic square wave tables to get you started

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
```