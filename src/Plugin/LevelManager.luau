local ChangeHistoryService = game:GetService("ChangeHistoryService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PromptPopups = require(script.Parent.PromptPopups)
local UiTheming = require(script.Parent.UiTheming)

local LevelManager = {}

--local plugin

local levelsFolder
local gui: typeof(script.Parent.Parent.Gui.LevelManager)
local templateLevelOption: typeof(gui.TemplateLevelOption)
local selectedLevel: string?

function LevelManager.Init(p, levelManagerGui)
    --plugin = p

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
    gui.Options.RenameLevel.MouseButton1Down:Connect(onRenameLevelClicked)
    gui.Options.DuplicateLevel.MouseButton1Down:Connect(onDuplicateLevelClicked)
    gui.Options.DeleteLevel.MouseButton1Down:Connect(onDeleteLevelClicked)

    LevelManager.UpdateLevelList()

    -- updating level list on undo and redo
    local function updateLevelListNoParams()
        LevelManager.UpdateLevelList()
    end
    ChangeHistoryService.OnUndo:Connect(updateLevelListNoParams)
    ChangeHistoryService.OnRedo:Connect(updateLevelListNoParams)
end

-- function for checking if a level already exists
function doesLevelExist(levelName: string)
    for _, level in levelsFolder:GetChildren() do
        if levelName == level.Name then
            return true
        end
    end

    return false
end

function LevelManager.UpdateLevelList(newSelectedLevel: string?)
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

    if newSelectedLevel then
        selectedLevel = newSelectedLevel
        gui.List:FindFirstChild(newSelectedLevel).BackgroundColor3 = settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.CurrentMarker, Enum.StudioStyleGuideModifier.Selected)
    else
        selectedLevel = nil
    end
end

-- NEW LEVELS
function onNewLevelClicked()
    local newLevelName, cancelled = PromptPopups.PromptForText("Please name your new level.", "Name your level", "Level name")
    if cancelled then return end
    LevelManager.NewLevel(newLevelName)
end

function LevelManager.NewLevel(name: string)
    if doesLevelExist(name) then
        warn("New level can not be created. A level with the same name already exists")
        return
    end

    ChangeHistoryService:SetWaypoint("NewLevel")

    local newLevel = Instance.new("Folder", levelsFolder)
    newLevel.Name = name
    LevelManager.UpdateLevelList(name)

    ChangeHistoryService:SetWaypoint("NewLevel")
end

-- RENAMING LEVELS
function onRenameLevelClicked()
    if not selectedLevel then return end

    local newLevelName, cancelled = PromptPopups.PromptForText(`Please make a new name for {selectedLevel}.`, "Rename your level", "Level name")
    if cancelled then return end

    LevelManager.RenameLevel(selectedLevel, newLevelName)
end

function LevelManager.RenameLevel(levelName: string, newName: string)
    if doesLevelExist(newName) then
        warn("Level can not be renamed. A level with the same name already exists.")
        return
    end

    local level = levelsFolder:FindFirstChild(levelName)
    if not level then
        warn(`Tried to rename level "{levelName}" however it does not exist.`)
        return
    end

    ChangeHistoryService:SetWaypoint("RenameLevel")

    level.Name = newName
    LevelManager.UpdateLevelList(newName)

    ChangeHistoryService:SetWaypoint("RenameLevel")
end

-- DUPLICATING LEVELS
function onDuplicateLevelClicked()
    if not selectedLevel then return end
    LevelManager.DuplicateLevel(selectedLevel)
end

function increaseNameNumber(currentName: string): string
    local split = string.split(currentName, "_")
    local currentNum = tonumber(split[#split])
    if currentNum then
        return string.sub(currentName, 1, -1-#(tostring(currentNum)))..tostring(currentNum+1)
    else
        return currentName.."_2"
    end
end

function LevelManager.DuplicateLevel(levelName: string)
    local level = levelsFolder:FindFirstChild(levelName)
    if not level then
        warn(`Tried to duplicate level "{levelName}" however it does not exist.`)
        return
    end

    local newName = levelName
    repeat
        newName = increaseNameNumber(newName)
    until not doesLevelExist(newName)

    ChangeHistoryService:SetWaypoint("DuplicateLevel")
    
    local newLevel = level:Clone()
    newLevel.Name = newName
    newLevel.Parent = levelsFolder

    LevelManager.UpdateLevelList(newName)

    ChangeHistoryService:SetWaypoint("DuplicateLevel")
end

-- DELETING LEVELS
function onDeleteLevelClicked()
    if not selectedLevel then return end

    local doDelete, cancelled = PromptPopups.PromptYesNo(`Are you sure you want to delete the level "{selectedLevel}"? This cannot be undone!`, "Delete confirmation")
    if cancelled then return end
    if not doDelete then return end

    LevelManager.DeleteLevel(selectedLevel)
end

function LevelManager.DeleteLevel(levelName: string)
    if not doesLevelExist(levelName) then return end

    ChangeHistoryService:SetWaypoint("DeleteLevel")

    levelsFolder:FindFirstChild(levelName):Destroy()
    LevelManager.UpdateLevelList()

    ChangeHistoryService:SetWaypoint("DeleteLevel")
end

return LevelManager