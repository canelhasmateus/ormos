-- Hammerspoon Configuration

-- Debug: Show all keypresses
local keyLogger = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(event)
  local keyCode = event:getKeyCode()
  local keyChar = hs.keycodes.map[keyCode]
  local flags = event:getFlags()

  local modifiers = {}
  if flags.cmd then table.insert(modifiers, "cmd") end
  if flags.shift then table.insert(modifiers, "shift") end
  if flags.alt then table.insert(modifiers, "alt") end
  if flags.ctrl then table.insert(modifiers, "ctrl") end

  local modStr = table.concat(modifiers, "+")
  if modStr ~= "" then modStr = modStr .. "+" end

  hs.alert.show(modStr .. (keyChar or keyCode))
  return false  -- Don't block the event
end)

local toggleKey = function()
    if keyLogger:isEnabled() then
        keyLogger:stop()
        hs.alert.show("Key logger OFF")
    else
        keyLogger:start()
        hs.alert.show("Key logger ON")
    end
  end

local bgOsa = function(script)
    local previousApp = hs.application.frontmostApplication()

    -- Get the window ID from AppleScript
    local ok, windowId = hs.osascript.applescript(script)
    local watcher
    watcher = hs.window.filter.new(function(w) return w:id() == windowId end):subscribe(hs.window.filter.windowDestroyed, function()
        if previousApp then previousApp:activate() end
        watcher:unsubscribeAll()
        end)
end

local todos = function()
    bgOsa([[
             tell application "iTerm"
                 launch
                 set newWindow to (create window with default profile command "~/.canelhasmateus/bin/osx-todos.sh")
                 return id of newWindow
             end tell
         ]])
  end

local blurb = function()
    bgOsa([[
             tell application "iTerm"
                 launch
                 set newWindow to (create window with default profile command "~/.canelhasmateus/bin/osx-blurb.sh")
                 return id of newWindow
             end tell
         ]])
  end

local work = function()
    bgOsa([[
             tell application "iTerm"
                 launch
                 set newWindow to (create window with default profile command "~/.canelhasmateus/bin/osx-work.sh")
                 return id of newWindow
             end tell
         ]])
  end

local utilities = {
  {
    text = "Key Logger - Toggle keyboard event display",
    subText = "Shows all keypresses for debugging",
  },
  {
    text = "Reload Hammerspoon Config",
    subText = "Restart Hammerspoon configuration",
  },
  {
    text = "Todos",
    subText = "todos",
  },
  {
    text = "Blurb",
    subText = "blurb",
  },
  {
    text = "Work",
    subText = "work",
  },
}

local utilityFunctions = {
  function() toggleKey() end,
  function() hs.reload() end,
  function() todos() end,
  function() blurb() end,
  function() work() end,
}

local utilityChooser = hs.chooser.new(function(choice)
  if not choice then return end
  local index = choice.index
  if utilityFunctions[index] then
    utilityFunctions[index]()
  end
end)

hs.hotkey.bind({"cmd", "alt"}, "u", function()
  -- Add index to each choice
  local choices = {}
  for i, utility in ipairs(utilities) do
    choices[i] = {
      text = utility.text,
      subText = utility.subText,
      index = i
    }
  end
  utilityChooser:choices(choices)
  utilityChooser:show()
end)

 hs.hotkey.bind({"ctrl"}, "f19", todos)
 hs.hotkey.bind({"ctrl"}, "f18", blurb)
 hs.hotkey.bind({"ctrl"}, "f16", work)
 require("osx-hammerspoon-chrome")