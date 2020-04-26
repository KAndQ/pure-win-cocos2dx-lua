-- socket 客户端, 对 luasocket 的一层封装
-- @author dodo
-- @date 2020.04.26

local socket = require("socket")

local Client = class("Client")

local HEAD_SIZE = 4

--------------------------------------------------------------------------------
-- public methods
--------------------------------------------------------------------------------

-- 构造函数
function Client:ctor()
    self.isConnected = false
    self.listener = nil
    self:resetBuffer()
end

-- 连接到服务器
-- @param address: string 服务器地址
-- @param port: number 端口
function Client:connect(address, port)
    self.sock = socket.tcp()
    local ret = self.sock:connect(address, port)
    if ret == 1 then
        self.isConnected = true
        self.sock:settimeout(0)
    end
end

-- 断开连接
function Client:close()
    if self.isConnected then
        self.isConnected = false
        self.sock:close()
        self:resetBuffer()
    end
end

-- 获得已经收到的数据
-- @return 如果获得完整的数据, 将返回该数据内容, 否则返回 nil
function Client:recv()
    if self.isConnected then
        return table.remove(self.queue, 1)
    else
        return nil
    end
end

-- 发送数据
function Client:send(data)
    local size = string.len(data)
    local byte1 = math.abs(math.floor(bit.band(size, 4278190080) / 2 ^ 24))
    local byte2 = math.abs(math.floor(bit.band(size, 16777215) / 2 ^ 16))
    local byte3 = math.abs(math.floor(bit.band(size, 65535) / 2 ^ 8))
    local byte4 = math.abs(bit.band(size, 255))

    local head = string.char(byte1, byte2, byte3, byte4)
    local ret, err = self.sock:send(head .. data)
    if not ret and err then
        self.isConnected = false
        print("[SEND] ERR = " .. err)
    end
end

-- 设置事件侦听器
function Client:setEventListener(listener)
    self.listener = listener
end

-- 运行在 Scheduler.update 中的函数, 读取网络数据, 并解析成需要的数据格式
function Client:update()
    if self.isConnected then
        local ret, err = self.sock:receive("*a")
        if not ret then
            if err ~= "timeout" then
                self.isConnected = false
                self:resetBuffer()
            end
        else
            if not self.buffer then
                self.buffer = ret
            else
                self.buffer = self.buffer .. ret
            end

            while string.len(self.buffer) >= self.readSize do
                if self.isReadHead then
                    self.isReadHead = false

                    local head = string.sub(self.buffer, 1, self.readSize)
                    self.buffer = string.sub(self.buffer, self.readSize + 1)
                    local byte1 = string.byte(head, 1)
                    local byte2 = string.byte(head, 2)
                    local byte3 = string.byte(head, 3)
                    local byte4 = string.byte(head, 4)
                    self.readSize = (byte1 * 2 ^ 24) + (byte2 * 2 ^ 16) + (byte3 * 2 ^ 8) + byte4
                else
                    self.isReadHead = true

                    local data = string.sub(self.buffer, 1, self.readSize)
                    self.buffer = string.sub(self.buffer, self.readSize + 1)
                    table.insert(self.queue, data)
                end
            end
        end
    end
end

--------------------------------------------------------------------------------
-- private methods
--------------------------------------------------------------------------------

function Client:resetBuffer()
    self.queue = {}
    self.isReadHead = true
    self.readSize = HEAD_SIZE
    self.buffer = nil
end

return Client
