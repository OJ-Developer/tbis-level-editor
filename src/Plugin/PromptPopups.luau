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

function PromptPopups.PromptForText(messageText: string, widgetTitle: string, inputPlaceholderText: string?)
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

return PromptPopups