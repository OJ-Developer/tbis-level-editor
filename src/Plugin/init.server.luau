local LevelManager = require(script.LevelManager)
local Utils = require(script.Parent.Utils)

-- PLUGIN SETUP

local toolbar = plugin:CreateToolbar("TBIS Level Editor")
local insertObjectsButton = toolbar:CreateButton("Insert Objects", "Open the \"Insert Objects\" menu", "")
local propertiesButton = toolbar:CreateButton("Properties", "Open the \"Properties\" menu", "")
local levelManagerButton = toolbar:CreateButton("Level Manager", "Open the \"Level Manager\" menu", "")

-- UI THEME SETUP

for _, v in Utils.merge(script.Parent.Gui:GetDescendants(), script.Parent.GuiTemplates:GetDescendants()) do
    if v:IsA("GuiObject") then
        if not v:GetAttribute("Colour") then continue end

        local colourName = v:GetAttribute("Colour")
        if not colourName then continue end
        local colour = Enum.StudioStyleGuideColor:FromName(colourName)

        local modifierName = v:GetAttribute("Colour")
        local modifier
        if modifierName and Enum.StudioStyleGuideModifier:FromName(modifierName) then 
            modifier = Enum.StudioStyleGuideModifier:FromName(modifierName)
        end
        
        v.BackgroundColor3 = settings().Studio.Theme:GetColor(colour, modifier)
        
        local borderColourName = v:GetAttribute("BorderColour")
        if borderColourName and Enum.StudioStyleGuideColor:FromName(borderColourName) then
            local colourEnum = Enum.StudioStyleGuideColor:FromName(borderColourName)
            v.BorderColor3 = settings().Studio.Theme:GetColor(colourEnum)
        end
        
        if Utils.HasProperty(v, "TextColor3") then
            v.TextColor3 = settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.MainText)
        end
    end
end

-- WIDGET SETUP

local DEFAULT_WIDGET_WIDTH = 400
local DEFAULT_WIDGET_HEIGHT = 600
local MIN_WIDGET_WIDTH = 200
local MIN_WIDGET_HEIGHT = 300

local insertObjectsWidget = plugin:CreateDockWidgetPluginGuiAsync("tbis insert objects", DockWidgetPluginGuiInfo.new(
    Enum.InitialDockState.Right,
    false,
    false,
    DEFAULT_WIDGET_WIDTH,
    DEFAULT_WIDGET_HEIGHT,
    MIN_WIDGET_WIDTH,
    MIN_WIDGET_HEIGHT
))
insertObjectsWidget.Title = "TBIS Level Editor - Insert Objects"

local propertiesWidget = plugin:CreateDockWidgetPluginGuiAsync("tbis properties", DockWidgetPluginGuiInfo.new(
    Enum.InitialDockState.Right,
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

-- SETUP FUNCTIONALITY STUFF

LevelManager.Init(levelManagerGui)