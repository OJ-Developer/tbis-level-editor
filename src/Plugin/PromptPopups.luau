local HttpService = game:GetService("HttpService")

local plugin: Plugin

local PromptPopups = {}

local DEFAULT_WIDGET_INFO = DockWidgetPluginGuiInfo.new(
    Enum.InitialDockState.Float,
    false,
    false,
    300,
    200,
    300,
    200
)

function PromptPopups.Init(p)
    plugin = p
end

-- TEXT PROMPT
function PromptPopups.PromptForText(messageText: string, widgetTitle: string, inputPlaceholderText: string?): (string, boolean)
    local widget = plugin:CreateDockWidgetPluginGuiAsync(HttpService:GenerateGUID(false), DEFAULT_WIDGET_INFO)

    local ui = script.Parent.Parent.Gui.TextPromptPopup:Clone()
    ui.Parent = widget
    widget.Title = widgetTitle
    widget.Enabled = true
    ui.Message.Text = messageText
    ui.Input.PlaceholderText = inputPlaceholderText

    local entered = false
    local cancelled = false
    local thread1 = task.spawn(function()
        repeat
            entered = ui.Input.FocusLost:Wait()
        until entered
    end)
    local thread2 = task.spawn(function()
        repeat
            local property = widget.Changed:Wait()
            if property == "Enabled" and not widget.Enabled then
                cancelled = true
            end
        until cancelled
    end)

    repeat task.wait() until entered or cancelled

    task.cancel(thread1)
    task.cancel(thread2)

    local result = ui.Input.Text

    widget:Destroy()
    ui:Destroy()

    return result, cancelled
end

-- YES/NO PROMPT
function PromptPopups.PromptYesNo(messageText: string, widgetTitle: string, replacementOptions: {yes: string, no: string}?): (boolean?, boolean)
    local widget = plugin:CreateDockWidgetPluginGuiAsync(HttpService:GenerateGUID(false), DEFAULT_WIDGET_INFO)

    local ui = script.Parent.Parent.Gui.YesNoPromptPopup:Clone()
    ui.Parent = widget
    widget.Title = widgetTitle
    widget.Enabled = true
    ui.Message.Text = messageText

    if replacementOptions then
        ui.Yes.Text = replacementOptions.yes
        ui.No.Text = replacementOptions.no
    end

    local yesSelected = false
    local noSelected = false

    local yesConnection = ui.Yes.MouseButton1Down:Once(function()
        yesSelected = true
    end)
    local noConnection = ui.No.MouseButton1Down:Once(function()
        noSelected = true
    end)
    
    local cancelled = false
    local waitingForCancel = task.spawn(function()
        repeat
            local property = widget.Changed:Wait()
            if property == "Enabled" and not widget.Enabled then
                cancelled = true
            end
        until cancelled
    end)

    repeat task.wait() until yesSelected or noSelected or cancelled

    widget:Destroy()
    ui:Destroy()

    if yesSelected then
        noConnection:Disconnect()
        task.cancel(waitingForCancel)
        return true, false
    elseif noSelected then
        yesConnection:Disconnect()
        task.cancel(waitingForCancel)
        return false, false
    else
        yesConnection:Disconnect()
        noConnection:Disconnect()
        return nil, true
    end
end

function PromptPopups.MessagePopup(message: string, widgetTitle: string)
    local widget = plugin:CreateDockWidgetPluginGuiAsync(HttpService:GenerateGUID(false), DEFAULT_WIDGET_INFO)

    local ui = script.Parent.Parent.Gui.Message:Clone()
    ui.Parent = widget
    widget.Title = widgetTitle
    widget.Enabled = true
    ui.Message.Text = message
    
    task.spawn(function()
        local closed = false
        repeat
            local property = widget.Changed:Wait()
            if property == "Enabled" and not widget.Enabled then
                closed = true
            end
        until closed

        widget:Destroy()
        ui:Destroy()
    end)
end

return PromptPopups