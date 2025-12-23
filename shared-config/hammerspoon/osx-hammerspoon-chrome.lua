-- Bookmark Classification System for Hammerspoon

local DATABASE = os.getenv("HOME") .. "/.canelhasmateus/state.db"
local APPEND_FILE = os.getenv("HOME") .. "/.canelhasmateus/articles.tsv"

-- Utilities Module
local Utilities = {}

function Utilities.appendToFile(content)
    local file = io.open(APPEND_FILE, "a")
    if file then
        file:write(content)
        file:close()
    end
end

function Utilities.findTransitions(currentUrl)
    -- Create table if not exists
    local createSql = string.format(
        'sqlite3 "%s" "create table if not exists bookmarks(url text not null unique, transitions text not null)"',
        DATABASE
    )
    os.execute(createSql)

    -- Query existing transitions
    local selectSql = string.format(
        'sqlite3 "%s" "select transitions from bookmarks where url like \'%s\'"',
        DATABASE,
        currentUrl:gsub("'", "''")  -- Escape single quotes
    )

    local handle = io.popen(selectSql)
    local result = handle:read("*a")
    handle:close()

    if result and result ~= "" then
        return hs.json.decode(result)
    end
    return {}
end

function Utilities.persistTransition(transition)
    local transitionData = {}
    for _, t in ipairs(transition.previous) do
        table.insert(transitionData, t)
    end
    table.insert(transitionData, {
        date = transition.date,
        status = transition.status
    })

    local content = hs.json.encode(transitionData):gsub('"', '\\"')
    local sql = string.format(
        'sqlite3 "%s" "replace into bookmarks(url, transitions) values (\'%s\', \'%s\')"',
        DATABASE,
        transition.resource:gsub("'", "''"),
        content
    )
    os.execute(sql)
end

-- Main Functions
local function persist(transition)
    local content = string.format("\n%s\t%s\t%s\n",
        transition.date,
        transition.status,
        transition.resource
    )
    Utilities.appendToFile(content)
    Utilities.persistTransition(transition)
end

local function getCurrentChromeUrl()
    local script = [[
        tell application "Google Chrome"
            get URL of active tab of front window
        end tell
    ]]
    local ok, result = hs.osascript.applescript(script)
    if ok then
        return result
    end
    return nil
end

local function getBrazilTime()
    -- Get UTC time and subtract 3 hours for Brazil time
    local timestamp = os.time() - (3 * 60 * 60)
    return os.date("%Y-%m-%d %H:%M:%S", timestamp)
end

local function promptTransition(currentUrl)
    local previousTransitions = Utilities.findTransitions(currentUrl)

    -- Build history list
    local historyLines = {}
    for _, t in ipairs(previousTransitions) do
        table.insert(historyLines, string.format("%s\t%s", t.date, t.status))
    end
    local history = table.concat(historyLines, "\n")

    -- Create chooser
    local choices = {
        {text = "Queue"},
        {text = "History"},
        {text = "Wrote"},
        {text = "Good"},
        {text = "Premium"},
        {text = "Bad"},
        {text = "Explore"},
        {text = "Skip"},
        {text = "Tool"}
    }

    local selectedStatus = nil
    local chooser = hs.chooser.new(function(choice)
        if choice then
            selectedStatus = choice.text
        end
    end)

    chooser:choices(choices)
    chooser:placeholderText(string.format("Classify: %s", currentUrl))
    chooser:subTextColor({white = 0.5})

    -- Show history as subtitle for first item
    if #historyLines > 0 then
        choices[1].subText = "Previous: " .. table.concat(historyLines, " → ")
    end
    chooser:choices(choices)

    -- Show and wait for selection
    chooser:show()

    if selectedStatus then
        return {
            date = getBrazilTime(),
            status = selectedStatus,
            resource = currentUrl,
            previous = previousTransitions
        }
    end
    return nil
end

-- Main entry point
local function run()
    local currentUrl = getCurrentChromeUrl()

    if not currentUrl then
        hs.alert.show("Could not get Chrome URL")
        return
    end

    local transition = promptTransition(currentUrl)
    if transition then
        persist(transition)
        hs.alert.show(string.format("Saved: %s", transition.status))
    end
end

-- Bind to a hotkey (example: Cmd+Shift+B)
hs.hotkey.bind({"cmd", "alt"}, ";", run)

-- Return module for manual invocation
return {
    run = run
}