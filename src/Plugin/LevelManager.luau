local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PromptPopups = require(script.Parent.PromptPopups)
local UiTheming = require(script.Parent.UiTheming)

local LevelManager = {}

local plugin

local levelsFolder
local gui: typeof(script.Parent.Parent.Gui.LevelManager)
local templateLevelOption: typeof(gui.TemplateLevelOption)
local selectedLevel: string?

function LevelManager.Init(p, levelManagerGui)
    plugin = p

    -- creates new levels folder if it doesn't already exist
    levelsFolder = ReplicatedStorage:FindFirstChild("Levels")
    if not levelsFolder then
        levelsFolder = Instance.new("Folder")
        levelsFolder.Name = "Levels"
        levelsFolder.Parent = ReplicatedStorage
    end

    -- assigning variables
    gui = levelManagerGui
    templateLevelOption = gui.TemplateLevelOption

    -- options functionality
    gui.Options.NewLevel.MouseButton1Down:Connect(onNewLevelClicked)

    LevelManager.UpdateLevelList()
end

function LevelManager.UpdateLevelList()
    -- clear previous level options
    for _, levelOption in gui.List:GetChildren() do
        if not levelOption:IsA("TextButton") then
            continue
        end

        levelOption:Destroy()
    end

    -- generate new level options
    for _, level: Folder in levelsFolder:GetChildren() do
        local levelOption = templateLevelOption:Clone()
        levelOption.Name = level.Name
        levelOption.Text = level.Name
        levelOption.Visible = true
        levelOption.Parent = gui.List
        -- level selection
        levelOption.MouseButton1Down:Connect(function()
            if selectedLevel then
                if gui.List:FindFirstChild(selectedLevel) then
                    UiTheming.UpdateUiColour(gui.List[selectedLevel])
                end
            end
            selectedLevel = level.Name
            levelOption.BackgroundColor3 = settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.CurrentMarker, Enum.StudioStyleGuideModifier.Selected)
        end)
    end
end

-- NEW LEVELS
function onNewLevelClicked()
    local newLevelName, cancelled = PromptPopups.PromptForText("Please name your new level.", "Name your level", "Level name")
    if cancelled then return end
    LevelManager.NewLevel(newLevelName)
end

function LevelManager.NewLevel(name)
    local newLevel = Instance.new("Folder", levelsFolder)
    newLevel.Name = name
    LevelManager.UpdateLevelList()
end

return LevelManager