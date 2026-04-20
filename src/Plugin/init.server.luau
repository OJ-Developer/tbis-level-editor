local RunService = game:GetService("RunService")
local InsertObjects = require(script.InsertObjects)
local LevelManager = require(script.LevelManager)
local PromptPopups = require(script.PromptPopups)
local UiTheming = require(script.UiTheming)

if RunService:IsRunning() then return end

PromptPopups.Init(plugin)

-- PLUGIN SETUP

local toolbar = plugin:CreateToolbar("TBIS Level Editor")

local function main()
    local insertObjectsButton = toolbar:CreateButton("Insert Objects", "Open the \"Insert Objects\" menu", "")
    local propertiesButton = toolbar:CreateButton("Properties", "Open the \"Properties\" menu", "")
    local levelManagerButton = toolbar:CreateButton("Level Manager", "Open the \"Level Manager\" menu", "")

    -- WIDGET SETUP

    local DEFAULT_WIDGET_WIDTH = 400
    local DEFAULT_WIDGET_HEIGHT = 600
    local MIN_WIDGET_WIDTH = 200
    local MIN_WIDGET_HEIGHT = 300

    local insertObjectsWidget = plugin:CreateDockWidgetPluginGuiAsync("tbis insert objects", DockWidgetPluginGuiInfo.new(
        Enum.InitialDockState.Left,
        false,
        false,
        DEFAULT_WIDGET_WIDTH,
        DEFAULT_WIDGET_HEIGHT,
        MIN_WIDGET_WIDTH,
        MIN_WIDGET_HEIGHT
    ))
    insertObjectsWidget.Title = "TBIS Level Editor - Insert Objects"

    local propertiesWidget = plugin:CreateDockWidgetPluginGuiAsync("tbis properties", DockWidgetPluginGuiInfo.new(
        Enum.InitialDockState.Left,
        false,
        false,
        DEFAULT_WIDGET_WIDTH,
        DEFAULT_WIDGET_HEIGHT,
        MIN_WIDGET_WIDTH,
        MIN_WIDGET_HEIGHT
    ))
    propertiesWidget.Title = "TBIS Level Editor - Properties"

    local levelManagerWidget = plugin:CreateDockWidgetPluginGuiAsync("tbis level manager", DockWidgetPluginGuiInfo.new(
        Enum.InitialDockState.Left,
        false,
        false,
        DEFAULT_WIDGET_WIDTH,
        DEFAULT_WIDGET_HEIGHT,
        MIN_WIDGET_WIDTH,
        MIN_WIDGET_HEIGHT
    ))
    levelManagerWidget.Title = "TBIS Level Editor - Level Manager"

    local insertObjectsGui = script.Parent.Gui.InsertObjects
    local propertiesGui = script.Parent.Gui.Properties
    local levelManagerGui = script.Parent.Gui.LevelManager

    insertObjectsGui.Parent = insertObjectsWidget
    propertiesGui.Parent = propertiesWidget
    levelManagerGui.Parent = levelManagerWidget

    insertObjectsButton.Click:Connect(function()
        insertObjectsWidget.Enabled = not insertObjectsWidget.Enabled
    end)
    propertiesButton.Click:Connect(function()
        propertiesWidget.Enabled = not propertiesWidget.Enabled
    end)
    levelManagerButton.Click:Connect(function()
        levelManagerWidget.Enabled = not levelManagerWidget.Enabled
    end)

    -- UI THEME SETUP

    local function updateUiColours()
        UiTheming.UpdateDescendantsUiColours(insertObjectsGui)
        UiTheming.UpdateDescendantsUiColours(propertiesGui)
        UiTheming.UpdateDescendantsUiColours(levelManagerGui)
        UiTheming.UpdateDescendantsUiColours(script.Parent.Gui)
    end
    updateUiColours()
    settings().Studio.ThemeChanged:Connect(updateUiColours)

    -- SETUP FUNCTIONALITY STUFF

    LevelManager.Init(plugin, levelManagerGui)
    InsertObjects.Init(plugin, insertObjectsGui)

    workspace:SetAttribute("tbisleveleditor", true)

    -- DELETE EDITING LEVEL FOLDER WHEN PLAYING

    if workspace:FindFirstChild("DeleteEditingLevel") then return end

    local deleteEditingLevel = Instance.new("Script")
    deleteEditingLevel.Name = "DeleteEditingLevel"
    deleteEditingLevel.Source = [[
-- deletes the "EditingLevel" folder when the game is played
if workspace:FindFirstChild("EditingLevel") then
    workspace.EditingLevel:Destroy()
end
script:Destroy()]]
    deleteEditingLevel.Parent = workspace
end

-- INITIALIZATION
if workspace:GetAttribute("tbisleveleditor") then
    main()
else
    local initButton = toolbar:CreateButton("init tbis level editor", "Initialize the TUNNELER But it sucks level editor plugin.", "")
    
    initButton.Click:Connect(function()
        local result, cancelled = PromptPopups.PromptYesNo(
            "Are you sure you want to Initialize the TUNNELER But it sucks level editor? Doing so modify or break anything that already exists in this place.",
            "TBIS Level editor - Confirm initialization"
        )

        if cancelled then return end
        if not result then return end

        initButton.Enabled = false

        main()
    end)
end