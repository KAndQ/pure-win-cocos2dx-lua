
cc.FileUtils:getInstance():setPopupNotify(false)

require "net.init"
require "config"
require "cocos.init"

local function main()
    require("app.MyApp"):create():run()
    require("net.socket.Demo")
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
