function destroyAll()
    -- Destroy platforms
    for i = #platforms, 1, -1 do
        if platforms[i] then
            platforms[i]:destroy()
            table.remove(platforms, i)
        end
    end

    -- Destroy walls
    for i = #walls, 1, -1 do
        if walls[i] then
            walls[i]:destroy()
            table.remove(walls, i)
        end
    end

    -- Destroy levels
    for i = #levels, 1, -1 do
        if levels[i] then
            levels[i]:destroy()
            table.remove(levels, i)
        end
    end

    -- Destroy switches
    for i = #switches, 1, -1 do
        if switches[i] then
            switches[i]:destroy()
            table.remove(switches, i)
        end
    end

    -- Destroy gates
    for i = #gates, 1, -1 do
        if gates[i] then
            gates[i]:destroy()
            table.remove(gates, i)
        end
    end

    -- Destroy teleports
    for i = #teleports, 1, -1 do
        if teleports[i] then
            teleports[i]:destroy()
            table.remove(teleports, i)
        end
    end

    -- Destroy shops
    for i = #shops, 1, -1 do
        if shops[i] then
            shops[i]:destroy()
            table.remove(shops, i)
        end
    end

    -- Destroy statues
    for i = #statues, 1, -1 do
        if statues[i] then
            statues[i]:destroy()
            table.remove(statues, i)
        end
    end

    -- Destroy watchers
    for i = #watchers, 1, -1 do
        if watchers[i] then
            watchers[i]:destroy()
            table.remove(watchers, i)
        end
    end

    -- Destroy ghouls
    for i = #ghouls, 1, -1 do
        if ghouls[i] then
            ghouls[i]:destroy()
            table.remove(ghouls, i)
        end
    end

    -- Destroy summoners
    for i = #summoners, 1, -1 do
        if summoners[i] then
            summoners[i]:destroy()
            table.remove(summoners, i)
        end
    end

    -- Destroy spitters
    for i = #spitters, 1, -1 do
        if spitters[i] then
            spitters[i]:destroy()
            table.remove(spitters, i)
        end
    end

    -- Destroy projectiles
    for i = #projectiles, 1, -1 do
        if projectiles[i] then
            projectiles[i]:destroy()
            table.remove(projectiles, i)
        end
    end

    -- Destroy wasps
    for i = #wasps, 1, -1 do
        if wasps[i] then
            wasps[i]:destroy()
            table.remove(wasps, i)
        end
    end

    -- Destroy hives
    for i = #hives, 1, -1 do
        if hives[i] then
            hives[i]:destroy()
            table.remove(hives, i)
        end
    end 

    -- Destroy boss attack hitboxes
    if boss and boss.attackHitboxes then
        for i = #boss.attackHitboxes, 1, -1 do
            local hitbox = boss.attackHitboxes[i]
            if hitbox and not hitbox:isDestroyed() then
                hitbox:destroy()
                table.remove(boss.attackHitboxes, i)
            end
        end
    end

    -- Destroy the Game_Win object
    if gameWin then
        gameWin:destroy()
        gameWin = nil  -- Set it back to nil after destroying
    end    
end