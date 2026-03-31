local Utils = require(script.Parent.Parent.Utils)

local UiTheming = {}

function UiTheming.UpdateUiColour(UiElement)
    if not UiElement:IsA("GuiObject") then return end
    if UiElement:GetAttribute("Colour") then
        local colourName = UiElement:GetAttribute("Colour")
        if not colourName then return end
        local colour = Enum.StudioStyleGuideColor:FromName(colourName)

        local modifierName = UiElement:GetAttribute("Modifier")
        local modifier
        if modifierName and Enum.StudioStyleGuideModifier:FromName(modifierName) then
            modifier = Enum.StudioStyleGuideModifier:FromName(modifierName)
        end
        
        UiElement.BackgroundColor3 = settings().Studio.Theme:GetColor(colour, modifier)
    end
    
    local borderColourName = UiElement:GetAttribute("BorderColour")
    if borderColourName and Enum.StudioStyleGuideColor:FromName(borderColourName) then
        local colourEnum = Enum.StudioStyleGuideColor:FromName(borderColourName)
        UiElement.BorderColor3 = settings().Studio.Theme:GetColor(colourEnum)
    end
    
    if Utils.HasProperty(UiElement, "TextColor3") then
        UiElement.TextColor3 = settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.MainText)
    end
    if Utils.HasProperty(UiElement, "TextColor3") then
        UiElement.TextColor3 = settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.MainText)
    end
end

function UiTheming.UpdateAllUiColours()
    for _, v in Utils.merge(script.Parent.Parent.Gui:GetDescendants()) do
        UiTheming.UpdateUiColour(v)
    end
end

return UiTheming