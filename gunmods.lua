local function toggleTableAttribute(attribute, value)
    for _, gcVal in pairs(getgc(true)) do
        if type(gcVal) == "table" and rawget(gcVal, attribute) then
            gcVal[attribute] = value
        end
    end
end

toggleTableAttribute("ShootCooldown", 0)
toggleTableAttribute("ShootSpread", 0)
toggleTableAttribute("ShootRecoil", 0)

if game.GameId == 6035872082 then
    local Storage = game:GetService("ReplicatedStorage")
    local Items = require(Storage.Modules.ItemLibrary).Items

    -- ====================== FAST FIRE (Guns) ======================
    local gunExceptions = {
        ["Sniper"] = false,
        ["Crossbow"] = false,
        ["Bow"] = false,
        ["RPG"] = false,
    }

    for name, data in pairs(Items) do
        if typeof(data) == "table" and not gunExceptions[name] then
            if data.ShootSpread then data.ShootSpread = 0 end
            if data.ShootAccuracy then data.ShootAccuracy = 0 end
            if data.ShootRecoil then data.ShootRecoil = 0 end
            if data.ShootCooldown then data.ShootCooldown = 0.001 end
            if data.ShootBurstCooldown then data.ShootBurstCooldown = 0.001 end
        end
    end

    -- ====================== FAST MELEE ======================
    for name, data in pairs(Items) do
        if typeof(data) == "table" then
            -- Common melee cooldown properties in Rivals
            if data.AttackCooldown then data.AttackCooldown = 0.001 end
            if data.SwingCooldown then data.SwingCooldown = 0.001 end
            if data.MeleeCooldown then data.MeleeCooldown = 0.001 end
            if data.Cooldown then data.Cooldown = 0.001 end
            if data.RecoveryTime then data.RecoveryTime = 0.001 end
            if data.ResetTime then data.ResetTime = 0.001 end
        end
    end

