--[[
  Advanced Peripherals Player Detector Script with Monitor Output
  
  Description:
  This script uses an Advanced Peripherals Player Detector to count the number of players
  currently online on the server. It displays the count and player names on an attached
  monitor and also outputs a redstone signal based on the player count.

  Configuration:
  - Place a ComputerCraft computer.
  - Attach an Advanced Peripherals Player Detector to one side (default: "left").
  - Attach a Monitor to another side (default: "top").
  - Connect a redstone wire/device to another side (default: "right").
  - Edit the `config` table below to match your setup if it's different.
]]

-- =============================================================================
--                            CONFIGURATION
-- =============================================================================

local config = {
    -- The side the Player Detector is attached to.
    playerDetectorSide = "left",
    -- The side the Monitor is attached to.
    monitorSide = "top",
    -- The side to output the redstone signal from.
    redstoneSide = "right"
}

-- =============================================================================
--                           PERIPHERAL SETUP
-- =============================================================================

-- Function to find and wrap the Player Detector peripheral.
-- It will return the peripheral object or nil if not found.
local function findPlayerDetector()
    print("Searching for Player Detector on side: " .. config.playerDetectorSide)
    local detector = peripheral.wrap(config.playerDetectorSide)
    
    if detector == nil then
        print("Advanced Peripherals Player Detector not found.")
    end
    return detector
end

-- Function to find and wrap the Monitor peripheral.
-- It will return the peripheral object or nil if not found.
local function findMonitor()
    print("Searching for Monitor on side: " .. config.monitorSide)
    local mon = peripheral.wrap(config.monitorSide)

    if mon == nil then
        print("Monitor not found.")
    end
    return mon
end


-- =============================================================================
--                              MAIN LOOP
-- =============================================================================

print("Player Detector script starting...")

while true do
    -- Attempt to connect to peripherals in each loop iteration.
    -- This allows for peripherals to be added or removed while the script is running.
    local playerDetector = findPlayerDetector()
    local monitor = findMonitor()

    -- Proceed only if the player detector is connected.
    if playerDetector ~= nil then
        -- Get a table (list) of all online players.
        local onlinePlayers = playerDetector.getOnlinePlayers()

        -- Get the total count of online players from the table's length.
        local playerCount = #onlinePlayers 

        -- === CONSOLE OUTPUT (Computer's own screen) ===
        term.clear()
        term.setCursorPos(1,1)
        print("--- Player Detector Status ---")
        print("Current Players Online: " .. playerCount)
        if playerCount > 0 then
            print("Players: " .. table.concat(onlinePlayers, ", "))
        else
            print("No players online.")
        end
        print("----------------------------")
        
        -- === MONITOR OUTPUT ===
        if monitor ~= nil then
            -- Clear the monitor to remove old text.
            monitor.clear()
            
            -- Set the text size based on the monitor's dimensions.
            -- This helps make the text larger and more readable.
            local w, h = monitor.getSize()
            monitor.setTextScale(math.min(w / 20, h / 10))

            -- Write title
            monitor.setCursorPos(1, 1)
            monitor.write("Server Player Stats")
            
            -- Write the player count.
            monitor.setCursorPos(1, 3)
            monitor.write("Players Online: " .. playerCount)
            
            -- Write the list of players if any are online.
            if playerCount > 0 then
                monitor.setCursorPos(1, 5)
                monitor.write("Player List:")
                monitor.setCursorPos(1, 6)
                monitor.write(table.concat(onlinePlayers, ", "))
            end
        end

        -- === REDSTONE LOGIC ===
        -- Note: This logic enables redstone when ZERO players are online.
        if playerCount == 0 then
            -- If no players are online, output a redstone signal.
            rs.setOutput(config.redstoneSide, true) 
            print("Player count is 0. Redstone output ENABLED.")
        else
            -- If one or more players are online, turn the redstone signal off.
            rs.setOutput(config.redstoneSide, false)
            print("Player count is " .. playerCount .. ". Redstone output DISABLED.")
        end
    end

    -- Wait for 5 seconds before checking again.
    print("Waiting 5 seconds...")
    sleep(5) 
end
