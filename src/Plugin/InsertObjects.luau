local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Selection = game:GetService("Selection")
local Utils = require(script.Parent.Parent.Utils)

--local plugin

local InsertObjects = {}

local insertableObjects = script.Parent.Parent.InsertableObjects
local gui: typeof(script.Parent.Parent.Gui.InsertObjects)
local selectedCategory: string?

function InsertObjects.Init(p, ui)
    --plugin = p

    gui = ui

    for _, category: Instance in gui.Categories:GetChildren() do
        if category:IsA("TextButton") then
            category.MouseButton1Down:Connect(function()
                ChangeCategory(category.Name)
            end)
        end
    end
end

function ChangeCategory(newCategory: string)
    selectedCategory = newCategory
    InsertObjects.RefreshList()
end

function InsertObjects.RefreshList()
    -- clear anything already in the list
    for _, button in gui.List:GetChildren() do
        if button:IsA("TextButton") then
            button:Destroy()
        end
    end

    if not selectedCategory then return end
    if not insertableObjects:FindFirstChild(selectedCategory) then return end

    -- refresh list
    local objectsToShow: {BasePart | Model} = insertableObjects[selectedCategory]:GetChildren()
    for _, object in objectsToShow do
        local newButton = gui.TemplateInsertableObjectButton:Clone()
        newButton.Name = object.Name
        newButton.Text = object.Name
        newButton.Parent = gui.List
        newButton.Visible = true
        newButton.MouseButton1Down:Connect(function()
            InsertObjects.InsertObject(object)
        end)
    end
end

function InsertObjects.InsertObject(object: BasePart | Model)
    if not object.Parent then return end -- this is needed to make the dumb bullshit error warning thing go away
    if not workspace.EditingLevel:GetAttribute("Level") then
        warn("Can't add new object. No level is loaded.")
        return
    end

    ChangeHistoryService:SetWaypoint("InsertObject")

    -- create new object and parent it to the correct place
    local newObject = object:Clone()
    local parent = object:GetAttribute("Parent")
    if parent then
        newObject.Parent = workspace.EditingLevel:FindFirstChild(parent)
    else
        newObject.Parent = workspace.EditingLevel:FindFirstChild(object.Parent.Name)
    end

    -- position object
    if newObject:IsA("BasePart") then
        newObject.Position = workspace.CurrentCamera.CFrame.Position

        local target = workspace.CurrentCamera.CFrame.lookVector * 20
        local shapecast = workspace:Shapecast(newObject, target)
        if shapecast then
            newObject.Position = workspace.CurrentCamera.CFrame.Position + workspace.CurrentCamera.CFrame.lookVector * shapecast.Distance
        else
            newObject.Position = target + workspace.CurrentCamera.CFrame.Position
        end

        newObject.Position = Utils.roundVector(newObject.Position)
    elseif newObject:IsA("Model") then
        newObject:PivotTo(CFrame.new(workspace.CurrentCamera.CFrame.Position))

        local cframe, size = newObject:GetBoundingBox()
        local boundingBox = Instance.new("Part")
        boundingBox.Anchored = true
        boundingBox.Parent = workspace
        boundingBox.CFrame = cframe
        boundingBox.Size = size
        boundingBox.Position = workspace.CurrentCamera.CFrame.Position

        local target = workspace.CurrentCamera.CFrame.lookVector * 20
        local shapecast = workspace:Shapecast(boundingBox, target)
        if shapecast then
            newObject:PivotTo(CFrame.new(workspace.CurrentCamera.CFrame.Position + workspace.CurrentCamera.CFrame.lookVector * shapecast.Distance))
        else
            newObject:PivotTo(CFrame.new(target + workspace.CurrentCamera.CFrame.Position))
        end

        boundingBox:Destroy()

        newObject:PivotTo(CFrame.new(Utils.roundVector(newObject.WorldPivot.Position)) * newObject.WorldPivot.Rotation)
    end
    
    -- select the object
    Selection:Set({newObject})

    ChangeHistoryService:SetWaypoint("InsertObject")
end

return InsertObjects