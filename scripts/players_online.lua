-- ap_player_detector_script.lua

-- Function to find the Advanced Peripherals Player Detector peripheral
local function findPlayerDetector()
    -- The peripheral type for Advanced Peripherals Player Detector is "playerDetector"
    --local detector = peripheral.find("playerDetector")
    local detector = peripheral.wrap("right")
    
    if detector == nil then
        print("Advanced Peripherals Player Detector not found. Retrying in 5 seconds...")
    end
    return detector
end

-- Main loop
while true do
    local playerDetector = findPlayerDetector()

    if playerDetector ~= nil then
        -- Get a table (list) of all online players
        local onlinePlayers = playerDetector.getOnlinePlayers()

        -- Get the total count of online players from the table
        local playerCount = #onlinePlayers 

        -- Print the player count and names to the CC monitor (optional)
        print("Current Players Online: " .. playerCount)
        if playerCount > 0 then
            print("Players: " .. table.concat(onlinePlayers, ", "))
        else
            print("No players online.")
        end

        -- Check if the player count is 1
        if playerCount == 1 then
            -- If there's only 1 player, output a redstone signal
            -- Replace "bottom" with the side you want the redstone to output from
            rs.setOutput("bottom", true) 
            print("Player count is 1. Redstone output enabled.")
        else
            -- If there's more than 1 player, ensure redstone is off
            -- Replace "bottom" with the side you want the redstone to output from
            rs.setOutput("bottom", false)
            print("Player count is " .. playerCount .. ". Redstone output disabled.")
        end
    end

    -- Wait for 5 seconds before checking again
    sleep(5) 
end