local Utils = require(script.Parent.Parent.Utils)

local UiTheming = {}

UiTheming.CustomStyleGuideColour = {
    Red = {
        Dark = Color3.fromRGB(85, 0, 0),
        Light = Color3.fromRGB(255, 85, 85)
    },
    Green = {
        Dark = Color3.fromRGB(0, 85, 0),
        Light = Color3.fromRGB(85, 255, 85)
    }
}

local function getColour(colourName: string, modifierName: string?): Color3?
    if not colourName then return end

    local colourEnum = Enum.StudioStyleGuideColor:FromName(colourName)

    if not colourEnum then
        if UiTheming.CustomStyleGuideColour[colourName] then
            return UiTheming.CustomStyleGuideColour[colourName][settings().Studio.Theme.Name]
        else
            return
        end
    end

    local modifier
    if modifierName then
        modifier = Enum.StudioStyleGuideModifier:FromName(modifierName)
    end

    return settings().Studio.Theme:GetColor(colourEnum, modifier)
end

function UiTheming.UpdateUiColour(UiElement)
    if not UiElement:IsA("GuiObject") then return end

    local colour = getColour(UiElement:GetAttribute("Colour"), UiElement:GetAttribute("Modifier"))
    if colour then
        UiElement.BackgroundColor3 = colour
    end
    
    local borderColour = getColour(UiElement:GetAttribute("BorderColour"))
    if borderColour then
        UiElement.BorderColor3 = borderColour
    end
    
    if Utils.HasProperty(UiElement, "TextColor3") then
        UiElement.TextColor3 = settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.MainText)
    end
    if Utils.HasProperty(UiElement, "TextColor3") then
        UiElement.TextColor3 = settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.MainText)
    end
end

function UiTheming.UpdateDescendantsUiColours(UiElement: GuiObject)
    UiTheming.UpdateUiColour(UiElement)
    for _, v in UiElement:GetDescendants() do
        UiTheming.UpdateUiColour(v)
    end
end

return UiTheming