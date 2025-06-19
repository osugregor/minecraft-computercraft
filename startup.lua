-- This script downloads and updates other scripts from gregs computer craft repository

-- Optional: Specify a script to run automatically after all updates.
-- Set this to nil (or an empty string) if you don't want any script to run automatically.
local SCRIPT_TO_AUTO_RUN = nil

-- --- Configuration ---
local REPO_OWNER = "osugregor"
local REPO_NAME = "minecraft-computercraft"
local REPO_BRANCH = "main"
local SCRIPT_FOLDER_NAME = "scripts"

-- --- Internal Variables (Do not modify) ---
local had_errors = false -- Flag to track if any errors occurred during execution

-- --- Helper Functions ---

-- Prints an error message in red for better visibility
local function printError(message)
    term.setTextColor(colors.red)
    print("ERROR: " .. message)
    term.setTextColor(colors.white) -- Reset color
    had_errors = true -- Set the error flag
end

-- Downloads a single file from a given URL to a destination path using 'wget'.
-- 'wget' in ComputerCraft by default overwrites existing files when an output filename is provided.
local function downloadFile(url, destinationPath)
    -- print("Downloading: " .. url)
    local success, reason = pcall(shell.run, "wget", url, destinationPath)
    if not success then
        printError("Failed to download " .. destinationPath .. ": " .. tostring(reason))
        return false
    else
        -- print("  -> Saved as /" .. destinationPath)
        return true
    end
end

-- Fetches a list of filenames from a specific folder within a GitHub repository using the GitHub API.
-- Returns a table of filenames, or nil if an error occurs.
local function getGitHubFolderContents(owner, repo, branch, folderPath)
    local api_url = "https://api.github.com/repos/" .. owner .. "/" .. repo .. "/contents/" .. folderPath .. "?ref=" .. branch
    print("Fetching file list from GitHub API: " .. api_url)

    local response_handle, err = http.get(api_url) -- Use http.get for synchronous request
    if not response_handle then
        printError("Failed to connect to GitHub API: " .. tostring(err))
        return nil
    end

    local response_body = response_handle.readAll()
    response_handle.close()

    local success, data = pcall(textutils.unserializeJSON, response_body)
    if not success then
        printError("Failed to parse GitHub API response (JSON error): " .. tostring(data))
        printError("Response body was: " .. response_body)
        return nil
    end

    if type(data) ~= "table" then
        printError("GitHub API response was not a table. Unexpected format.")
        return nil
    end

    local filenames = {}
    for _, item in ipairs(data) do
        if item.type == "file" and item.name then
            table.insert(filenames, item.name)
        end
    end

    return filenames
end

-- --- Main Script Logic ---

-- 1. Check if the HTTP API is enabled
if not http then
    printError("HTTP API is NOT enabled! Please enable it in ComputerCraft.cfg (B:http_enable=true).")
    printError("This script requires internet access to download files.")
    return -- Exit the script if no internet access
end

-- 2. Create the target script folder if it doesn't exist
if not fs.exists(SCRIPT_FOLDER_NAME) then
    print("Creating script folder: /" .. SCRIPT_FOLDER_NAME)
    local success, reason = pcall(fs.makeDir, SCRIPT_FOLDER_NAME)
    if not success then
        printError("Failed to create folder /" .. SCRIPT_FOLDER_NAME .. ": " .. tostring(reason))
        return -- Exit if folder creation fails
    end
end

-- 3. Dynamically get list of scripts from GitHub
print("\n--- Getting Script List from GitHub Repository ---")
local SCRIPTS_TO_DOWNLOAD = getGitHubFolderContents(REPO_OWNER, REPO_NAME, REPO_BRANCH, SCRIPT_FOLDER_NAME)
local REPO_BASE_URL = "https://raw.githubusercontent.com/" .. REPO_OWNER .. "/" .. REPO_NAME .. "/refs/heads/" .. REPO_BRANCH .. "/" .. SCRIPT_FOLDER_NAME .. "/"

if not SCRIPTS_TO_DOWNLOAD or #SCRIPTS_TO_DOWNLOAD == 0 then
    printError("Could not get a list of scripts from GitHub or the folder is empty.")
    print("Please check REPO_OWNER, REPO_NAME, REPO_BRANCH, and SCRIPT_FOLDER_NAME configuration.")
    -- Continue to the next step, but no scripts will be downloaded.
else
    -- print("Found " .. #SCRIPTS_TO_DOWNLOAD .. " scripts to download.")
    -- 4. Download and update all specified scripts
    -- print("\n--- Downloading/Updating Scripts from GitHub ---")
    local downloaded_count = 0
    for _, filename in ipairs(SCRIPTS_TO_DOWNLOAD) do
        local source_url = REPO_BASE_URL .. filename
        local destination_path = SCRIPT_FOLDER_NAME .. "/" .. filename
        if downloadFile(source_url, destination_path) then
            downloaded_count = downloaded_count + 1
        end
    end

    if not had_errors and downloaded_count == #SCRIPTS_TO_DOWNLOAD then
        term.clear()
        term.setCursorPos(1,1)    
        term.setTextColor(colors.orange)
        print(": " .. message)
        print("Terminal Startup Success: " .. downloaded_count .. " scripts updated/downloaded to /" .. SCRIPT_FOLDER_NAME .. " folder.\n")
        term.setTextColor(colors.white) -- Reset color
    else
        printError("!!!!ERRORS OCCURED DURING STARTUP, CHECK THE LOGS ABOVE!!!!!!")
    end
end


-- 4. Optional: Run a specified script after updating
-- The script name to run is now defined in the SCRIPT_TO_AUTO_RUN variable at the top.
if SCRIPT_TO_AUTO_RUN and SCRIPT_TO_AUTO_RUN ~= "" then
    local full_script_path = SCRIPT_FOLDER_NAME .. "/" .. SCRIPT_TO_AUTO_RUN
    print("Running specified script: /" .. full_script_path)

    if fs.exists(full_script_path) then
        local success, reason = pcall(shell.run, full_script_path)
        if not success then
            printError("Failed to run " .. full_script_path .. ": " .. tostring(reason))
            printError("Error details: " .. tostring(reason)) -- More detailed error for debugging
        else
            -- If the script run by shell.run() exits, this startup script will resume.
            -- If the launched script contains an infinite loop, this startup script
            -- will effectively pause here until the launched script is terminated.
        end
    else
        printError("Specified script not found in /" .. SCRIPT_FOLDER_NAME .. ": " .. SCRIPT_TO_AUTO_RUN)
        printError("Please ensure the script name defined in SCRIPT_TO_AUTO_RUN is correct and exists in your repository.")
    end
else
    -- print("No script specified to run after update via SCRIPT_TO_AUTO_RUN variable.")
end

-- print("\n--- Startup Script Finished ---")

