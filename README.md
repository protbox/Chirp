chirp is a library for LÖVE that simplifies the process of generating band-limited waves (square and sawtooth). It can also generate a 16-step triangle.

It only has one function right now, which is `new_wave`. To use it, you'd do something like:

```lua
local chirp = require "chirp"

local c5_square = chirp.new_wave("square", "C5", 0.125) -- generates a NES-like 12.5% pulse sound data
local as4_sawtooth = chirp.new_wave("sawtooth", "A#4") -- no other wave types require a duty cycle
local g2_triangle = chirp.new_wave("triangle", "G2")

-- to make them player, simply pass the sound data into love.audio.newSource
local c5_square_src = love.audio.newSource(c5_square)
c5_square_src:play()
```

If you're looking to emulate the NES sound, your typical duty cycles will be:
- 0.125 for 12.5%
- 0.25 for 25%
- 0.50 for 50%