-----------------------------------------------
-- Simple Window Management
-- Basic tile left/right, fullscreen toggle, and center
-----------------------------------------------

-- Disable window animations for snappy response
hs.window.animationDuration = 0

-----------------------------------------------
-- Helper Functions
-----------------------------------------------

-- Get the focused window with better detection
local function getFocusedWindow()
    local win = hs.window.focusedWindow()
    
    -- If no focused window found, try alternative methods
    if not win then
        -- Try getting the frontmost window of the current application
        local app = hs.application.frontmostApplication()
        if app then
            win = app:mainWindow()
            if not win then
                -- Try getting any visible window from the frontmost app
                local windows = app:allWindows()
                for _, w in ipairs(windows) do
                    if w:isVisible() and w:isStandard() then
                        win = w
                        break
                    end
                end
            end
        end
    end
    
    -- Final check - if still no window, show detailed error
    if not win then
        local app = hs.application.frontmostApplication()
        local appName = app and app:name() or "Unknown"
        hs.alert.show("No manageable window found for " .. appName)
        return nil
    end
    
    -- Validate the window is manageable
    if not win:isStandard() then
        hs.alert.show("Window is not standard/manageable")
        return nil
    end
    
    return win
end

-- Get screen frame
local function getScreenFrame(win)
    return win:screen():frame()
end

-----------------------------------------------
-- Window Functions
-----------------------------------------------

-- Tile focused window to left half
local function tileLeft()
    local win = getFocusedWindow()
    if not win then return end
    
    -- Exit fullscreen first if needed
    if win:isFullscreen() then
        win:setFullscreen(false)
        hs.timer.doAfter(0.3, function()
            local screen = getScreenFrame(win)
            win:setFrame({
                x = screen.x,
                y = screen.y,
                w = screen.w / 2,
                h = screen.h
            })
            hs.alert.show("Left Half")
        end)
    else
        local screen = getScreenFrame(win)
        win:setFrame({
            x = screen.x,
            y = screen.y,
            w = screen.w / 2,
            h = screen.h
        })
        hs.alert.show("Left Half")
    end
end

-- Tile focused window to right half
local function tileRight()
    local win = getFocusedWindow()
    if not win then return end
    
    -- Exit fullscreen first if needed
    if win:isFullscreen() then
        win:setFullscreen(false)
        hs.timer.doAfter(0.3, function()
            local screen = getScreenFrame(win)
            win:setFrame({
                x = screen.x + screen.w / 2,
                y = screen.y,
                w = screen.w / 2,
                h = screen.h
            })
            hs.alert.show("Right Half")
        end)
    else
        local screen = getScreenFrame(win)
        win:setFrame({
            x = screen.x + screen.w / 2,
            y = screen.y,
            w = screen.w / 2,
            h = screen.h
        })
        hs.alert.show("Right Half")
    end
end

-- Toggle fullscreen
local function toggleFullscreen()
    local win = getFocusedWindow()
    if not win then return end
    
    win:setFullscreen(not win:isFullscreen())
    hs.alert.show(win:isFullscreen() and "Fullscreen" or "Windowed")
end

-- Center window at 80% screen size (exits fullscreen first if needed)
local function centerWindow()
    local win = getFocusedWindow()
    if not win then return end
    
    -- Exit fullscreen mode if currently in fullscreen
    if win:isFullscreen() then
        win:setFullscreen(false)
        -- Wait a moment for fullscreen to exit before centering
        hs.timer.doAfter(0.3, function()
            local screen = getScreenFrame(win)
            local newW = screen.w * 0.8
            local newH = screen.h * 0.8
            
            win:setFrame({
                x = screen.x + (screen.w - newW) / 2,
                y = screen.y + (screen.h - newH) / 2,
                w = newW,
                h = newH
            })
            hs.alert.show("Centered (80%)")
        end)
    else
        -- Not in fullscreen, center immediately
        local screen = getScreenFrame(win)
        local newW = screen.w * 0.8
        local newH = screen.h * 0.8
        
        win:setFrame({
            x = screen.x + (screen.w - newW) / 2,
            y = screen.y + (screen.h - newH) / 2,
            w = newW,
            h = newH
        })
        hs.alert.show("Centered (80%)")
    end
end

-- Close current window
local function closeWindow()
    local win = getFocusedWindow()
    if win then
        win:close()
    end
end

-- Quit current application
local function quitApplication()
    local app = hs.application.frontmostApplication()
    if app then
        app:kill()
        hs.alert.show("Quit " .. app:name())
    end
end

-----------------------------------------------
-- Key Bindings
-----------------------------------------------

-- Tile left/right
hyper:bind({}, "left", function()
    tileLeft()
    hyper.triggered = true
end)

hyper:bind({}, "right", function()
    tileRight()
    hyper.triggered = true
end)

-- Toggle fullscreen
hyper:bind({}, "f", function()
    toggleFullscreen()
    hyper.triggered = true
end)

-- Center window at 80%
hyper:bind({}, "return", function()
    centerWindow()
    hyper.triggered = true
end)

-- Close current window
hyper:bind({}, "w", function()
    closeWindow()
    hyper.triggered = true
end)

-- Quit current application
hyper:bind({}, "q", function()
    quitApplication()
    hyper.triggered = true
end) 