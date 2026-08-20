local active        = false
local hudVisible     = false
local drifting      = false
local score         = 0
local combo         = 1.0
local bestChain      = 0
local currentChain   = 0
local lastDriftTime  = 0
local pauseHidden    = false

local function getVehicleAngleAndSpeed(veh)
    local vel = GetEntityVelocity(veh)
    local speed = GetEntitySpeed(veh) * 2.236936 -- m/s -> mph

    if speed < 1.0 then
        return 0.0, speed
    end

    local heading = GetEntityHeading(veh)
    local headingRad = math.rad(heading)
    local forward = vector2(-math.sin(headingRad), math.cos(headingRad))
    local velDir = vector2(vel.x, vel.y)
    local velLen = #velDir

    if velLen < 0.1 then
        return 0.0, speed
    end

    velDir = velDir / velLen

    local dot = forward.x * velDir.x + forward.y * velDir.y
    dot = math.max(-1.0, math.min(1.0, dot))
    local angle = math.deg(math.acos(dot))

    return angle, speed
end

local function resetSession()
    score = 0
    combo = 1.0
    currentChain = 0
    lastDriftTime = 0
end

CreateThread(function()
    while true do
        local wait = Config.tickMs

        if active then
            local ped = PlayerPedId()

            if IsPedInAnyVehicle(ped, false) then
                local veh = GetVehiclePedIsIn(ped, false)

                if GetPedInVehicleSeat(veh, -1) == ped then
                    if not hudVisible then
                        hudVisible = true
                        SendNUIMessage({ type = 'show' })
                    end

                    local angle, speed = getVehicleAngleAndSpeed(veh)
                    local now = GetGameTimer()

                    local isDrifting = angle >= Config.minAngle
                        and speed >= Config.minSpeed
                        and not IsVehicleOnAllWheels(veh) == false -- stays grounded

                    if isDrifting then
                        if not drifting then
                            drifting = true
                            SendNUIMessage({ type = 'status', drifting = true })
                        end

                        lastDriftTime = now
                        local gain = math.floor(Config.scorePerTick * combo)
                        score = score + gain
                        currentChain = currentChain + gain
                        combo = math.min(Config.comboMax, combo + Config.comboGainPerTick)

                        if currentChain > bestChain then
                            bestChain = currentChain
                        end

                        SendNUIMessage({
                            type   = 'update',
                            score  = score,
                            combo  = combo,
                            angle  = math.floor(angle),
                            best   = bestChain
                        })
                    else
                        if drifting and (now - lastDriftTime) > Config.comboDecayTime then
                            drifting = false
                            combo = 1.0
                            currentChain = 0
                            SendNUIMessage({ type = 'status', drifting = false })
                        end

                        SendNUIMessage({
                            type  = 'update',
                            score = score,
                            combo = combo,
                            angle = math.floor(angle),
                            best  = bestChain
                        })
                    end
                else
                    if hudVisible then
                        hudVisible = false
                        drifting = false
                        combo = 1.0
                        currentChain = 0
                        SendNUIMessage({ type = 'hide' })
                    end
                    wait = 500
                end
            else
                if hudVisible then
                    hudVisible = false
                    drifting = false
                    combo = 1.0
                    currentChain = 0
                    SendNUIMessage({ type = 'hide' })
                end
                wait = 500
            end
        else
            wait = 500
        end

        Wait(wait)
    end
end)

local function toggleHud()
    active = not active

    if active then
        resetSession()
        -- HUD will appear automatically once the player is in the driver's seat
    else
        drifting = false
        if pauseHidden then
            pauseHidden = false
            SendNUIMessage({ type = 'pause', hidden = false })
        end
        if hudVisible then
            hudVisible = false
            SendNUIMessage({ type = 'hide' })
        end
    end
end

-- Hide the HUD while the pause menu (ESC / Map) is open
CreateThread(function()
    while true do
        local wait = 500

        if active then
            wait = 0
            local paused = IsPauseMenuActive()

            if paused ~= pauseHidden then
                pauseHidden = paused
                SendNUIMessage({ type = 'pause', hidden = paused })
            end
        end

        Wait(wait)
    end
end)

RegisterCommand(Config.command, function()
    toggleHud()
end, false)

RegisterKeyMapping(Config.command, 'Toggle drift counter HUD', 'keyboard', Config.toggleKey)

-- Reset best chain / score on resource stop cleanly
AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        SendNUIMessage({ type = 'hide' })
    end
end)
