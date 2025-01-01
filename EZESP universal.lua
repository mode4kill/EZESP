-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Local player reference
local localPlayer = Players.LocalPlayer

---------------------------------------
-- Username Tags (Red Text Near Waist)
---------------------------------------
local function addNameTagToCharacter(character, playerName, isLocalPlayer)
    if isLocalPlayer then return end -- Skip local player

    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    -- Check if the BillboardGui already exists to avoid duplication
    if character:FindFirstChild("UsernameDisplay") then
        return
    end

    -- Create a BillboardGui
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "UsernameDisplay"
    billboardGui.Adornee = humanoidRootPart
    billboardGui.Size = UDim2.new(4, 0, 1, 0) -- Adjust size
    billboardGui.StudsOffset = Vector3.new(0, -1, 0) -- Position near the waist
    billboardGui.AlwaysOnTop = true

    -- Create a TextLabel inside the BillboardGui
    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "UsernameLabel"
    textLabel.Parent = billboardGui
    textLabel.Size = UDim2.new(1, 0, 1, 0) -- Fill the BillboardGui
    textLabel.BackgroundTransparency = 1 -- Transparent background
    textLabel.Text = playerName -- Set the text to the player's username
    textLabel.TextColor3 = Color3.new(1, 0, 0) -- Red text color
    textLabel.TextScaled = true -- Scale the text to fit
    textLabel.Font = Enum.Font.SourceSansBold -- Set the font

    -- Parent the BillboardGui to the character
    billboardGui.Parent = character
end

local function onPlayerAdded(player)
    player.CharacterAdded:Connect(function(character)
        addNameTagToCharacter(character, player.Name, player == localPlayer)
    end)

    -- Add a name tag if the character already exists
    if player.Character then
        addNameTagToCharacter(player.Character, player.Name, player == localPlayer)
    end
end

-- Add name tags to all existing players
for _, player in pairs(Players:GetPlayers()) do
    onPlayerAdded(player)
end

Players.PlayerAdded:Connect(onPlayerAdded)

--------------------------------------
-- Hollow Box with Health Bar (ESP)
--------------------------------------
local function createESP(character, isLocalPlayer)
    if isLocalPlayer then return end -- Skip local player

    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    local humanoid = character:WaitForChild("Humanoid")

    -- Check if ESP already exists
    if humanoidRootPart:FindFirstChild("ESPBox") then return end

    -- Create a SelectionBox for the hollow box
    local selectionBox = Instance.new("SelectionBox")
    selectionBox.Name = "ESPBox"
    selectionBox.Adornee = character
    selectionBox.LineThickness = 0.05 -- Thin box outline
    selectionBox.Color3 = Color3.new(1, 1, 1) -- White color
    selectionBox.SurfaceTransparency = 0.8 -- Transparency level
    selectionBox.Parent = humanoidRootPart

    -- Create the health bar (BillboardGui)
    local healthGui = Instance.new("BillboardGui")
    healthGui.Name = "HealthDisplay"
    healthGui.Adornee = humanoidRootPart
    healthGui.Size = UDim2.new(2, 0, 0.2, 0) -- Smaller size
    healthGui.StudsOffset = Vector3.new(0, 3, 0) -- Above character
    healthGui.AlwaysOnTop = true
    healthGui.Parent = humanoidRootPart

    local healthBarBackground = Instance.new("Frame")
    healthBarBackground.Name = "HealthBarBackground"
    healthBarBackground.Size = UDim2.new(1, 0, 1, 0)
    healthBarBackground.Position = UDim2.new(0, 0, 0, 0)
    healthBarBackground.BackgroundColor3 = Color3.new(0, 0, 0) -- Black background
    healthBarBackground.BorderSizePixel = 0
    healthBarBackground.Parent = healthGui

    local healthBar = Instance.new("Frame")
    healthBar.Name = "HealthBar"
    healthBar.Size = UDim2.new(humanoid.Health / humanoid.MaxHealth, 0, 1, 0)
    healthBar.BackgroundColor3 = Color3.new(0, 1, 0) -- Green
    healthBar.BorderSizePixel = 0
    healthBar.Parent = healthBarBackground

    humanoid:GetPropertyChangedSignal("Health"):Connect(function()
        healthBar.Size = UDim2.new(math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1), 0, 1, 0)

        -- Change health bar color based on health percentage
        if humanoid.Health / humanoid.MaxHealth > 0.5 then
            healthBar.BackgroundColor3 = Color3.new(0, 1, 0) -- Green
        elseif humanoid.Health / humanoid.MaxHealth > 0.2 then
            healthBar.BackgroundColor3 = Color3.new(1, 1, 0) -- Yellow
        else
            healthBar.BackgroundColor3 = Color3.new(1, 0, 0) -- Red
        end
    end)
end

local function addESPToPlayer(player)
    player.CharacterAdded:Connect(function(character)
        createESP(character, player == localPlayer)
    end)

    if player.Character then
        createESP(player.Character, player == localPlayer)
    end
end

for _, player in pairs(Players:GetPlayers()) do
    addESPToPlayer(player)
end

Players.PlayerAdded:Connect(addESPToPlayer)

--------------------------------------
-- Tracers (Red Beams to Other Players)
--------------------------------------
local function createTracer(fromCharacter, toCharacter, isLocalPlayer)
    if not isLocalPlayer then return end -- Only create tracers from the local player

    local fromPart = fromCharacter:WaitForChild("HumanoidRootPart")
    local toPart = toCharacter:WaitForChild("HumanoidRootPart")

    -- Check if the Beam already exists to avoid duplication
    if fromPart:FindFirstChild("PointerTo_" .. toCharacter.Name) then
        return
    end

    -- Create Attachments on both HumanoidRootParts
    local fromAttachment = Instance.new("Attachment")
    fromAttachment.Name = "FromAttachment"
    fromAttachment.Parent = fromPart

    local toAttachment = Instance.new("Attachment")
    toAttachment.Name = "ToAttachment"
    toAttachment.Parent = toPart

    -- Create a Beam to connect the Attachments
    local beam = Instance.new("Beam")
    beam.Name = "PointerTo_" .. toCharacter.Name
    beam.Attachment0 = fromAttachment
    beam.Attachment1 = toAttachment
    beam.Color = ColorSequence.new(Color3.new(1, 0, 0)) -- Red color
    beam.Width0 = 0.1 -- Starting width
    beam.Width1 = 0.1 -- Ending width
    beam.FaceCamera = true -- Make it always face the camera
    beam.Parent = fromPart
end

local function addTracersToPlayer(player)
    player.CharacterAdded:Connect(function(character)
        if localPlayer.Character then
            createTracer(localPlayer.Character, character, true)
        end
    end)

    if player.Character and localPlayer.Character then
        createTracer(localPlayer.Character, player.Character, true)
    end
end

-- Create tracers for all existing players
for _, player in pairs(Players:GetPlayers()) do
    if player ~= localPlayer then
        addTracersToPlayer(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= localPlayer then
        addTracersToPlayer(player)
    end
end)
