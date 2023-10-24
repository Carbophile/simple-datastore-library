-- Get the DataStoreService and create a new DataStore called "SDL"
local service = game:GetService("DataStoreService")
local dataStore = service:GetDataStore("SDL")

-- Get the Players service
local players = game:GetService("Players")

-- Create a new folder in ServerStorage to hold the SDL values
local serverStorage = game:GetService("ServerStorage")
local serverFolder = Instance.new("Folder")
serverFolder.Name = "SDL"
serverFolder.Parent = serverStorage

-- Set up a RemoteFunction to allow server scripts to add tracked values
local acceptingValues = true
local addTrackedValue = Instance.new("BindableFunction")
addTrackedValue.Name = "AddTrackedValue"
addTrackedValue.Parent = serverFolder

-- Create an empty table to hold the tracked values
local trackedValues = {}

-- Set up the OnServerInvoke function for the RemoteFunction
addTrackedValue.OnInvoke = function(name, type, defaultValue)
    -- Only accept new values before initialization is complete
    if acceptingValues then
        -- Check that the type is a Value type
        if string.sub(type, -5) == "Value" then
            -- Check that all required parameters are provided
            if name == nil then
                return false, "Name must be provided."
            end
            if type == nil then
                return false, "Type must be provided."
            end
            if defaultValue == nil then
                return false, "Default value must be provided."
            end
            -- Add the new tracked value to the table
            table.insert(trackedValues, {name, type, defaultValue})
            return true
        else
            return false, "Invalid type. Must be a Value type."
        end
    else
        return false, "Can not add new tracked value after initialization is complete. Send a request earlier."
    end
end

-- Set up a PlayerAdded event to initialize SDL values for new players
players.PlayerAdded:Connect(function(player)
    -- Stop accepting new values
    acceptingValues = false
    -- Create a new folder in the player to hold their SDL values
    local playerFolder = Instance.new("Folder")
    playerFolder.Name = "SDL"
    playerFolder.Parent = player
    -- Loop through the tracked values and create new instances for each one
    for _, value in pairs(trackedValues) do
        local newValue = Instance.new(value[2])
        newValue.Name = value[1]
        newValue.Parent = playerFolder
        newValue.Value = value[3]
    end
    -- Try to load the player's data from the DataStore
    local success, errormessage = pcall(function()
        local data = dataStore:GetAsync(player.UserId)
        -- Ensure that the data is not nil
        if not data then
            data = {}
        end
        -- Loop through the tracked values and set their values to the loaded data
        for _, value in pairs(trackedValues) do
            if data[value[1]] then
                playerFolder:FindFirstChild(value[1]).Value = data[value[1]]
            end
        end
    end)
    -- If loading the data fails, kick the player and print an error message
    if not success then
        player:Kick("Failed to load data. Please rejoin.")
        warn(errormessage)
    end
end)

-- Set up a PlayerRemoving event to save SDL values for leaving players
players.PlayerRemoving:Connect(function(player)
    --Access the player's ID
    local playerID = player.UserId
    -- Find the player's SDL folder
    local playerFolder = player:FindFirstChild("SDL")
    if playerFolder then
        -- Create a table to hold the player's data
        local data = {}
        -- Loop through the tracked values and add their values to the data table
        for _, value in pairs(trackedValues) do
            data[value[1]] = playerFolder:FindFirstChild(value[1]).Value
        end
        -- Try to save the data to the DataStore
        local success, errormessage = pcall(function()
            dataStore:SetAsync(player.UserId, data)
        end)
        -- If saving the data fails, print an error message and retry once
        if not success then
            warn(errormessage)
            print("Retrying...")
            success, errormessage = pcall(function()
                dataStore:SetAsync(playerID, data)
            end)
            -- If the retry succeeds, print a success message
            if success then
                print("Success!")
            else
                -- If the retry fails, print an error message
                print("Failed to save data for player " .. player.Name .. " (" .. player.UserId .. ")")
                warn(errormessage)
            end
        end
    end
end)