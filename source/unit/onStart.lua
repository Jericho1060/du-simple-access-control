--version 1.0.0

--LUA PARAMETERS
local AllowedUsersId = "" --export: the list of all IDs, comma separated
local AllowedUsersName = "Jericho" --export: the list of all names, comma separated (Case sensitive)
local AllowedUserOrgsId = "18261" --export: the list of all organisation IDs, comma separated
local AllowedUserOrgsName = "Federatis" --export: the list of all organisation Names, comma separated (Case sensitive)

--Libraries
--split is a function to split a string in a table with a delimiter written by Jericho
function split(s,d)local t={}s:gsub("[^"..d.."]+",function(w)table.insert(t,w)end)return t end

--hide unit widget
unit.hideWidget()

--auto detecting the door, force fields and the screens
Doors = {}
Fields = {}
Screens = {}
for slotName,slot in pairs(unit) do
    if
        type(slot) == "table"
        and type(slot.export) == "table"
        and slot.getClass
    then
        local ElementClass = slot.getClass():lower()
        if ElementClass:find("doorunit") then
            table.insert(Doors, slot)
        elseif ElementClass:find("forcefieldunit") then
            table.insert(Fields, slot)
            slot.activate()
        elseif ElementClass:find("screenunit") then
            table.insert(Screens, slot)
            slot.activate()
        else
            system.print(ElementClass)
        end
    end
end

function getRenderScript(access)
    local color = "red"
    local message = "Access Denied"
    if access then
        color = "green"
        message = "Access Granted"
    end
    return [[
    setBackgroundColor(15/255,24/255,29/255)
    local rx,ry = getResolution()
    local cx, cy = getCursor()
    if vmode then
    ry,rx = getResolution()
    cy, cx = getCursor()
    cx = rx - cx
    if vmode_side == "right" then
    cy = ry - cy
    cx = rx - cx
end
end

    local smallBold=loadFont('Play-Bold',40)
    local bigBold=loadFont('Play-Bold',64)

    local front=createLayer()
    local back=createLayer()
    setDefaultStrokeColor( back,Shape_Line,0,0,0,0.5)
    setDefaultShadow( back,Shape_Line,6,0,0,0,0.5)
    setDefaultFillColor( front,Shape_BoxRounded,249/255,212/255,123/255,1)
    setDefaultFillColor( front,Shape_Text,0,0,0,1)
    setDefaultFillColor( front,Shape_Box,0.075,0.125,0.156,1)
    setDefaultFillColor( front,Shape_Text,0.710,0.878,0.941,1)

    local red = {177/255,42/255,42/255}
    local green = {34/255,177/255,76/255}

    function renderHeader(title)
    local h = 55
    addLine(back,0,h+12,rx,h+12)
    addBox(front,0,12,rx,h)
    addText(front,smallBold,title,44,h-12)
end

    setNextFillColor(front, ]] .. color .. [[[1], ]] .. color .. [[[2], ]] .. color .. [[[3], 1)
    setNextTextAlign(front,AlignH_Center,AlignV_Middle)
    addText(front,smallBold,"]] .. message .. [[", rx/2, ry/4)


    setNextFillColor(front, ]] .. color .. [[[1], ]] .. color .. [[[2], ]] .. color .. [[[3], 1)
    setNextTextAlign(front,AlignH_Center,AlignV_Middle)
    addText(front,bigBold,"]] .. player.getName() .. [[", rx/2, ry/2)

    renderHeader("Access Control System")
    requestAnimationFrame(10)
    ]]
end

local AccessPermitted = false

function setRenderScriptOnScreens(access)
    for _,screen in pairs(Screens) do
        screen.setRenderScript(getRenderScript(access))
    end
end

function grantAccess()
    AccessPermitted = true
    for _,Door in pairs(Doors) do
        Door.open() --open the door
    end
    for _,Field in pairs(Fields) do
        Field.deactivate() --open the field
    end
    setRenderScriptOnScreens(true)
end

function closeAll()
    AccessPermitted = false
    for _,Door in pairs(Doors) do
        Door.close() --close the door
    end
    for _,Field in pairs(Fields) do
        Field.activate() --close the field
    end
end

function rejectAccess()
    closeAll()
    setRenderScriptOnScreens(false)
    unit.exit()
end

--converting to tables
local tPermittedUsersId = split(AllowedUsersId,',') or {}
local tPermittedUsersName = split(AllowedUsersName,',') or {}
local tPermittedOrgsId = split(AllowedUserOrgsId,',') or {}
local tPermittedOrgsName = split(AllowedUserOrgsName,',') or {}

local player_id = player.getId()

for _,id in pairs(tPermittedUsersId) do
    if id == player_id then
        grantAccess()
        AccessPermitted = true
        break
    end
end

if not AccessPermitted then
    local player_name = player.getName()
    for _,name in pairs(tPermittedUsersName) do
        if name == player_name then
            grantAccess()
            break
        end
    end
end

if not AccessPermitted then
    local player_orgs_id = player.getOrgIds()
    for _,oid in pairs(player_orgs_id) do
        for _,id in pairs(tPermittedOrgsId) do
            if tonumber(id) == oid then
                grantAccess()
                break
            end
        end
        --if access is granted, end the loop
        if AccessPermitted then break end
        --if not a valid ID, veifying the org name
        local o = system.getOrganization(oid)
        if o.name then
            for _,name in pairs(tPermittedOrgsName) do
            if name == o.name then
                grantAccess()
                break
            end
        end
        end
        --if access is granted, end the loop
        if AccessPermitted then break end
    end
end

if not AccessPermitted then
    rejectAccess()
end