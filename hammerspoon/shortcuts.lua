-- Function to open iTerm
hyper:bind({}, "t", function()
    hs.application.launchOrFocus("iTerm")
    hyper.triggered = true
end)

-- Function to open or minimize Outlook
hyper:bind({}, "o", function()
    hs.application.launchOrFocus("Microsoft Outlook") 
    hyper.triggered = true
end)

-- Function to open or minimize Slack
hyper:bind({}, "s", function()
    hs.application.launchOrFocus("Slack")
    hyper.triggered = true
end)
