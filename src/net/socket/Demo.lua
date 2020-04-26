-- demo
-- 服务器可以使用 https://github.com/KAndQ/ts-pingpong
-- @author dodo
-- @date 2020.04.26

local scene = display.newScene()
display.runScene(scene)

local buttonIndex = 0
local ROW_MAX = 6
local INTERVAL = cc.p(180, 80)
local buttonOffset = cc.p(80, display.height - 32)

-- 创建按钮
-- @param text 按钮文本
-- @param clickListener 点击按钮回调
local function createButton(text, clickListener)
    local button = ccui.Button:create()
    button:setTitleText(text)
    button:setTitleFontSize(28)
    button:setPosition(cc.p(buttonOffset.x + (buttonIndex % ROW_MAX) * INTERVAL.x, buttonOffset.y + math.floor(buttonIndex / ROW_MAX) * INTERVAL.y))
    button:addClickEventListener(clickListener)
    scene:addChild(button)

    buttonIndex = buttonIndex + 1

    return button
end

local Client = require("net.socket.Client")
local ADDRESS = "127.0.0.1"
local PORT = 48080

-- 连接服务器
local client = Client.new()
client:connect(ADDRESS, PORT)

local scheduler = cc.Director:getInstance():getScheduler()
scheduler:scheduleScriptFunc(function(dt)
    client:update()

    local data = client:recv()
    if data then
        print("[CLIENT RECV]: " .. data)
    end
end, 0, false)

createButton("关闭连接", function()
    client:close()
end)

createButton("PING", function()
    client:send("ping")
    print("[CLIENT SEND]: ping")
end)

dump(bit.band(128, 2151686272))
