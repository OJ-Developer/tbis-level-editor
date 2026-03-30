local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LevelManager = {}

local levelsFolder
local gui: typeof(script.Parent.Parent.Gui.LevelManager)
local templateLevelOption: typeof(gui.TemplateLevelOption)
local selectedLevel: Folder?

function LevelManager.Init(levelManagerGui)
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
    end
end

-- NEW LEVELS
function onNewLevelClicked()
    
end

function LevelManager.NewLevel(name)
    
end

return LevelManager