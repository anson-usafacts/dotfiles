-- Function to open iTerm
hyper:bind({}, "t", function()
    hs.application.launchOrFocus("iTerm")
    hyper.triggered = true
end)

-- Function to open Outlook
hyper:bind({}, "o", function()
    hs.application.launchOrFocus("Microsoft Outlook") 
    hyper.triggered = true
end)

-- Function to open or minimize Slack
hyper:bind({}, "s", function()
    hs.application.launchOrFocus("Slack")
    hyper.triggered = true
end)

-- Function to open Arc browser
hyper:bind({}, "a", function()
    hs.application.launchOrFocus("Arc")
    hyper.triggered = true
end)

-- Function to open or minimize Cursor
hyper:bind({}, "c", function()
    hs.application.launchOrFocus("Cursor")
    hyper.triggered = true
end)

-- Test shortcut to verify everything is working
hyper:bind({}, "z", function()
    hs.alert.show("Hammerspoon is working! 🎉")
    hyper.triggered = true
end)

-- Open README file in iTerm with glow rendering
hyper:bind({}, "h", function()
    local readmePath = "/Users/ansonh/dotfiles/hammerspoon/README.md"
    hs.application.launchOrFocus("iTerm")
    hs.timer.doAfter(0.5, function()
        hs.eventtap.keyStroke({"cmd"}, "t") -- New tab
        hs.timer.doAfter(0.2, function()
            local command = string.format("clear && echo '📖 Hammerspoon Shortcuts Reference' && echo '════════════════════════════════════════════════════' && echo '' && glow '%s' && echo '' && echo '════════════════════════════════════════════════════' && echo 'Press any key to close...' && read -n 1", readmePath)
            hs.pasteboard.setContents(command)
            hs.eventtap.keyStroke({"cmd"}, "v")
            hs.eventtap.keyStroke({}, "return")
        end)
    end)
    hs.alert.show("Opening shortcuts reference...")
    hyper.triggered = true
end)
