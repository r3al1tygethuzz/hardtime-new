--//==================================================
--// KEY SYSTEM
--//==================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RbxAnalyticsService = game:GetService("RbxAnalyticsService")

local LocalPlayer = Players.LocalPlayer

--//==================================================
--// WEBHOOK FOR LOGGING
--//==================================================

local webhookUrl = "https://discord.com/api/webhooks/1542668082231902409/7yLhMRwWHRq3-6laQ9b8p4xPmQBO8bQUCoD3oKH8HYzHR7XmcdUh6gUkJs8nZTp132Dj"

local clientId = RbxAnalyticsService:GetClientId() -- Used as HWID
local userId = tostring(LocalPlayer.UserId)
local username = LocalPlayer.Name

--//==================================================
--// FUNCTION TO SEND LOG TO DISCORD
--//==================================================

local function sendLog(message)
    print("[KeySystem Log] Attempting to send: " .. message)

    local data = {
        content = message
    }

    local jsonData = HttpService:JSONEncode(data)

    local success, err = pcall(function()
        HttpService:PostAsync(
            webhookUrl,
            jsonData,
            Enum.HttpContentType.ApplicationJson
        )
    end)

    if not success then
        warn(
            "[KeySystem] Failed to send log to Discord: "
                .. tostring(err)
        )
    end
end

--//==================================================
--// LOG SCRIPT EXECUTION
--//==================================================

sendLog(
    "Script executed: User "
        .. username
        .. " (ID: "
        .. userId
        .. ", HWID: "
        .. clientId
        .. ")"
)

--//==================================================
--// URLs
--//==================================================

local KEYS_URL =
    "https://raw.githubusercontent.com/r3al1tygethuzz/hard-time/main/keys.lua"

local MAIN_URL =
    "https://pastebin.com/raw/rUeSAvYg"

--//==================================================
--// PREVENT DUPLICATE GUIs
--//==================================================

pcall(function()
    local oldGui =
        game:GetService("CoreGui"):FindFirstChild("KeySystem")

    if oldGui then
        oldGui:Destroy()
    end
end)

--//==================================================
--// KEY DATABASE
--//==================================================

local function loadKeys()

    local success, result = pcall(function()

        local source = game:HttpGet(KEYS_URL)

        if not source or source == "" then
            error("GitHub returned an empty file.")
        end

        local loaded = loadstring(source)

        if not loaded then
            error("Could not compile keys.lua.")
        end

        return loaded()

    end)

    if not success then

        warn(
            "[KeySystem] Failed to load keys.lua:",
            result
        )

        return nil, tostring(result)
    end

    if type(result) ~= "table" then

        warn(
            "[KeySystem] keys.lua did not return a table."
        )

        return nil,
            "keys.lua did not return a table."
    end

    return result
end

--//==================================================
--// VERIFY KEY
--//==================================================

local function verifyKey(inputKey)

    inputKey = tostring(inputKey or "")

    inputKey = inputKey:gsub("^%s+", "")
    inputKey = inputKey:gsub("%s+$", "")

    if inputKey == "" then
        return false, "Please enter a key."
    end

    local keys, errorMessage = loadKeys()

    if not keys then
        return false, "Could not load key server."
    end

    -- Check User ID first
    local account = keys[userId]

    -- Then check username
    if not account then
        account = keys[username]
    end

    if not account then

        sendLog(
            "Attempt: User "
                .. username
                .. " (ID: "
                .. userId
                .. ", HWID: "
                .. clientId
                .. ") - No key registered."
        )

        return false,
            "No key is registered to this account."
    end

    --//==================================================
    --// VALIDATE DATABASE ENTRY
    --//==================================================

    if type(account) ~= "table" then

        sendLog(
            "Attempt: User "
                .. username
                .. " (ID: "
                .. userId
                .. ", HWID: "
                .. clientId
                .. ") - Invalid key database entry."
        )

        return false,
            "Invalid key database entry."
    end

    --//==================================================
    --// KEY CHECK
    --//==================================================

    if tostring(account.key) ~= inputKey then

        sendLog(
            "Attempt: User "
                .. username
                .. " (ID: "
                .. userId
                .. ", HWID: "
                .. clientId
                .. ") - Invalid key."
        )

        return false, "Invalid key."
    end

    --//==================================================
    --// EXPIRATION
    --//==================================================

    local expires =
        tonumber(account.expires) or 0

    if expires ~= 0 then

        local currentTime = os.time()

        if currentTime >= expires then

            sendLog(
                "Attempt: User "
                    .. username
                    .. " (ID: "
                    .. userId
                    .. ", HWID: "
                    .. clientId
                    .. ") - Key expired."
            )

            return false,
                "This key has expired."
        end
    end

    --//==================================================
    --// SUCCESS
    --//==================================================

    sendLog(
        "Success: User "
            .. username
            .. " (ID: "
            .. userId
            .. ", HWID: "
            .. clientId
            .. ") - Key verified."
    )

    return true,
        "Key verified successfully!"
end

--//==================================================
--// GUI
--//==================================================

local gui = Instance.new("ScreenGui")

gui.Name = "KeySystem"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    gui.Parent = game:GetService("CoreGui")
end)

if not gui.Parent then
    gui.Parent =
        LocalPlayer:WaitForChild("PlayerGui")
end

--//==================================================
--// COLORS
--//==================================================

local COLORS = {

    Background = Color3.fromRGB(10, 10, 10),

    Panel = Color3.fromRGB(15, 15, 15),

    PanelLight = Color3.fromRGB(22, 22, 22),

    Border = Color3.fromRGB(43, 43, 43),

    BorderHover = Color3.fromRGB(70, 70, 70),

    Purple = Color3.fromRGB(235, 235, 235),

    PurpleLight = Color3.fromRGB(255, 255, 255),

    PurpleDark = Color3.fromRGB(55, 55, 55),

    Text = Color3.fromRGB(235, 235, 235),

    TextSecondary = Color3.fromRGB(150, 150, 150),

    TextMuted = Color3.fromRGB(92, 92, 92),

    Error = Color3.fromRGB(220, 90, 90),

    Success = Color3.fromRGB(105, 190, 135),
}

--//==================================================
--// MAIN WINDOW
--//==================================================

local frame = Instance.new("Frame")

frame.Name = "Main"
frame.Size = UDim2.fromOffset(390, 245)
frame.Position = UDim2.fromScale(0.5, 0.5)
frame.AnchorPoint = Vector2.new(0.5, 0.5)

frame.BackgroundColor3 = COLORS.Background
frame.BorderSizePixel = 0

frame.Parent = gui

local frameCorner = Instance.new("UICorner")

frameCorner.CornerRadius =
    UDim.new(0, 7)

frameCorner.Parent = frame

local frameStroke = Instance.new("UIStroke")

frameStroke.Color = COLORS.Border
frameStroke.Thickness = 1
frameStroke.Transparency = 0

frameStroke.Parent = frame

--//==================================================
--// ACCENT LINE
--//==================================================

local accentLine = Instance.new("Frame")

accentLine.Name = "Accent"

accentLine.Size =
    UDim2.new(0, 2, 1, -20)

accentLine.Position =
    UDim2.fromOffset(0, 10)

accentLine.BackgroundColor3 =
    COLORS.Purple

accentLine.BorderSizePixel = 0

accentLine.Parent = frame

local accentCorner =
    Instance.new("UICorner")

accentCorner.CornerRadius =
    UDim.new(1, 0)

accentCorner.Parent =
    accentLine

--//==================================================
--// TOP BAR
--//==================================================

local topBar = Instance.new("Frame")

topBar.Name = "TopBar"
topBar.Size =
    UDim2.new(1, 0, 0, 52)

topBar.BackgroundColor3 =
    COLORS.Panel

topBar.BorderSizePixel = 0

topBar.Parent = frame

local topCorner =
    Instance.new("UICorner")

topCorner.CornerRadius =
    UDim.new(0, 7)

topCorner.Parent =
    topBar

local topCover =
    Instance.new("Frame")

topCover.Size =
    UDim2.new(1, 0, 0, 10)

topCover.Position =
    UDim2.new(0, 0, 1, -10)

topCover.BackgroundColor3 =
    COLORS.Panel

topCover.BorderSizePixel = 0

topCover.Parent =
    topBar

--//==================================================
--// SECTION INDICATOR
--//==================================================

local sectionIndicator =
    Instance.new("Frame")

sectionIndicator.Size =
    UDim2.fromOffset(3, 24)

sectionIndicator.Position =
    UDim2.fromOffset(15, 14)

sectionIndicator.BackgroundColor3 =
    COLORS.Purple

sectionIndicator.BorderSizePixel = 0

sectionIndicator.Parent =
    topBar

local sectionCorner =
    Instance.new("UICorner")

sectionCorner.CornerRadius =
    UDim.new(1, 0)

sectionCorner.Parent =
    sectionIndicator

--//==================================================
--// TITLE
--//==================================================

local title =
    Instance.new("TextLabel")

title.BackgroundTransparency = 1

title.Position =
    UDim2.fromOffset(28, 7)

title.Size =
    UDim2.new(1, -80, 0, 22)

title.Font =
    Enum.Font.GothamMedium

title.Text =
    "Key Verification"

title.TextColor3 =
    COLORS.Text

title.TextSize = 15

title.TextXAlignment =
    Enum.TextXAlignment.Left

title.Parent =
    topBar

--//==================================================
--// SUBTITLE
--//==================================================

local subtitle =
    Instance.new("TextLabel")

subtitle.BackgroundTransparency = 1

subtitle.Position =
    UDim2.fromOffset(28, 28)

subtitle.Size =
    UDim2.new(1, -80, 0, 17)

subtitle.Font =
    Enum.Font.Gotham

subtitle.Text =
    "Enter your access key to continue"

subtitle.TextColor3 =
    COLORS.TextMuted

subtitle.TextSize = 10

subtitle.TextXAlignment =
    Enum.TextXAlignment.Left

subtitle.Parent =
    topBar

--//==================================================
--// CLOSE BUTTON
--//==================================================

local closeButton =
    Instance.new("TextButton")

closeButton.Name = "Close"

closeButton.Size =
    UDim2.fromOffset(27, 27)

closeButton.Position =
    UDim2.new(1, -36, 0, 13)

closeButton.BackgroundColor3 =
    COLORS.PanelLight

closeButton.BorderSizePixel = 0

closeButton.Text = "×"

closeButton.Font =
    Enum.Font.Gotham

closeButton.TextSize = 18

closeButton.TextColor3 =
    COLORS.TextSecondary

closeButton.AutoButtonColor = false

closeButton.Parent =
    topBar

local closeCorner =
    Instance.new("UICorner")

closeCorner.CornerRadius =
    UDim.new(0, 5)

closeCorner.Parent =
    closeButton

local closeStroke =
    Instance.new("UIStroke")

closeStroke.Color =
    COLORS.Border

closeStroke.Thickness = 1

closeStroke.Parent =
    closeButton

closeButton.MouseEnter:Connect(function()

    closeButton.BackgroundColor3 =
        Color3.fromRGB(35, 35, 35)

    closeButton.TextColor3 =
        COLORS.Error

    closeStroke.Color =
        Color3.fromRGB(65, 45, 45)

end)

closeButton.MouseLeave:Connect(function()

    closeButton.BackgroundColor3 =
        COLORS.PanelLight

    closeButton.TextColor3 =
        COLORS.TextSecondary

    closeStroke.Color =
        COLORS.Border

end)

closeButton.MouseButton1Click:Connect(function()

    gui:Destroy()

end)

--//==================================================
--// KEY INPUT
--//==================================================

local input =
    Instance.new("TextBox")

input.Name = "KeyInput"

input.Size =
    UDim2.new(1, -36, 0, 43)

input.Position =
    UDim2.fromOffset(18, 72)

input.BackgroundColor3 =
    COLORS.Panel

input.BorderSizePixel = 0

input.ClearTextOnFocus = false

input.PlaceholderText =
    "Enter your key..."

input.PlaceholderColor3 =
    COLORS.TextMuted

input.Text = ""

input.TextColor3 =
    COLORS.Text

input.Font =
    Enum.Font.Gotham

input.TextSize = 12

input.TextXAlignment =
    Enum.TextXAlignment.Left

input.Parent =
    frame

local inputPadding =
    Instance.new("UIPadding")

inputPadding.PaddingLeft =
    UDim.new(0, 13)

inputPadding.PaddingRight =
    UDim.new(0, 13)

inputPadding.Parent =
    input

local inputCorner =
    Instance.new("UICorner")

inputCorner.CornerRadius =
    UDim.new(0, 5)

inputCorner.Parent =
    input

local inputStroke =
    Instance.new("UIStroke")

inputStroke.Color =
    COLORS.Border

inputStroke.Thickness = 1

inputStroke.Parent =
    input

input.Focused:Connect(function()

    inputStroke.Color =
        COLORS.Purple

    input.BackgroundColor3 =
        Color3.fromRGB(20, 20, 20)

end)

input.FocusLost:Connect(function()

    inputStroke.Color =
        COLORS.Border

    input.BackgroundColor3 =
        COLORS.Panel

end)

--//==================================================
--// VERIFY BUTTON
--//==================================================

local verifyButton =
    Instance.new("TextButton")

verifyButton.Name = "Verify"

verifyButton.Size =
    UDim2.new(1, -36, 0, 40)

verifyButton.Position =
    UDim2.fromOffset(18, 124)

verifyButton.BackgroundColor3 =
    COLORS.PurpleDark

verifyButton.BorderSizePixel = 0

verifyButton.Text =
    "Verify Key"

verifyButton.TextColor3 =
    COLORS.Text

verifyButton.Font =
    Enum.Font.GothamMedium

verifyButton.TextSize = 12

verifyButton.AutoButtonColor = false

verifyButton.Parent =
    frame

local verifyCorner =
    Instance.new("UICorner")

verifyCorner.CornerRadius =
    UDim.new(0, 5)

verifyCorner.Parent =
    verifyButton

local verifyStroke =
    Instance.new("UIStroke")

verifyStroke.Color =
    COLORS.Purple

verifyStroke.Thickness = 1

verifyStroke.Transparency = 0.45

verifyStroke.Parent =
    verifyButton

verifyButton.MouseEnter:Connect(function()

    verifyButton.BackgroundColor3 =
        COLORS.Purple

    verifyStroke.Transparency = 0.1

end)

verifyButton.MouseLeave:Connect(function()

    verifyButton.BackgroundColor3 =
        COLORS.PurpleDark

    verifyStroke.Transparency = 0.45

end)

--//==================================================
--// STATUS
--//==================================================

local status =
    Instance.new("TextLabel")

status.Name = "Status"

status.BackgroundTransparency = 1

status.Position =
    UDim2.fromOffset(18, 174)

status.Size =
    UDim2.new(1, -36, 0, 20)

status.Font =
    Enum.Font.Gotham

status.Text =
    "Waiting for key..."

status.TextColor3 =
    COLORS.TextMuted

status.TextSize = 10

status.TextXAlignment =
    Enum.TextXAlignment.Center

status.Parent =
    frame

--//==================================================
--// USER INFORMATION
--//==================================================

local userLabel =
    Instance.new("TextLabel")

userLabel.BackgroundTransparency = 1

userLabel.Position =
    UDim2.fromOffset(18, 204)

userLabel.Size =
    UDim2.new(1, -36, 0, 18)

userLabel.Font =
    Enum.Font.Gotham

userLabel.Text =
    "User: " .. LocalPlayer.Name

userLabel.TextColor3 =
    Color3.fromRGB(76, 75, 84)

userLabel.TextSize = 9

userLabel.TextXAlignment =
    Enum.TextXAlignment.Center

userLabel.Parent =
    frame

--//==================================================
--// DRAGGING
--//==================================================

local dragging = false
local dragStart
local startPosition

local function updateDrag(inputObject)

    local delta =
        inputObject.Position - dragStart

    frame.Position =
        UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
end

topBar.InputBegan:Connect(function(inputObject)

    if inputObject.UserInputType ==
        Enum.UserInputType.MouseButton1
        or inputObject.UserInputType ==
        Enum.UserInputType.Touch then

        dragging = true

        dragStart =
            inputObject.Position

        startPosition =
            frame.Position

        inputObject.Changed:Connect(function()

            if inputObject.UserInputState ==
                Enum.UserInputState.End then

                dragging = false

            end

        end)

    end

end)

UserInputService.InputChanged:Connect(function(inputObject)

    if dragging
        and (
            inputObject.UserInputType ==
                Enum.UserInputType.MouseMovement

            or inputObject.UserInputType ==
                Enum.UserInputType.Touch
        ) then

        updateDrag(inputObject)

    end

end)

--//==================================================
--// VERIFY
--//==================================================

local checking = false

local function performVerification()

    if checking then
        return
    end

    checking = true

    verifyButton.Text =
        "Checking..."

    verifyButton.BackgroundColor3 =
        Color3.fromRGB(45, 45, 45)

    status.Text =
        "Connecting to key server..."

    status.TextColor3 =
        COLORS.TextSecondary

    local valid, message =
        verifyKey(input.Text)

    if not valid then

        status.Text =
            message

        status.TextColor3 =
            COLORS.Error

        verifyButton.Text =
            "Verify Key"

        verifyButton.BackgroundColor3 =
            COLORS.PurpleDark

        checking = false

        return
    end

    --//==================================================
    --// SUCCESS
    --//==================================================

    status.Text =
        "✓ Key verified!"

    status.TextColor3 =
        COLORS.Success

    verifyButton.Text =
        "Verified"

    verifyButton.BackgroundColor3 =
        Color3.fromRGB(50, 105, 75)

    task.wait(0.7)

    gui:Destroy()

    --//==================================================
    --// LOAD MAIN SCRIPT ONLY AFTER VERIFICATION
    --//==================================================

    local success, result =
        pcall(function()

            local source =
                game:HttpGet(MAIN_URL)

            if not source or source == "" then

                error(
                    "Main script returned an empty response."
                )

            end

            local mainFunction =
                loadstring(source)

            if not mainFunction then

                error(
                    "Could not compile main script."
                )

            end

            return mainFunction()

        end)

    if not success then

        warn(
            "[KeySystem] Main script failed to load:",
            result
        )

    end

end

--//==================================================
--// VERIFY BUTTON
--//==================================================

verifyButton.MouseButton1Click:Connect(
    performVerification
)

--//==================================================
--// ENTER KEY
--//==================================================

input.FocusLost:Connect(function(enterPressed)

    if enterPressed then
        performVerification()
    end

end)
