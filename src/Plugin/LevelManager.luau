local ChangeHistoryService = game:GetService("ChangeHistoryService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Selection = game:GetService("Selection")
local Config = require(script.Parent.Parent.Config)
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

    if not workspace:FindFirstChild("EditingLevel") then
        Instance.new("Folder", workspace).Name = "EditingLevel"
    end

    -- assigning variables
    gui = levelManagerGui
    templateLevelOption = gui.TemplateLevelOption

    -- options functionality
    gui.Options.NewLevel.MouseButton1Down:Connect(onNewLevelPressed)
    gui.Options.RenameLevel.MouseButton1Down:Connect(onRenameLevelPressed)
    gui.Options.DuplicateLevel.MouseButton1Down:Connect(onDuplicateLevelPressed)
    gui.Options.DeleteLevel.MouseButton1Down:Connect(onDeleteLevelPressed)
    gui.Options.LoadLevel.MouseButton1Down:Connect(onLoadLevelPressed)
    gui.Options.SaveLevel.MouseButton1Down:Connect(onSaveLevelPressed)
    gui.Options.UnloadLevel.MouseButton1Down:Connect(onUnloadLevelPressed)

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
function onNewLevelPressed()
    local newLevelName, cancelled = PromptPopups.PromptForText(
        "Please name your new level.", 
        "Name your level", 
        "Level name"
    )
    if cancelled then return end
    LevelManager.NewLevel(newLevelName)
end

function LevelManager.NewLevel(name: string)
    if doesLevelExist(name) then
        PromptPopups.MessagePopup("New level can not be created. A level with the same name already exists", "Can't create level")
        return
    end

    ChangeHistoryService:SetWaypoint("NewLevel")

    local newLevel = script.Parent.Parent.TemplateLevel:Clone()
    newLevel.Name = name
    newLevel.Parent = levelsFolder

    LevelManager.UpdateLevelList(name)

    ChangeHistoryService:SetWaypoint("NewLevel")
end

-- RENAMING LEVELS
function onRenameLevelPressed()
    if not selectedLevel then return end

    local newLevelName, cancelled = PromptPopups.PromptForText(
        `Please make a new name for {selectedLevel}.`, 
        "Rename your level", "Level name"
    )
    if cancelled then return end

    LevelManager.RenameLevel(selectedLevel, newLevelName)
end

function LevelManager.RenameLevel(levelName: string, newName: string)
    if doesLevelExist(newName) then
        PromptPopups.MessagePopup("Level can not be renamed. A level with the same name already exists.", "Can't rename level")
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

    if workspace.EditingLevel:GetAttribute("Level") == levelName then
        workspace.EditingLevel:SetAttribute("Level", newName)
    end

    ChangeHistoryService:SetWaypoint("RenameLevel")
end

-- DUPLICATING LEVELS
function onDuplicateLevelPressed()
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
function onDeleteLevelPressed()
    if not selectedLevel then return end

    local doDelete, cancelled = PromptPopups.PromptYesNo(
        `Are you sure you want to delete the level "{selectedLevel}"? This cannot be undone!`, 
        "Delete confirmation"
    )
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

-- LEVEL LOADING
function onLoadLevelPressed()
    if not selectedLevel then return end

    if workspace.EditingLevel:GetAttribute("Level") then
        local doLoad, cancelled = PromptPopups.PromptYesNo(
            "Are you sure you want to load this level? Any unsaved changes to the currently loaded level will be deleted!",
            "Load Level Confirmation"
        )

        if cancelled then return end
        if not doLoad then return end
    end

    LevelManager.LoadLevel(selectedLevel)
end

function LevelManager.LoadLevel(levelName: string)
    local level = levelsFolder:FindFirstChild(levelName)
    if not level then return end

    ChangeHistoryService:SetWaypoint("LoadLevel")

    local prevEditingLevel = workspace.EditingLevel
    local loadedLevel = level:Clone()
    loadedLevel.Name = "EditingLevel"
    loadedLevel.Parent = workspace
    loadedLevel:SetAttribute("Level", levelName)
    prevEditingLevel:Destroy()

    -- focus camera on new level
    --Utils.FocusCamera(loadedLevel)
    Selection:Set({loadedLevel})

    ChangeHistoryService:SetWaypoint("LoadLevel")
end

-- LEVEL SAVING
function onSaveLevelPressed()
    if not workspace.EditingLevel:GetAttribute("Level") then
        warn("Cannot save level. No level is loaded.")
        return
    end
    
    if selectedLevel then
        if workspace.EditingLevel:GetAttribute("Level") ~= selectedLevel then
            local doSave, cancelled = PromptPopups.PromptYesNo(
                `Are you sure you want to override the level "{selectedLevel}"? This cannot be undone!`,
                "Save level confirmation"
            )

            if cancelled then return end
            if not doSave then return end
        end

        LevelManager.SaveLevel(selectedLevel)
    else
        LevelManager.SaveLevel(workspace.EditingLevel:GetAttribute("Level"))
    end
end


function LevelManager.SaveLevel(saveToLevelName: string)
    local saveToLevel = levelsFolder:FindFirstChild(saveToLevelName)
    if not saveToLevel then return end

    ChangeHistoryService:SetWaypoint("SaveLevel")

    saveToLevel:Destroy()

    local savedLevel = workspace.EditingLevel:Clone()
    savedLevel.Name = saveToLevelName
    savedLevel.Parent = levelsFolder
    
    ChangeHistoryService:SetWaypoint("SaveLevel")

    if not Config.SaveLevelsAsFile then return end

    Selection:Set({savedLevel})
    plugin:PromptSaveSelectionAsync(savedLevel.Name)
end

-- UNLOADING LEVELS

function onUnloadLevelPressed()
    if not workspace.EditingLevel:GetAttribute("Level") then return end

    local doUnload, cancelled = PromptPopups.PromptYesNo(
        "Are you sure you want to unload the loaded level? Any unsaved changes to the currently loaded level will be deleted!",
        "Unload level confirmation"
    )

    if cancelled then return end
    if not doUnload then return end

    ChangeHistoryService:SetWaypoint("UnloadLevel")

    workspace.EditingLevel:ClearAllChildren()
    workspace.EditingLevel:SetAttribute("Level", nil)

    ChangeHistoryService:SetWaypoint("UnloadLevel")
end

return LevelManager