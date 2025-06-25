RegisterNetEvent("qb-adminnoclip:checkPerms")
AddEventHandler("qb-adminnoclip:checkPerms", function()
    local src = source
    local allowed = IsPlayerAceAllowed(src, "admin.noclip")
    TriggerClientEvent("qb-adminnoclip:setAdminStatus", src, allowed)
end)
