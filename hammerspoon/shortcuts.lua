-- Function to open iTerm
hyper:bind({}, "t", function()
    hs.application.launchOrFocus("iTerm")
    hyper.triggered = true
end)

