Config = {
    command           = 'driftcounter', -- chat command to toggle the HUD
    toggleKey         = '',    -- bind this key
    minAngle          = 12.0,   -- degrees of slip before it counts as a drift
    minSpeed          = 15.0,   -- mph minimum speed to count
    scorePerTick      = 8,      -- base score per tick while drifting
    comboDecayTime    = 1500,   -- ms of no-drift before combo resets
    comboGainPerTick  = 0.015,
    comboMax          = 10.0,
    tickMs            = 100    -- update frequency
}
