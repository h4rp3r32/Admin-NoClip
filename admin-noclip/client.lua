local QBCore = exports['qb-core']:GetCoreObject()

local noclip = false
local invisible = false
local isAdmin = false
local toggleRequested = false
local noclipSpeed = 1.0
local thirdPerson = false

local noclipToggleKey = 167 -- F6
local invisToggleKey = 249  -- N key

-- Ask the server if we're an admin on resource start
Citizen.CreateThread(function()
    TriggerServerEvent("qb-adminnoclip:checkPerms")
end)

-- Show/hide NUI menu
function SetNoclipUI(state)
    SendNUIMessage({ type = state and "showMenu" or "hideMenu" })
end

-- Server replies with admin status
RegisterNetEvent("qb-adminnoclip:setAdminStatus")
AddEventHandler("qb-adminnoclip:setAdminStatus", function(status)
    print("Received admin status from server:", status)
    isAdmin = status

    if toggleRequested then
        print("Toggle requested, isAdmin:", isAdmin)
        if isAdmin then
            noclip = not noclip
            print("Noclip toggled:", noclip)
            local ped = PlayerPedId()

            if noclip then
                invisible = true -- default invis when noclip on
                SetEntityVisible(ped, false, false)
                SetEntityCollision(ped, false, false)
                SetEntityInvincible(ped, true)
                ClearPedTasksImmediately(ped)
                SetNoclipUI(true)
            else
                invisible = false
                SetEntityVisible(ped, true, false)
                SetEntityCollision(ped, true, true)
                SetEntityInvincible(ped, false)
                ClearPedTasksImmediately(ped)
                SetEntityVelocity(ped, 0.0, 0.0, 0.0)
                SetNoclipUI(false)

                -- Safely place ped on ground after noclip off
                local x, y, z = table.unpack(GetEntityCoords(ped))
                local groundZ = nil
                local tries = 0

                repeat
                    tries = tries + 1
                    local success, zPos = GetGroundZFor_3dCoord(x, y, z + 2.0, 0, false)
                    if success then
                        groundZ = zPos
                    else
                        Citizen.Wait(100)
                    end
                until groundZ or tries > 20

                if groundZ then
                    SetEntityCoordsNoOffset(ped, x, y, groundZ, true, true, true)
                else
                    SetEntityCoordsNoOffset(ped, x, y, z, true, true, true)
                end

                thirdPerson = false
                SetFollowPedCamViewMode(1) -- reset to 1st person
            end
        else
            print("No permission to toggle noclip")
        end
        toggleRequested = false
    else
        print("Toggle not requested, ignoring admin status")
    end
end)

-- Command to toggle noclip
RegisterCommand("adminnoclip", function()
    toggleRequested = true
    TriggerServerEvent("qb-adminnoclip:checkPerms")
end)

-- F6 key to toggle noclip
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustReleased(0, noclipToggleKey) then
            toggleRequested = true
            TriggerServerEvent("qb-adminnoclip:checkPerms")
        end
    end
end)

-- N key to toggle invisibility while noclipped
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if noclip and IsControlJustReleased(0, invisToggleKey) then
            invisible = not invisible
            local ped = PlayerPedId()
            SetEntityVisible(ped, not invisible, false)
            print("Noclip invisibility toggled. Invisible:", invisible)
        end
    end
end)

-- Numpad 0 toggles first/third person camera while noclipping
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if noclip and IsControlJustReleased(0, 96) then -- Numpad 0
            thirdPerson = not thirdPerson
            SetFollowPedCamViewMode(thirdPerson and 4 or 1)
        end
    end
end)

-- Noclip movement logic (fly around + idle + heading fix)
Citizen.CreateThread(function()
    while true do
        if noclip then
            local ped = PlayerPedId()
            local camRot = GetGameplayCamRot(0)

            local forwardVector = vector3(
                -math.sin(math.rad(camRot.z)) * math.cos(math.rad(camRot.x)),
                math.cos(math.rad(camRot.z)) * math.cos(math.rad(camRot.x)),
                math.sin(math.rad(camRot.x))
            )

            -- Speed control
            if IsControlPressed(0, 21) then -- Shift faster
                noclipSpeed = 6.0
            elseif IsControlPressed(0, 29) then -- B slower
                noclipSpeed = 0.1
            else
                noclipSpeed = 0.7
            end

            local pos = GetEntityCoords(ped)

            -- Move forward/back (W/S)
            if IsControlPressed(0, 32) then pos = pos + forwardVector * noclipSpeed end
            if IsControlPressed(0, 33) then pos = pos - forwardVector * noclipSpeed end

            -- Calculate right vector relative to camera (A/D)
            local rightVector = vector3(
                math.cos(math.rad(camRot.z)),
                math.sin(math.rad(camRot.z)),
                0
            )

            if IsControlPressed(0, 34) then pos = pos - rightVector * noclipSpeed end
            if IsControlPressed(0, 35) then pos = pos + rightVector * noclipSpeed end

            -- Vertical movement (Q/E)
            if IsControlPressed(0, 44) then pos = pos - vector3(0, 0, noclipSpeed) end
            if IsControlPressed(0, 46) then pos = pos + vector3(0, 0, noclipSpeed) end

            -- Apply position, disable velocity & collision
            SetEntityCoordsNoOffset(ped, pos.x, pos.y, pos.z, true, true, true)
            SetEntityVelocity(ped, 0.0, 0.0, 0.0)
            SetEntityCollision(ped, false, false)
            SetEntityVisible(ped, not invisible, false)
            SetEntityInvincible(ped, true)

            -- ❗ Play idle animation
            if not IsEntityPlayingAnim(ped, "move_m@buzzed", "idle", 3) then
                RequestAnimDict("move_m@buzzed")
                while not HasAnimDictLoaded("move_m@buzzed") do
                    Citizen.Wait(0)
                end
                TaskPlayAnim(ped, "move_m@buzzed", "idle", 1.0, -1.0, -1, 1, 0, false, false, false)
            end

            -- ❗ Face camera direction
            local heading = camRot.z
            SetEntityHeading(ped, heading)

            -- Disable controls to prevent animation breaks
            DisableControlAction(0, 22, true)  -- jump
            DisableControlAction(0, 23, true)  -- enter vehicle
            DisableControlAction(0, 36, true)  -- stealth/crouch
            DisablePlayerFiring(PlayerId(), true)

            Citizen.Wait(0)
        else
            Citizen.Wait(500)
        end
    end
end)
